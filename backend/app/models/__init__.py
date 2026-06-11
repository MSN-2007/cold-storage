"""
ColdSmart – Complete Database Models
All SQLAlchemy ORM models for production schema
"""
import uuid
import enum
from datetime import datetime
from typing import Optional, List

from sqlalchemy import (
    Column, String, Float, Boolean, Integer, BigInteger,
    DateTime, ForeignKey, Text, JSON, Enum as SAEnum,
    Index, UniqueConstraint, CheckConstraint, func, text
)
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship, mapped_column, Mapped

from app.database import Base


# ─── Enums ────────────────────────────────────────────────────────────────────

class UserRole(str, enum.Enum):
    SUPER_ADMIN = "super_admin"
    OWNER = "owner"
    MANAGER = "manager"
    OPERATOR = "operator"
    TECHNICIAN = "technician"
    VIEWER = "viewer"


class AlertSeverity(str, enum.Enum):
    INFO = "info"
    WARNING = "warning"
    CRITICAL = "critical"
    EMERGENCY = "emergency"


class AlertStatus(str, enum.Enum):
    ACTIVE = "active"
    ACKNOWLEDGED = "acknowledged"
    RESOLVED = "resolved"
    DISMISSED = "dismissed"


class DeviceStatus(str, enum.Enum):
    ONLINE = "online"
    OFFLINE = "offline"
    WARNING = "warning"
    CRITICAL = "critical"
    MAINTENANCE = "maintenance"


class OTAStatus(str, enum.Enum):
    PENDING = "pending"
    DOWNLOADING = "downloading"
    INSTALLING = "installing"
    SUCCESS = "success"
    FAILED = "failed"
    ROLLED_BACK = "rolled_back"


class AuthProvider(str, enum.Enum):
    EMAIL = "email"
    PHONE = "phone"
    OTP = "otp"


class GoodsStage(str, enum.Enum):
    PRE_HARVEST = "pre_harvest"
    FRESHLY_HARVESTED = "freshly_harvested"
    CURING = "curing"
    STORAGE = "storage"
    READY_FOR_MARKET = "ready_for_market"


class AuditAction(str, enum.Enum):
    LOGIN = "login"
    LOGOUT = "logout"
    PARAM_CHANGE = "param_change"
    DEVICE_ACCESS = "device_access"
    FIRMWARE_UPDATE = "firmware_update"
    USER_CREATED = "user_created"
    USER_MODIFIED = "user_modified"
    USER_DELETED = "user_deleted"
    DEVICE_PAIRED = "device_paired"
    DEVICE_TRANSFERRED = "device_transferred"
    ALERT_ACKNOWLEDGED = "alert_acknowledged"
    REPORT_GENERATED = "report_generated"
    CALIBRATION = "calibration"
    DIAGNOSTICS = "diagnostics"


class ReportType(str, enum.Enum):
    TEMPERATURE_COMPLIANCE = "temperature_compliance"
    HUMIDITY_COMPLIANCE = "humidity_compliance"
    GAS_COMPLIANCE = "gas_compliance"
    AUDIT_REPORT = "audit_report"
    MAINTENANCE_REPORT = "maintenance_report"
    ALERT_REPORT = "alert_report"
    INVENTORY_REPORT = "inventory_report"


class ReportFormat(str, enum.Enum):
    PDF = "pdf"
    EXCEL = "excel"
    CSV = "csv"


# ─── Mixins ───────────────────────────────────────────────────────────────────

class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)


class UUIDMixin:
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)


# ─── Company (Multi-tenant root) ──────────────────────────────────────────────

