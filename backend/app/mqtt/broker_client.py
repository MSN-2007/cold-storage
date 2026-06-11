"""
ColdSmart MQTT Architecture
Topics, message handler, and broker client for IoT device communication
"""
import json
import asyncio
import logging
from datetime import datetime, timezone
from typing import Optional, Dict, Any
from uuid import UUID

import aiomqtt
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update

from app.config import settings
from app.database import AsyncSessionLocal
from app.models import Device, DeviceStatus, Chamber, SensorReading
from app.services.alert_engine import AlertEngine

logger = logging.getLogger(__name__)


# ─── MQTT Topic Templates ─────────────────────────────────────────────────────
# Format: cs/{company_id}/device/{device_id}/{subtopic}

class Topics:
    @staticmethod
    def telemetry(company_id: str, device_id: str) -> str:
        return f"cs/{company_id}/device/{device_id}/telemetry"

    @staticmethod
    def status(company_id: str, device_id: str) -> str:
        return f"cs/{company_id}/device/{device_id}/status"

    @staticmethod
    def alerts(company_id: str, device_id: str) -> str:
        return f"cs/{company_id}/device/{device_id}/alerts"

    @staticmethod
    def commands(company_id: str, device_id: str) -> str:
        return f"cs/{company_id}/device/{device_id}/commands"

    @staticmethod
    def ota_start(company_id: str, device_id: str) -> str:
        return f"cs/{company_id}/device/{device_id}/ota/start"

    @staticmethod
    def ota_progress(company_id: str, device_id: str) -> str:
        return f"cs/{company_id}/device/{device_id}/ota/progress"

    @staticmethod
    def ota_result(company_id: str, device_id: str) -> str:
        return f"cs/{company_id}/device/{device_id}/ota/result"

    @staticmethod
    def diagnostics_request(company_id: str, device_id: str) -> str:
        return f"cs/{company_id}/device/{device_id}/diagnostics/request"

    @staticmethod
    def diagnostics_result(company_id: str, device_id: str) -> str:
        return f"cs/{company_id}/device/{device_id}/diagnostics/result"

    # Wildcard subscriptions for the backend
    TELEMETRY_ALL = "cs/+/device/+/telemetry"
    STATUS_ALL = "cs/+/device/+/status"
    OTA_PROGRESS_ALL = "cs/+/device/+/ota/progress"
    OTA_RESULT_ALL = "cs/+/device/+/ota/result"
    DIAGNOSTICS_ALL = "cs/+/device/+/diagnostics/result"


# ─── Telemetry Payload Schema (Device → Cloud) ───────────────────────────────
"""
Expected telemetry payload from IoT device:
{
    "device_id": "CS-001-ABCDEF",
    "timestamp": "2025-01-01T10:00:00Z",
    "chambers": [
        {
            "chamber_number": 1,
            "temperature": 4.2,
            "humidity": 88.5,
            "co2": 620.0,
            "o2": 20.5,
            "ethylene": 0.7,
            "carbon_monoxide": 0.0,
            "methane": 0.0
        }
    ],
    "device_health": {
        "battery": 100,
        "wifi_rssi": -65,
        "uptime_seconds": 86400
    }
}
"""


# ─── Message Handler ──────────────────────────────────────────────────────────

