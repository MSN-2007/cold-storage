"""
ColdSmart FastAPI Main Application
Production-ready app with lifespan, middleware, routers, WebSocket, and monitoring
"""
import asyncio
import logging
from contextlib import asynccontextmanager
from typing import Dict, Any

import structlog
from fastapi import FastAPI, Request, WebSocket, WebSocketDisconnect, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse
from prometheus_fastapi_instrumentator import Instrumentator

from app.config import settings
from app.database import create_tables, AsyncSessionLocal
from app.mqtt.broker_client import mqtt_client
from app.routers import (
    auth, devices, users, chambers, sensor_data, goods, crop_profiles, alerts, ota
)
from app.routers.reports_diagnostics_audit import reports_router, diagnostics_router, audit_router
from app.core.exceptions import ColdSmartException

# ─── Logging Setup ────────────────────────────────────────────────────────────

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.dev.ConsoleRenderer() if settings.DEBUG else structlog.processors.JSONRenderer(),
    ]
)
logger = structlog.get_logger()


# ─── WebSocket Connection Manager ─────────────────────────────────────────────

class ConnectionManager:
    """Manages WebSocket connections for real-time dashboard updates."""

    def __init__(self):
        # company_id -> list of active WebSocket connections
        self.active_connections: Dict[str, list] = {}

    async def connect(self, websocket: WebSocket, company_id: str, user_id: str):
        await websocket.accept()
        if company_id not in self.active_connections:
            self.active_connections[company_id] = []
        self.active_connections[company_id].append({
            "ws": websocket,
            "user_id": user_id,
        })
        logger.info("WS connected", company_id=company_id, user_id=user_id)

    def disconnect(self, websocket: WebSocket, company_id: str):
        if company_id in self.active_connections:
            self.active_connections[company_id] = [
                c for c in self.active_connections[company_id] if c["ws"] != websocket
            ]

    async def broadcast_to_company(self, company_id: str, message: Dict[str, Any]):
        """Broadcast a message to all connected WebSocket clients of a company."""
        if company_id not in self.active_connections:
            return
        dead = []
        for conn in self.active_connections[company_id]:
            try:
                await conn["ws"].send_json(message)
            except Exception:
                dead.append(conn)
        for d in dead:
            self.active_connections[company_id].remove(d)

    async def send_to_user(self, company_id: str, user_id: str, message: Dict[str, Any]):
        """Send a message to a specific user."""
        if company_id not in self.active_connections:
            return
        for conn in self.active_connections[company_id]:
            if conn["user_id"] == user_id:
                try:
                    await conn["ws"].send_json(message)
                except Exception:
                    pass


ws_manager = ConnectionManager()


# ─── Lifespan (startup/shutdown) ──────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifecycle: startup → run → shutdown."""
    logger.info("🚀 ColdSmart starting up...", version=settings.APP_VERSION, env=settings.ENVIRONMENT)

    # Security warning for default SECRET_KEY in production
    if settings.SECRET_KEY == "insecure_debug_secret_key_change_in_production" and settings.ENVIRONMENT == "production":
        logger.error("🛑 SECURITY CRITICAL: Running in production mode with default SECRET_KEY! Update settings.SECRET_KEY immediately.")

    # Create/verify database tables
    await create_tables()
    logger.info("✅ Database tables ready")

    # Seed system crop profiles if not present
    await _seed_crop_profiles()

    # Initialize MinIO buckets
    await _initialize_minio_buckets()

    # Start MQTT broker client in background
    mqtt_task = asyncio.create_task(mqtt_client.run())
    logger.info("✅ MQTT broker client started")

    yield  # Application running

    # Graceful shutdown
    mqtt_task.cancel()
    try:
        await mqtt_task
    except asyncio.CancelledError:
        pass
    logger.info("🛑 ColdSmart shut down gracefully")


async def _seed_crop_profiles():
    """Seed the database with system crop profiles on first run."""
    from app.models import CropProfile
    from app.services.crop_intelligence import get_system_profiles
    from sqlalchemy import select, func

    async with AsyncSessionLocal() as db:
        count_res = await db.execute(
            select(func.count(CropProfile.id)).where(CropProfile.is_system == True)
        )
        count = count_res.scalar()

        if count == 0:
            logger.info("Seeding system crop profiles...")
            for profile_data in get_system_profiles():
                profile = CropProfile(**profile_data)
                db.add(profile)
            await db.commit()
            logger.info("✅ Crop profiles seeded")