class Company(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "companies"

    name: Mapped[str] = mapped_column(String(255), nullable=False)
    slug: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    logo_url: Mapped[Optional[str]] = mapped_column(String(500))
    address: Mapped[Optional[str]] = mapped_column(Text)
    country: Mapped[str] = mapped_column(String(100), default="IN")
    currency: Mapped[str] = mapped_column(String(10), default="INR")
    timezone: Mapped[str] = mapped_column(String(50), default="Asia/Kolkata")
    subscription_plan: Mapped[str] = mapped_column(String(50), default="starter")
    max_devices: Mapped[int] = mapped_column(Integer, default=10)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    settings: Mapped[Optional[dict]] = mapped_column(JSONB)

    # Relationships
    users: Mapped[List["User"]] = relationship("User", back_populates="company", cascade="all, delete-orphan")
    devices: Mapped[List["Device"]] = relationship("Device", back_populates="company", cascade="all, delete-orphan")
    crop_profiles: Mapped[List["CropProfile"]] = relationship("CropProfile", back_populates="company")


# ─── User ─────────────────────────────────────────────────────────────────────

class User(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "users"

    company_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("companies.id", ondelete="CASCADE"), nullable=False)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    email: Mapped[Optional[str]] = mapped_column(String(255), unique=True, index=True)
    phone: Mapped[Optional[str]] = mapped_column(String(20), unique=True, index=True)
    password_hash: Mapped[Optional[str]] = mapped_column(String(255))
    role: Mapped[UserRole] = mapped_column(SAEnum(UserRole), nullable=False, default=UserRole.VIEWER)
    auth_provider: Mapped[AuthProvider] = mapped_column(SAEnum(AuthProvider), default=AuthProvider.EMAIL)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_email_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    is_phone_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    last_login_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    profile_image_url: Mapped[Optional[str]] = mapped_column(String(500))
    preferred_language: Mapped[str] = mapped_column(String(10), default="en")
    notification_preferences: Mapped[Optional[dict]] = mapped_column(JSONB)
    totp_secret: Mapped[Optional[str]] = mapped_column(String(64))
    app_mode: Mapped[str] = mapped_column(String(20), default="simple")  # simple | expert

    # Relationships
    company: Mapped["Company"] = relationship("Company", back_populates="users")
    sessions: Mapped[List["UserSession"]] = relationship("UserSession", back_populates="user", cascade="all, delete-orphan")
    device_access: Mapped[List["DeviceUser"]] = relationship("DeviceUser", back_populates="user", foreign_keys="[DeviceUser.user_id]")
    audit_logs: Mapped[List["AuditLog"]] = relationship("AuditLog", back_populates="user")
    notification_tokens: Mapped[List["NotificationToken"]] = relationship("NotificationToken", back_populates="user")

    __table_args__ = (
        CheckConstraint("email IS NOT NULL OR phone IS NOT NULL", name="ck_users_email_or_phone"),
        Index("ix_users_company_id", "company_id"),
    )


class UserSession(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "user_sessions"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    refresh_token_hash: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    device_info: Mapped[Optional[dict]] = mapped_column(JSONB)
    ip_address: Mapped[Optional[str]] = mapped_column(String(45))
    user_agent: Mapped[Optional[str]] = mapped_column(String(500))
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    is_revoked: Mapped[bool] = mapped_column(Boolean, default=False)
    last_used_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))

    user: Mapped["User"] = relationship("User", back_populates="sessions")
    __table_args__ = (Index("ix_sessions_user_id", "user_id"),)


class OTPRecord(Base, UUIDMixin):
    __tablename__ = "otp_records"

    target: Mapped[str] = mapped_column(String(255), nullable=False, index=True)  # email or phone
    otp_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    purpose: Mapped[str] = mapped_column(String(50), nullable=False)  # login | verify | reset
    attempts: Mapped[int] = mapped_column(Integer, default=0)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    is_used: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class NotificationToken(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "notification_tokens"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    token: Mapped[str] = mapped_column(String(500), nullable=False)
    platform: Mapped[str] = mapped_column(String(20), nullable=False)  # android | ios | web
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    user: Mapped["User"] = relationship("User", back_populates="notification_tokens")
    __table_args__ = (
        UniqueConstraint("user_id", "token", name="uq_notification_tokens_user_token"),
    )


# ─── Device ───────────────────────────────────────────────────────────────────

class Device(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "devices"

    company_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("companies.id", ondelete="CASCADE"), nullable=False)
    device_id: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)  # Hardware ID
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text)
    location: Mapped[Optional[str]] = mapped_column(String(255))
    qr_code: Mapped[Optional[str]] = mapped_column(String(500))  # URL to QR image
    bluetooth_id: Mapped[Optional[str]] = mapped_column(String(100))
    firmware_version: Mapped[Optional[str]] = mapped_column(String(50))
    hardware_version: Mapped[Optional[str]] = mapped_column(String(50))
    model: Mapped[Optional[str]] = mapped_column(String(100))
    status: Mapped[DeviceStatus] = mapped_column(SAEnum(DeviceStatus), default=DeviceStatus.OFFLINE)
    last_seen_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    ip_address: Mapped[Optional[str]] = mapped_column(String(45))
    mac_address: Mapped[Optional[str]] = mapped_column(String(20))
    wifi_ssid: Mapped[Optional[str]] = mapped_column(String(100))
    signal_strength: Mapped[Optional[int]] = mapped_column(Integer)  # dBm
    mqtt_credentials: Mapped[Optional[dict]] = mapped_column(JSONB)  # Encrypted
    config: Mapped[Optional[dict]] = mapped_column(JSONB)
    total_health_score: Mapped[Optional[float]] = mapped_column(Float)

    # Relationships
    company: Mapped["Company"] = relationship("Company", back_populates="devices")
    chambers: Mapped[List["Chamber"]] = relationship("Chamber", back_populates="device", cascade="all, delete-orphan")
    users: Mapped[List["DeviceUser"]] = relationship("DeviceUser", back_populates="device")
    ota_deployments: Mapped[List["OTADeployment"]] = relationship("OTADeployment", back_populates="device")
    audit_logs: Mapped[List["AuditLog"]] = relationship("AuditLog", back_populates="device")

    __table_args__ = (Index("ix_devices_company_id", "company_id"),)