class MQTTMessageHandler:
    def __init__(self):
        self._device_cache: Dict[str, Device] = {}

    async def handle_telemetry(self, payload: Dict[str, Any], db: AsyncSession):
        """Process incoming sensor telemetry from a device."""
        try:
            device_id_str = payload.get("device_id")
            if not device_id_str:
                logger.warning("Telemetry missing device_id")
                return

            # Fetch device
            result = await db.execute(
                select(Device).where(Device.device_id == device_id_str)
            )
            device = result.scalar_one_or_none()
            if not device:
                logger.warning(f"Unknown device: {device_id_str}")
                return

            now = datetime.now(timezone.utc)
            ts_str = payload.get("timestamp")
            if ts_str:
                try:
                    recorded_at = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
                except Exception:
                    recorded_at = now
            else:
                recorded_at = now

            # Update device status
            await db.execute(
                update(Device)
                .where(Device.id == device.id)
                .values(
                    status=DeviceStatus.ONLINE,
                    last_seen_at=now,
                    signal_strength=payload.get("device_health", {}).get("wifi_rssi"),
                )
            )

            alert_engine = AlertEngine(db)

            # Process each chamber
            for chamber_data in payload.get("chambers", []):
                chamber_num = chamber_data.get("chamber_number")
                chamber_res = await db.execute(
                    select(Chamber).where(
                        Chamber.device_id == device.id,
                        Chamber.chamber_number == chamber_num,
                        Chamber.is_active == True,
                    )
                )
                chamber = chamber_res.scalar_one_or_none()
                if not chamber:
                    continue

                # Save sensor reading
                reading = SensorReading(
                    chamber_id=chamber.id,
                    device_id=device.id,
                    recorded_at=recorded_at,
                    temperature=chamber_data.get("temperature"),
                    humidity=chamber_data.get("humidity"),
                    co2=chamber_data.get("co2"),
                    o2=chamber_data.get("o2"),
                    ethylene=chamber_data.get("ethylene"),
                    carbon_monoxide=chamber_data.get("carbon_monoxide"),
                    methane=chamber_data.get("methane"),
                    raw_payload=chamber_data,
                )
                db.add(reading)

                # Run alert engine
                await alert_engine.process_reading(chamber, chamber_data, device.company_id)

            await db.commit()

        except Exception as e:
            logger.error(f"Error processing telemetry: {e}", exc_info=True)
            await db.rollback()

    async def handle_status(self, payload: Dict[str, Any], db: AsyncSession):
        """Process device heartbeat/status update."""
        device_id_str = payload.get("device_id")
        status_str = payload.get("status", "online")

        status_map = {
            "online": DeviceStatus.ONLINE,
            "offline": DeviceStatus.OFFLINE,
            "maintenance": DeviceStatus.MAINTENANCE,
        }
        device_status = status_map.get(status_str, DeviceStatus.ONLINE)

        await db.execute(
            update(Device)
            .where(Device.device_id == device_id_str)
            .values(
                status=device_status,
                last_seen_at=datetime.now(timezone.utc),
                firmware_version=payload.get("firmware_version"),
                ip_address=payload.get("ip_address"),
            )
        )
        await db.commit()

    async def handle_ota_progress(self, payload: Dict[str, Any], db: AsyncSession):
        """Track OTA firmware update progress."""
        from app.models import OTADeployment, OTAStatus
        device_id_str = payload.get("device_id")
        progress = payload.get("progress_percent", 0)
        status_str = payload.get("status", "downloading")

        status_map = {
            "downloading": OTAStatus.DOWNLOADING,
            "installing": OTAStatus.INSTALLING,
            "success": OTAStatus.SUCCESS,
            "failed": OTAStatus.FAILED,
        }

        result = await db.execute(
            select(Device).where(Device.device_id == device_id_str)
        )
        device = result.scalar_one_or_none()
        if not device:
            return

        dep_res = await db.execute(
            select(OTADeployment).where(
                OTADeployment.device_id == device.id,
                OTADeployment.status.in_([OTAStatus.PENDING, OTAStatus.DOWNLOADING, OTAStatus.INSTALLING])
            ).limit(1)
        )
        deployment = dep_res.scalar_one_or_none()
        if deployment:
            deployment.progress_percent = progress
            deployment.status = status_map.get(status_str, OTAStatus.DOWNLOADING)
            if status_str == "success":
                deployment.completed_at = datetime.now(timezone.utc)
                # Update device firmware version
                await db.execute(
                    update(Device)
                    .where(Device.id == device.id)
                    .values(firmware_version=payload.get("new_firmware_version"))
                )
            elif status_str == "failed":
                deployment.error_message = payload.get("error_message")
                deployment.completed_at = datetime.now(timezone.utc)
            await db.commit()

    async def handle_diagnostics_result(self, payload: Dict[str, Any], db: AsyncSession):
        """Store device diagnostic results."""
        from app.models import DiagnosticResult
        device_id_str = payload.get("device_id")

        result = await db.execute(select(Device).where(Device.device_id == device_id_str))
        device = result.scalar_one_or_none()
        if not device:
            return

        diag = DiagnosticResult(
            device_id=device.id,
            results=payload.get("results", {}),
            overall_status=payload.get("overall_status", "unknown"),
            notes=payload.get("notes"),
        )
        db.add(diag)
        await db.commit()