async def _initialize_minio_buckets():
    """Verify and auto-create required MinIO / S3 buckets on startup."""
    import boto3
    from botocore.config import Config
    try:
        s3 = boto3.client(
            "s3",
            endpoint_url=f"http{'s' if settings.MINIO_SECURE else ''}://{settings.MINIO_ENDPOINT}",
            aws_access_key_id=settings.MINIO_ACCESS_KEY,
            aws_secret_access_key=settings.MINIO_SECRET_KEY,
            config=Config(signature_version="s3v4"),
        )
        buckets = [
            settings.MINIO_BUCKET_FIRMWARE,
            settings.MINIO_BUCKET_REPORTS,
            settings.MINIO_BUCKET_EXPORTS,
        ]
        for bucket in buckets:
            try:
                s3.head_bucket(Bucket=bucket)
                logger.info("MinIO bucket verified", bucket=bucket)
            except Exception:
                logger.info("MinIO bucket missing, creating it...", bucket=bucket)
                try:
                    s3.create_bucket(Bucket=bucket)
                    logger.info("MinIO bucket created successfully", bucket=bucket)
                except Exception as ex:
                    logger.warn("Could not create MinIO bucket (it might exist or local offline)", bucket=bucket, error=str(ex))
    except Exception as e:
        logger.error("Failed to initialize MinIO buckets connection", error=str(e))


# ─── App Factory ──────────────────────────────────────────────────────────────

def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.APP_NAME,
        version=settings.APP_VERSION,
        description=(
            "ColdSmart – Intelligent Produce Preservation and Cold Storage Operating System. "
            "Complete IoT-driven cold storage management for farmers, operators, and enterprises."
        ),
        docs_url="/api/docs" if not settings.DEBUG is False else None,
        redoc_url="/api/redoc",
        openapi_url="/api/openapi.json",
        lifespan=lifespan,
    )

    # ── Middleware ─────────────────────────────────────────────────────────────
    app.add_middleware(GZipMiddleware, minimum_size=1000)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.ALLOWED_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # ── Prometheus Metrics ─────────────────────────────────────────────────────
    if settings.PROMETHEUS_ENABLED:
        Instrumentator().instrument(app).expose(app, endpoint="/metrics")

    # ── Exception Handlers ─────────────────────────────────────────────────────
    @app.exception_handler(ColdSmartException)
    async def coldsmart_exception_handler(request: Request, exc: ColdSmartException):
        return JSONResponse(
            status_code=exc.status_code,
            content={"detail": exc.message, "code": exc.error_code},
        )

    @app.exception_handler(Exception)
    async def generic_exception_handler(request: Request, exc: Exception):
        logger.error("Unhandled exception", exc_info=exc, path=request.url.path)
        return JSONResponse(
            status_code=500,
            content={"detail": "Internal server error. Please try again."},
        )

    # ── API Routers ────────────────────────────────────────────────────────────
    prefix = settings.API_V1_PREFIX

    app.include_router(auth.router, prefix=prefix)
    app.include_router(devices.router, prefix=prefix)
    app.include_router(users.router, prefix=prefix)
    app.include_router(chambers.router, prefix=prefix)
    app.include_router(sensor_data.router, prefix=prefix)
    app.include_router(goods.router, prefix=prefix)
    app.include_router(crop_profiles.router, prefix=prefix)
    app.include_router(alerts.router, prefix=prefix)
    app.include_router(ota.router, prefix=prefix)
    app.include_router(reports_router, prefix=prefix)
    app.include_router(diagnostics_router, prefix=prefix)
    app.include_router(audit_router, prefix=prefix)

    # ── WebSocket Endpoints ────────────────────────────────────────────────────

    @app.websocket("/ws/{company_id}")
    async def websocket_endpoint(websocket: WebSocket, company_id: str, token: str):
        """
        Real-time WebSocket endpoint for dashboard.
        Connect: ws://host/ws/{company_id}?token=<access_token>

        Messages pushed:
        - telemetry: { type: "telemetry", data: {...} }
        - alert: { type: "alert", data: {...} }
        - device_status: { type: "device_status", data: {...} }
        """
        from app.core.security import decode_token
        try:
            claims = decode_token(token)
            user_id = claims.get("sub")
            if claims.get("company_id") != company_id:
                await websocket.close(code=4001)
                return
        except Exception:
            await websocket.close(code=4001)
            return

        await ws_manager.connect(websocket, company_id, user_id)
        try:
            while True:
                # Keep connection alive; handle ping/pong
                data = await websocket.receive_text()
                if data == "ping":
                    await websocket.send_text("pong")
        except WebSocketDisconnect:
            ws_manager.disconnect(websocket, company_id)

    # ── Health & Info Endpoints ────────────────────────────────────────────────

    @app.get("/health", tags=["System"])
    async def health_check():
        return {
            "status": "healthy",
            "version": settings.APP_VERSION,
            "environment": settings.ENVIRONMENT,
        }

    @app.get("/", tags=["System"])
    async def root():
        return {
            "name": settings.APP_NAME,
            "version": settings.APP_VERSION,
            "docs": "/api/docs",
        }

    return app


# ─── Entry Point ──────────────────────────────────────────────────────────────

app = create_app()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        workers=1 if settings.DEBUG else 4,
        log_level=settings.LOG_LEVEL.lower(),
    )