class DeviceUser(Base, UUIDMixin, TimestampMixin):
    """Many-to-many: Device <-> User with permission level"""
    __tablename__ = "device_users"

    device_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("devices.id", ondelete="CASCADE"), nullable=False)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    permission_level: Mapped[str] = mapped_column(String(50), default="view")  # view | operate | admin
    granted_by: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"))
    expires_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))

    device: Mapped["Device"] = relationship("Device", back_populates="users")
    user: Mapped["User"] = relationship("User", back_populates="device_access", foreign_keys=[user_id])

    __table_args__ = (
        UniqueConstraint("device_id", "user_id", name="uq_device_users"),
    )


# ─── Chamber ──────────────────────────────────────────────────────────────────

class Chamber(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "chambers"

    device_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("devices.id", ondelete="CASCADE"), nullable=False)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    chamber_number: Mapped[int] = mapped_column(Integer, nullable=False)
    capacity_kg: Mapped[Optional[float]] = mapped_column(Float)
    capacity_units: Mapped[Optional[int]] = mapped_column(Integer)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    current_crop_profile_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("crop_profiles.id"))
    health_score: Mapped[Optional[float]] = mapped_column(Float)

    # Target parameters (operator-configured)
    target_temperature: Mapped[Optional[float]] = mapped_column(Float)
    target_humidity: Mapped[Optional[float]] = mapped_column(Float)
    target_co2: Mapped[Optional[float]] = mapped_column(Float)
    target_o2: Mapped[Optional[float]] = mapped_column(Float)
    target_ethylene: Mapped[Optional[float]] = mapped_column(Float)
    target_co: Mapped[Optional[float]] = mapped_column(Float)
    target_methane: Mapped[Optional[float]] = mapped_column(Float)

    # Acceptable ranges
    temp_min: Mapped[Optional[float]] = mapped_column(Float)
    temp_max: Mapped[Optional[float]] = mapped_column(Float)
    humidity_min: Mapped[Optional[float]] = mapped_column(Float)
    humidity_max: Mapped[Optional[float]] = mapped_column(Float)
    co2_min: Mapped[Optional[float]] = mapped_column(Float)
    co2_max: Mapped[Optional[float]] = mapped_column(Float)
    o2_min: Mapped[Optional[float]] = mapped_column(Float)
    o2_max: Mapped[Optional[float]] = mapped_column(Float)
    ethylene_max: Mapped[Optional[float]] = mapped_column(Float)
    co_max: Mapped[Optional[float]] = mapped_column(Float)
    methane_max: Mapped[Optional[float]] = mapped_column(Float)

    # Relationships
    device: Mapped["Device"] = relationship("Device", back_populates="chambers")
    sensor_readings: Mapped[List["SensorReading"]] = relationship("SensorReading", back_populates="chamber")
    goods_batches: Mapped[List["GoodsBatch"]] = relationship("GoodsBatch", back_populates="chamber")
    alerts: Mapped[List["Alert"]] = relationship("Alert", back_populates="chamber")
    current_profile: Mapped[Optional["CropProfile"]] = relationship("CropProfile", foreign_keys=[current_crop_profile_id])

    __table_args__ = (
        UniqueConstraint("device_id", "chamber_number", name="uq_chambers_device_number"),
        Index("ix_chambers_device_id", "device_id"),
    )


# ─── Sensor Readings (TimescaleDB Hypertable) ────────────────────────────────