# ─── MQTT Broker Client ───────────────────────────────────────────────────────

class MQTTBrokerClient:
    """
    Production MQTT client using aiomqtt.
    Runs as a background service alongside FastAPI.
    """

    def __init__(self):
        self.handler = MQTTMessageHandler()
        self._client: Optional[aiomqtt.Client] = None

    async def publish(self, topic: str, payload: Dict[str, Any], qos: int = 1):
        """Publish a message to a topic."""
        if self._client:
            await self._client.publish(
                topic,
                payload=json.dumps(payload).encode(),
                qos=qos,
            )

    async def send_command(self, company_id: str, device_id: str, command: Dict[str, Any]):
        """Send a command to a specific device."""
        topic = Topics.commands(company_id, device_id)
        await self.publish(topic, command)

    async def trigger_ota(self, company_id: str, device_id: str, ota_payload: Dict[str, Any]):
        """Trigger OTA update on a device."""
        topic = Topics.ota_start(company_id, device_id)
        await self.publish(topic, ota_payload)

    async def request_diagnostics(self, company_id: str, device_id: str, test_types: list):
        """Request device to run diagnostics."""
        topic = Topics.diagnostics_request(company_id, device_id)
        await self.publish(topic, {"tests": test_types, "timestamp": datetime.now(timezone.utc).isoformat()})

    async def run(self):
        """Main MQTT subscription loop."""
        logger.info(f"Connecting to MQTT broker: {settings.MQTT_BROKER_HOST}:{settings.MQTT_BROKER_PORT}")

        while True:
            try:
                import uuid
                client_id = f"{settings.MQTT_CLIENT_ID}_{uuid.uuid4().hex[:8]}"
                async with aiomqtt.Client(
                    hostname=settings.MQTT_BROKER_HOST,
                    port=settings.MQTT_BROKER_PORT,
                    username=settings.MQTT_USERNAME,
                    password=settings.MQTT_PASSWORD,
                    identifier=client_id,
                    keepalive=settings.MQTT_KEEPALIVE,
                ) as client:
                    self._client = client

                    # Subscribe to all device topics
                    await client.subscribe(Topics.TELEMETRY_ALL, qos=settings.MQTT_QOS)
                    await client.subscribe(Topics.STATUS_ALL, qos=settings.MQTT_QOS)
                    await client.subscribe(Topics.OTA_PROGRESS_ALL, qos=settings.MQTT_QOS)
                    await client.subscribe(Topics.OTA_RESULT_ALL, qos=settings.MQTT_QOS)
                    await client.subscribe(Topics.DIAGNOSTICS_ALL, qos=settings.MQTT_QOS)

                    logger.info("MQTT broker connected and subscribed.")

                    async for message in client.messages:
                        asyncio.create_task(self._dispatch(message))

            except aiomqtt.MqttError as e:
                logger.error(f"MQTT connection lost: {e}. Reconnecting...")
                await asyncio.sleep(5)
            except Exception as e:
                logger.error(f"MQTT unexpected error: {e}. Retrying in 5 seconds...")
                await asyncio.sleep(5)

    async def _dispatch(self, message):
        """Route incoming MQTT messages to appropriate handlers."""
        topic = str(message.topic)
        try:
            payload = json.loads(message.payload.decode())
        except json.JSONDecodeError:
            logger.warning(f"Invalid JSON on topic: {topic}")
            return

        async with AsyncSessionLocal() as db:
            if "/telemetry" in topic:
                await self.handler.handle_telemetry(payload, db)
            elif "/status" in topic:
                await self.handler.handle_status(payload, db)
            elif "/ota/progress" in topic or "/ota/result" in topic:
                await self.handler.handle_ota_progress(payload, db)
            elif "/diagnostics/result" in topic:
                await self.handler.handle_diagnostics_result(payload, db)


# ─── Singleton ────────────────────────────────────────────────────────────────
mqtt_client = MQTTBrokerClient()
