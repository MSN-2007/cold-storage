"""
ColdSmart Security Core
JWT, Password Hashing, RBAC, Device Pairing Security
"""
import hashlib
import secrets
import hmac
from datetime import datetime, timedelta, timezone
from typing import Optional, Dict, Any
from uuid import UUID

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.config import settings
from app.models import UserRole

# ─── Password Hashing ─────────────────────────────────────────────────────────

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(plain: str) -> str:
    return pwd_context.hash(plain)


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


def hash_token(token: str) -> str:
    """SHA-256 hash for storing refresh tokens."""
    return hashlib.sha256(token.encode()).hexdigest()


def hash_otp(otp: str) -> str:
    """HMAC-SHA256 hash for OTP storage."""
    return hmac.new(
        settings.SECRET_KEY.encode(),
        otp.encode(),
        hashlib.sha256
    ).hexdigest()


def generate_otp(length: int = 6) -> str:
    """Cryptographically secure numeric OTP."""
    return "".join([str(secrets.randbelow(10)) for _ in range(length)])


def generate_device_pairing_secret() -> str:
    """32-byte URL-safe pairing secret for device onboarding."""
    return secrets.token_urlsafe(32)


# ─── JWT Tokens ───────────────────────────────────────────────────────────────

def create_access_token(
    user_id: UUID,
    company_id: UUID,
    role: UserRole,
    extra_claims: Optional[Dict[str, Any]] = None,
) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": str(user_id),
        "company_id": str(company_id),
        "role": role.value,
        "iat": now,
        "exp": now + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES),
        "type": "access",
    }
    if extra_claims:
        payload.update(extra_claims)
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.JWT_ALGORITHM)


def create_refresh_token(user_id: UUID, session_id: UUID) -> tuple[str, str]:
    """Returns (raw_token, hashed_token). Store only the hash."""
    raw = secrets.token_urlsafe(64)
    now = datetime.now(timezone.utc)
    payload = {
        "sub": str(user_id),
        "session_id": str(session_id),
        "iat": now,
        "exp": now + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
        "type": "refresh",
    }
    signed = jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
    return signed, hash_token(signed)


def decode_token(token: str) -> Dict[str, Any]:
    """Raises JWTError on invalid/expired tokens."""
    return jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])


# ─── RBAC Permission Matrix ───────────────────────────────────────────────────

ROLE_PERMISSIONS: Dict[UserRole, set] = {
    UserRole.SUPER_ADMIN: {
        "company:read", "company:write", "company:delete",
        "user:read", "user:write", "user:delete",
        "device:read", "device:write", "device:delete",
        "device:pair", "device:transfer",
        "chamber:read", "chamber:write",
        "sensor:read", "parameter:write",
        "goods:read", "goods:write", "goods:delete",
        "alert:read", "alert:acknowledge", "alert:resolve",
        "alert:configure",
        "report:read", "report:generate",
        "audit:read",
        "ota:read", "ota:deploy", "ota:upload", "ota:rollback",
        "diagnostics:run", "calibration:run",
        "crop_profile:read", "crop_profile:write", "crop_profile:delete",
    },
    UserRole.OWNER: {
        "company:read", "company:write",
        "user:read", "user:write", "user:delete",
        "device:read", "device:write", "device:delete",
        "device:pair", "device:transfer",
        "chamber:read", "chamber:write",
        "sensor:read", "parameter:write",
        "goods:read", "goods:write", "goods:delete",
        "alert:read", "alert:acknowledge", "alert:resolve", "alert:configure",
        "report:read", "report:generate",
        "audit:read",
        "ota:read", "ota:deploy",
        "diagnostics:run",
        "crop_profile:read", "crop_profile:write",
    },
    UserRole.MANAGER: {
        "company:read",
        "user:read",
        "device:read", "device:write",
        "chamber:read", "chamber:write",
        "sensor:read", "parameter:write",
        "goods:read", "goods:write",
        "alert:read", "alert:acknowledge", "alert:resolve", "alert:configure",
        "report:read", "report:generate",
        "audit:read",
        "ota:read",
        "diagnostics:run",
        "crop_profile:read", "crop_profile:write",
    },
    UserRole.OPERATOR: {
        "company:read",
        "device:read",
        "chamber:read", "chamber:write",
        "sensor:read", "parameter:write",
        "goods:read", "goods:write",
        "alert:read", "alert:acknowledge",
        "report:read",
        "crop_profile:read",
    },
    UserRole.TECHNICIAN: {
        "device:read",
        "chamber:read",
        "sensor:read",
        "alert:read",
        "ota:read", "ota:deploy",
        "diagnostics:run", "calibration:run",
        "crop_profile:read",
    },
    UserRole.VIEWER: {
        "company:read",
        "device:read",
        "chamber:read",
        "sensor:read",
        "goods:read",
        "alert:read",
        "report:read",
        "crop_profile:read",
    },
}


def has_permission(role: UserRole, permission: str) -> bool:
    return permission in ROLE_PERMISSIONS.get(role, set())


def require_permission(role: UserRole, permission: str) -> None:
    from fastapi import HTTPException, status
    if not has_permission(role, permission):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Permission denied: {permission} required.",
        )


# ─── Device Security ──────────────────────────────────────────────────────────

def generate_mqtt_credentials(device_id: str, company_id: str) -> Dict[str, str]:
    """Generate unique MQTT credentials for a device."""
    username = f"device_{device_id}"
    password = secrets.token_urlsafe(32)
    return {
        "mqtt_username": username,
        "mqtt_password": password,
        "mqtt_password_hash": hash_password(password),
    }


def sign_ota_payload(firmware_url: str, version: str, checksum: str) -> str:
    """HMAC signature for OTA payload verification."""
    message = f"{firmware_url}:{version}:{checksum}"
    return hmac.new(
        settings.SECRET_KEY.encode(),
        message.encode(),
        hashlib.sha256,
    ).hexdigest()


def verify_ota_signature(firmware_url: str, version: str, checksum: str, signature: str) -> bool:
    expected = sign_ota_payload(firmware_url, version, checksum)
    return hmac.compare_digest(expected, signature)