class SensorReading(Base):
    """
    TimescaleDB hypertable partitioned by time and device.
    After creation, run:
      SELECT create_hypertable('sensor_readings', 'recorded_at');
      SELECT add_compression_policy('sensor_readings', INTERVAL '30 days');
    """
    __tablename__ = "sensor_readings"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    chamber_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("chambers.id", ondelete="CASCADE"), nullable=False)
    device_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("devices.id", ondelete="CASCADE"), nullable=False)
    recorded_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)

    # Sensor values
    temperature: Mapped[Optional[float]] = mapped_column(Float)     # °C
    humidity: Mapped[Optional[float]] = mapped_column(Float)        # %RH
    co2: Mapped[Optional[float]] = mapped_column(Float)             # ppm
    o2: Mapped[Optional[float]] = mapped_column(Float)              # %
    ethylene: Mapped[Optional[float]] = mapped_column(Float)        # ppm
    carbon_monoxide: Mapped[Optional[float]] = mapped_column(Float) # ppm
    methane: Mapped[Optional[float]] = mapped_column(Float)         # ppm

    # Computed
    health_score: Mapped[Optional[float]] = mapped_column(Float)
    raw_payload: Mapped[Optional[dict]] = mapped_column(JSONB)

    chamber: Mapped["Chamber"] = relationship("Chamber", back_populates="sensor_readings")

    __table_args__ = (
        Index("ix_sensor_readings_chamber_time", "chamber_id", "recorded_at"),
        Index("ix_sensor_readings_device_time", "device_id", "recorded_at"),
    )


# ─── Crop Profiles ────────────────────────────────────────────────────────────

class CropProfile(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "crop_profiles"

    company_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("companies.id", ondelete="SET NULL"))
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    category: Mapped[str] = mapped_column(String(100), nullable=False)  # fruit | vegetable | flower | custom
    variety: Mapped[Optional[str]] = mapped_column(String(255))
    profile_type: Mapped[str] = mapped_column(String(50), default="company_default")  # system | company_default | user_preset | custom
    maturity_stage: Mapped[Optional[str]] = mapped_column(String(100))
    storage_strategy: Mapped[Optional[str]] = mapped_column(String(100))
    icon_url: Mapped[Optional[str]] = mapped_column(String(500))
    is_system: Mapped[bool] = mapped_column(Boolean, default=False)  # Built-in profiles
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    # Environmental parameters
    temp_min: Mapped[Optional[float]] = mapped_column(Float)
    temp_max: Mapped[Optional[float]] = mapped_column(Float)
    temp_optimal: Mapped[Optional[float]] = mapped_column(Float)
    humidity_min: Mapped[Optional[float]] = mapped_column(Float)
    humidity_max: Mapped[Optional[float]] = mapped_column(Float)
    humidity_optimal: Mapped[Optional[float]] = mapped_column(Float)
    co2_min: Mapped[Optional[float]] = mapped_column(Float)
    co2_max: Mapped[Optional[float]] = mapped_column(Float)
    o2_min: Mapped[Optional[float]] = mapped_column(Float)
    o2_max: Mapped[Optional[float]] = mapped_column(Float)
    ethylene_max: Mapped[Optional[float]] = mapped_column(Float)
    co_max: Mapped[Optional[float]] = mapped_column(Float)
    methane_max: Mapped[Optional[float]] = mapped_column(Float)

    # Shelf life
    storage_duration_days: Mapped[Optional[int]] = mapped_column(Integer)
    shelf_life_days: Mapped[Optional[int]] = mapped_column(Integer)
    respiration_rate: Mapped[Optional[float]] = mapped_column(Float)

    # Rich content
    description: Mapped[Optional[str]] = mapped_column(Text)
    handling_notes: Mapped[Optional[str]] = mapped_column(Text)
    compliance_standards: Mapped[Optional[list]] = mapped_column(JSONB)
    sources: Mapped[Optional[list]] = mapped_column(JSONB)

    company: Mapped[Optional["Company"]] = relationship("Company", back_populates="crop_profiles")


# ─── Goods Batch (Inventory) ──────────────────────────────────────────────────

