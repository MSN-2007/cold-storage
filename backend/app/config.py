"""
ColdSmart Backend Configuration
Production-grade settings via pydantic-settings
"""
from typing import Optional, List
from pydantic_settings import BaseSettings
from pydantic import field_validator
import secrets


class Settings(BaseSettings):
    # ─── App ────────────────────────────────────────────────────────────────
    APP_NAME: str = "ColdSmart API"
    APP_VERSION: str = "1.0.0"
    ENVIRONMENT: str = "production"  # development | staging | production
    DEBUG: bool = False
    SECRET_KEY: str = secrets.token_urlsafe(64)
    API_V1_PREFIX: str = "/api/v1"
    ALLOWED_ORIGINS: List[str] = ["*"]

    # ─── Database ────────────────────────────────────────────────────────────
    DATABASE_URL: str = "postgresql+asyncpg://coldsmart:coldsmart_pass@localhost:5432/coldsmart_db"
    DATABASE_POOL_SIZE: int = 20
    DATABASE_MAX_OVERFLOW: int = 40
    DATABASE_POOL_TIMEOUT: int = 30

    # ─── Redis ───────────────────────────────────────────────────────────────
    REDIS_URL: str = "redis://localhost:6379/0"
    REDIS_CACHE_TTL: int = 300  # seconds

    # ─── JWT Auth ────────────────────────────────────────────────────────────
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    OTP_EXPIRE_SECONDS: int = 300

    # ─── MQTT / EMQX ─────────────────────────────────────────────────────────
    MQTT_BROKER_HOST: str = "localhost"
    MQTT_BROKER_PORT: int = 1883
    MQTT_BROKER_WS_PORT: int = 8083
    MQTT_USERNAME: str = "coldsmart_server"
    MQTT_PASSWORD: str = "mqtt_secure_pass"
    MQTT_CLIENT_ID: str = "coldsmart_backend_001"
    MQTT_QOS: int = 1
    MQTT_KEEPALIVE: int = 60
    MQTT_TLS_ENABLED: bool = False

    # ─── MinIO / S3 ──────────────────────────────────────────────────────────
    MINIO_ENDPOINT: str = "localhost:9000"
    MINIO_ACCESS_KEY: str = "coldsmart_minio"
    MINIO_SECRET_KEY: str = "minio_secret_pass"
    MINIO_SECURE: bool = False
    MINIO_BUCKET_FIRMWARE: str = "firmware"
    MINIO_BUCKET_REPORTS: str = "reports"
    MINIO_BUCKET_EXPORTS: str = "exports"

    # ─── Firebase (Push Notifications) ───────────────────────────────────────
    FIREBASE_CREDENTIALS_PATH: Optional[str] = None

    # ─── SMS / OTP ───────────────────────────────────────────────────────────
    TWILIO_ACCOUNT_SID: Optional[str] = None
    TWILIO_AUTH_TOKEN: Optional[str] = None
    TWILIO_FROM_NUMBER: Optional[str] = None

    # ─── Email ───────────────────────────────────────────────────────────────
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USER: Optional[str] = None
    SMTP_PASSWORD: Optional[str] = None
    SMTP_FROM: str = "noreply@coldsmart.io"

    # ─── Rate Limiting ────────────────────────────────────────────────────────
    RATE_LIMIT_REQUESTS: int = 100
    RATE_LIMIT_WINDOW: int = 60  # seconds

    # ─── Celery ──────────────────────────────────────────────────────────────
    CELERY_BROKER_URL: str = "redis://localhost:6379/1"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/2"

    # ─── Monitoring ──────────────────────────────────────────────────────────
    PROMETHEUS_ENABLED: bool = True
    LOG_LEVEL: str = "INFO"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True


settings = Settings()