class GoodsBatch(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "goods_batches"

    chamber_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("chambers.id", ondelete="CASCADE"), nullable=False)
    crop_profile_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("crop_profiles.id"))
    added_by_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)

    name: Mapped[str] = mapped_column(String(255), nullable=False)
    batch_number: Mapped[Optional[str]] = mapped_column(String(100))
    category: Mapped[str] = mapped_column(String(100), nullable=False)  # fruit | vegetable | flower | custom
    variety: Mapped[Optional[str]] = mapped_column(String(255))
    quantity_kg: Mapped[Optional[float]] = mapped_column(Float)
    quantity_units: Mapped[Optional[int]] = mapped_column(Integer)
    unit_price: Mapped[Optional[float]] = mapped_column(Float)
    currency: Mapped[str] = mapped_column(String(10), default="INR")
    total_value: Mapped[Optional[float]] = mapped_column(Float)
    stage: Mapped[GoodsStage] = mapped_column(SAEnum(GoodsStage), default=GoodsStage.STORAGE)
    harvest_date: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    storage_date: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    expected_out_date: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    is_removed: Mapped[bool] = mapped_column(Boolean, default=False)
    removed_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    notes: Mapped[Optional[str]] = mapped_column(Text)

    # Computed
    remaining_shelf_life_days: Mapped[Optional[int]] = mapped_column(Integer)
    spoilage_risk_score: Mapped[Optional[float]] = mapped_column(Float)

    chamber: Mapped["Chamber"] = relationship("Chamber", back_populates="goods_batches")
    crop_profile: Mapped[Optional["CropProfile"]] = relationship("CropProfile")

    __table_args__ = (Index("ix_goods_batches_chamber_id", "chamber_id"),)


# ─── Alerts ───────────────────────────────────────────────────────────────────

class Alert(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "alerts"

    company_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("companies.id", ondelete="CASCADE"), nullable=False)
    device_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("devices.id", ondelete="CASCADE"), nullable=False)
    chamber_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("chambers.id", ondelete="SET NULL"))

    severity: Mapped[AlertSeverity] = mapped_column(SAEnum(AlertSeverity), nullable=False)
    status: Mapped[AlertStatus] = mapped_column(SAEnum(AlertStatus), default=AlertStatus.ACTIVE)
    alert_type: Mapped[str] = mapped_column(String(100), nullable=False)  # temperature_high | humidity_low | etc.

    # Human-readable fields
    title: Mapped[str] = mapped_column(String(500), nullable=False)
    cause: Mapped[str] = mapped_column(Text, nullable=False)
    impact: Mapped[str] = mapped_column(Text, nullable=False)
    recommended_action: Mapped[str] = mapped_column(Text, nullable=False)

    # Data context
    parameter: Mapped[Optional[str]] = mapped_column(String(50))
    current_value: Mapped[Optional[float]] = mapped_column(Float)
    threshold_value: Mapped[Optional[float]] = mapped_column(Float)
    unit: Mapped[Optional[str]] = mapped_column(String(20))

    # Lifecycle
    triggered_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    acknowledged_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    resolved_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    acknowledged_by_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"))
    resolved_by_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"))
    notification_sent: Mapped[bool] = mapped_column(Boolean, default=False)

    chamber: Mapped[Optional["Chamber"]] = relationship("Chamber", back_populates="alerts")
    device: Mapped["Device"] = relationship("Device")

    __table_args__ = (
        Index("ix_alerts_company_status", "company_id", "status"),
        Index("ix_alerts_device_id", "device_id"),
        Index("ix_alerts_triggered_at", "triggered_at"),
        Index(
            "uq_active_chamber_alerts",
            "chamber_id",
            "alert_type",
            unique=True,
            postgresql_where=text("status = 'ACTIVE'"),
        ),
        Index(
            "uq_active_device_alerts",
            "device_id",
            "alert_type",
            unique=True,
            postgresql_where=text("status = 'ACTIVE' AND chamber_id IS NULL"),
        ),
    )


# ─── Audit Logs ───────────────────────────────────────────────────────────────

class AuditLog(Base, UUIDMixin):
    __tablename__ = "audit_logs"

    company_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("companies.id", ondelete="CASCADE"), nullable=False)
    user_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"))
    device_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("devices.id", ondelete="SET NULL"))
    action: Mapped[AuditAction] = mapped_column(SAEnum(AuditAction), nullable=False)
    resource_type: Mapped[Optional[str]] = mapped_column(String(100))
    resource_id: Mapped[Optional[str]] = mapped_column(String(255))
    description: Mapped[str] = mapped_column(Text, nullable=False)
    log_metadata: Mapped[Optional[dict]] = mapped_column("metadata", JSONB)
    ip_address: Mapped[Optional[str]] = mapped_column(String(45))
    user_agent: Mapped[Optional[str]] = mapped_column(String(500))
    timestamp: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False, index=True)

    user: Mapped[Optional["User"]] = relationship("User", back_populates="audit_logs")
    device: Mapped[Optional["Device"]] = relationship("Device", back_populates="audit_logs")

    __table_args__ = (
        Index("ix_audit_logs_company_time", "company_id", "timestamp"),
        Index("ix_audit_logs_user_id", "user_id"),
    )


# ─── OTA Updates ──────────────────────────────────────────────────────────────

class OTAUpdate(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "ota_updates"

    company_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("companies.id", ondelete="SET NULL"))
    version: Mapped[str] = mapped_column(String(50), nullable=False, unique=True)
    description: Mapped[Optional[str]] = mapped_column(Text)
    changelog: Mapped[Optional[str]] = mapped_column(Text)
    firmware_url: Mapped[str] = mapped_column(String(500), nullable=False)
    checksum_sha256: Mapped[str] = mapped_column(String(64), nullable=False)
    file_size_bytes: Mapped[int] = mapped_column(BigInteger, nullable=False)
    is_mandatory: Mapped[bool] = mapped_column(Boolean, default=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    target_hardware_versions: Mapped[Optional[list]] = mapped_column(JSONB)
    min_firmware_version: Mapped[Optional[str]] = mapped_column(String(50))
    released_by_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"))

    deployments: Mapped[List["OTADeployment"]] = relationship("OTADeployment", back_populates="ota_update")


class OTADeployment(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "ota_deployments"

    ota_update_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("ota_updates.id", ondelete="CASCADE"), nullable=False)
    device_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("devices.id", ondelete="CASCADE"), nullable=False)
    status: Mapped[OTAStatus] = mapped_column(SAEnum(OTAStatus), default=OTAStatus.PENDING)
    progress_percent: Mapped[Optional[int]] = mapped_column(Integer)
    started_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    completed_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    error_message: Mapped[Optional[str]] = mapped_column(Text)
    previous_firmware_version: Mapped[Optional[str]] = mapped_column(String(50))
    rollback_available: Mapped[bool] = mapped_column(Boolean, default=True)
    initiated_by_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"))

    ota_update: Mapped["OTAUpdate"] = relationship("OTAUpdate", back_populates="deployments")
    device: Mapped["Device"] = relationship("Device", back_populates="ota_deployments")


# ─── Reports ──────────────────────────────────────────────────────────────────

class Report(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "reports"

    company_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("companies.id", ondelete="CASCADE"), nullable=False)
    generated_by_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    report_type: Mapped[ReportType] = mapped_column(SAEnum(ReportType), nullable=False)
    format: Mapped[ReportFormat] = mapped_column(SAEnum(ReportFormat), nullable=False)
    title: Mapped[str] = mapped_column(String(500), nullable=False)
    date_from: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    date_to: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    filters: Mapped[Optional[dict]] = mapped_column(JSONB)
    file_url: Mapped[Optional[str]] = mapped_column(String(500))
    file_size_bytes: Mapped[Optional[int]] = mapped_column(BigInteger)
    is_ready: Mapped[bool] = mapped_column(Boolean, default=False)
    error_message: Mapped[Optional[str]] = mapped_column(Text)

    __table_args__ = (Index("ix_reports_company_id", "company_id"),)


# ─── Offline Sync Queue ───────────────────────────────────────────────────────

class OfflineSyncQueue(Base, UUIDMixin):
    __tablename__ = "offline_sync_queue"

    company_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    entity_type: Mapped[str] = mapped_column(String(100), nullable=False)
    entity_id: Mapped[Optional[str]] = mapped_column(String(255))
    action: Mapped[str] = mapped_column(String(50), nullable=False)  # create | update | delete
    payload: Mapped[dict] = mapped_column(JSONB, nullable=False)
    client_timestamp: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    server_timestamp: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    is_processed: Mapped[bool] = mapped_column(Boolean, default=False)
    processed_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    conflict_resolution: Mapped[Optional[str]] = mapped_column(String(50))
    error_message: Mapped[Optional[str]] = mapped_column(Text)
    retry_count: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (
        Index("ix_offline_sync_unprocessed", "is_processed", "company_id"),
    )


# ─── Diagnostics Results ─────────────────────────────────────────────────────

class DiagnosticResult(Base, UUIDMixin):
    __tablename__ = "diagnostic_results"

    device_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("devices.id", ondelete="CASCADE"), nullable=False)
    initiated_by_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"))
    run_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    results: Mapped[dict] = mapped_column(JSONB, nullable=False)
    overall_status: Mapped[str] = mapped_column(String(50), nullable=False)  # pass | fail | warning
    notes: Mapped[Optional[str]] = mapped_column(Text)

    device: Mapped["Device"] = relationship("Device")
