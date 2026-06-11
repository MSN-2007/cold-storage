"""
ColdSmart Devices Router
Full device management: pairing, QR, CRUD, status, ownership transfer
"""
import io
import qrcode
import base64
from typing import Optional
from uuid import UUID, uuid4

from fastapi import APIRouter, HTTPException, UploadFile, File, BackgroundTasks, status
from sqlalchemy import select, update, func
from sqlalchemy.orm import selectinload
from pydantic import BaseModel, Field

from app.database import get_db
from app.models import (
    Device, DeviceUser, Chamber, AuditLog, AuditAction,
    DeviceStatus, Alert, AlertStatus, SensorReading
)
from app.core.security import generate_device_pairing_secret, generate_mqtt_credentials
from app.dependencies import DB, CurrentUser, Paginate, require, rate_limit
from app.mqtt.broker_client import mqtt_client

router = APIRouter(prefix="/devices", tags=["Devices"])


# ─── Schemas ──────────────────────────────────────────────────────────────────

class DeviceCreateRequest(BaseModel):
    device_id: str = Field(min_length=4, max_length=100, description="Hardware device ID")
    name: str = Field(min_length=1, max_length=255)
    description: Optional[str] = None
    location: Optional[str] = None
    hardware_version: Optional[str] = None
    model: Optional[str] = None


class DeviceUpdateRequest(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    location: Optional[str] = None


class ChamberCreateRequest(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    chamber_number: int = Field(ge=1)
    capacity_kg: Optional[float] = None


class ChamberParameterUpdate(BaseModel):
    target_temperature: Optional[float] = None
    target_humidity: Optional[float] = None
    target_co2: Optional[float] = None
    target_o2: Optional[float] = None
    target_ethylene: Optional[float] = None
    temp_min: Optional[float] = None
    temp_max: Optional[float] = None
    humidity_min: Optional[float] = None
    humidity_max: Optional[float] = None
    co2_min: Optional[float] = None
    co2_max: Optional[float] = None
    o2_min: Optional[float] = None
    o2_max: Optional[float] = None
    ethylene_max: Optional[float] = None
    co_max: Optional[float] = None
    methane_max: Optional[float] = None


class OwnershipTransferRequest(BaseModel):
    new_owner_user_id: UUID
    reason: Optional[str] = None


# ─── Device CRUD ──────────────────────────────────────────────────────────────

@router.get("/", summary="List all devices for the company")
async def list_devices(current_user: CurrentUser, db: DB, pagination: Paginate):
    result = await db.execute(
        select(Device)
        .where(Device.company_id == current_user.company_id, Device.is_active == True)
        .options(selectinload(Device.chambers))
        .order_by(Device.created_at.desc())
        .offset(pagination.offset)
        .limit(pagination.page_size)
    )
    devices = result.scalars().all()

    total_res = await db.execute(
        select(func.count(Device.id))
        .where(Device.company_id == current_user.company_id, Device.is_active == True)
    )
    total = total_res.scalar()

    return {
        "items": [_device_summary(d) for d in devices],
        "total": total,
        "page": pagination.page,
        "page_size": pagination.page_size,
    }


@router.post("/", summary="Register a new device (pair by Device ID)")
async def register_device(
    payload: DeviceCreateRequest,
    current_user: CurrentUser,
    db: DB,
):
    # Check device_id not already registered
    existing = await db.execute(select(Device).where(Device.device_id == payload.device_id))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Device ID already registered.")

    # Generate MQTT credentials
    mqtt_creds = generate_mqtt_credentials(payload.device_id, str(current_user.company_id))

    # Generate QR code
    qr_data = f"coldsmart://pair?id={payload.device_id}&secret={generate_device_pairing_secret()}"
    qr_img = qrcode.make(qr_data)
    buffer = io.BytesIO()
    qr_img.save(buffer, format="PNG")
    qr_b64 = base64.b64encode(buffer.getvalue()).decode()

    device = Device(
        company_id=current_user.company_id,
        device_id=payload.device_id,
        name=payload.name,
        description=payload.description,
        location=payload.location,
        hardware_version=payload.hardware_version,
        model=payload.model,
        qr_code=qr_b64,
        status=DeviceStatus.OFFLINE,
        mqtt_credentials={
            "username": mqtt_creds["mqtt_username"],
            "password_hash": mqtt_creds["mqtt_password_hash"],
        },
    )
    db.add(device)
    await db.flush()

    # Grant owner full access
    db.add(DeviceUser(
        device_id=device.id,
        user_id=current_user.id,
        permission_level="admin",
        granted_by=current_user.id,
    ))

    # Audit
    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        device_id=device.id,
        action=AuditAction.DEVICE_PAIRED,
        description=f"Device '{payload.name}' ({payload.device_id}) registered.",
        resource_type="device",
        resource_id=str(device.id),
    ))

    return {
        "device": _device_detail(device),
        "mqtt_credentials": {
            "username": mqtt_creds["mqtt_username"],
            "password": mqtt_creds["mqtt_password"],  # Return ONCE at registration
        },
        "qr_code_base64": qr_b64,
        "message": "Device registered. Share MQTT credentials with the device firmware.",
    }


@router.get("/{device_id}", summary="Get device detail with latest sensor readings")
async def get_device(device_id: UUID, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(Device)
        .where(Device.id == device_id, Device.company_id == current_user.company_id)
        .options(selectinload(Device.chambers))
    )
    device = result.scalar_one_or_none()
    if not device:
        raise HTTPException(status_code=404, detail="Device not found.")

    return _device_detail(device)


@router.put("/{device_id}", summary="Update device metadata")
async def update_device(device_id: UUID, payload: DeviceUpdateRequest, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(Device).where(Device.id == device_id, Device.company_id == current_user.company_id)
    )
    device = result.scalar_one_or_none()
    if not device:
        raise HTTPException(status_code=404, detail="Device not found.")

    if payload.name is not None:
        device.name = payload.name
    if payload.description is not None:
        device.description = payload.description
    if payload.location is not None:
        device.location = payload.location

    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        device_id=device.id,
        action=AuditAction.DEVICE_ACCESS,
        description=f"Device '{device.name}' metadata updated.",
        resource_type="device",
        resource_id=str(device.id),
    ))

    return _device_detail(device)


@router.delete("/{device_id}", summary="Deactivate a device")
async def deactivate_device(device_id: UUID, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(Device).where(Device.id == device_id, Device.company_id == current_user.company_id)
    )
    device = result.scalar_one_or_none()
    if not device:
        raise HTTPException(status_code=404, detail="Device not found.")

    device.is_active = False
    return {"message": "Device deactivated."}


# ─── Chamber Management ───────────────────────────────────────────────────────

@router.post("/{device_id}/chambers", summary="Add a chamber to a device")
async def add_chamber(device_id: UUID, payload: ChamberCreateRequest, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(Device).where(Device.id == device_id, Device.company_id == current_user.company_id)
    )
    device = result.scalar_one_or_none()
    if not device:
        raise HTTPException(status_code=404, detail="Device not found.")

    chamber = Chamber(
        device_id=device.id,
        name=payload.name,
        chamber_number=payload.chamber_number,
        capacity_kg=payload.capacity_kg,
    )
    db.add(chamber)
    return {"message": "Chamber added.", "chamber_id": str(chamber.id)}


@router.put("/{device_id}/chambers/{chamber_id}/parameters", summary="Update chamber environmental parameters")
async def update_chamber_parameters(
    device_id: UUID,
    chamber_id: UUID,
    payload: ChamberParameterUpdate,
    current_user: CurrentUser,
    db: DB,
    background_tasks: BackgroundTasks,
):
    result = await db.execute(
        select(Chamber).where(Chamber.id == chamber_id, Chamber.device_id == device_id)
    )
    chamber = result.scalar_one_or_none()
    if not chamber:
        raise HTTPException(status_code=404, detail="Chamber not found.")

    # Apply updates
    for field, value in payload.model_dump(exclude_none=True).items():
        setattr(chamber, field, value)

    # Log parameter change
    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        device_id=device_id,
        action=AuditAction.PARAM_CHANGE,
        description=f"Parameters updated for chamber '{chamber.name}'.",
        log_metadata=payload.model_dump(exclude_none=True),
        resource_type="chamber",
        resource_id=str(chamber_id),
    ))

    # Push parameter update to device via MQTT
    device_res = await db.execute(select(Device).where(Device.id == device_id))
    device = device_res.scalar_one()
    background_tasks.add_task(
        mqtt_client.send_command,
        str(current_user.company_id),
        device.device_id,
        {"action": "update_parameters", "chamber_number": chamber.chamber_number, **payload.model_dump(exclude_none=True)},
    )

    return {"message": "Parameters updated and pushed to device."}


# ─── Device Ownership Transfer ────────────────────────────────────────────────

@router.post(
    "/{device_id}/transfer-ownership",
    summary="Transfer device ownership",
    dependencies=[rate_limit(5, 60, "device_transfer_ip")],
)
async def transfer_ownership(
    device_id: UUID,
    payload: OwnershipTransferRequest,
    current_user: CurrentUser,
    db: DB,
):
    from app.models import User, UserRole
    # Only owners and above can transfer
    if current_user.role not in (UserRole.SUPER_ADMIN, UserRole.OWNER):
        raise HTTPException(status_code=403, detail="Only owners can transfer device ownership.")

    result = await db.execute(
        select(Device).where(Device.id == device_id, Device.company_id == current_user.company_id)
    )
    device = result.scalar_one_or_none()
    if not device:
        raise HTTPException(status_code=404, detail="Device not found.")

    # Verify new owner exists in company
    new_owner_res = await db.execute(
        select(User).where(User.id == payload.new_owner_user_id, User.company_id == current_user.company_id)
    )
    new_owner = new_owner_res.scalar_one_or_none()
    if not new_owner:
        raise HTTPException(status_code=404, detail="New owner not found in your company.")

    # Update or insert DeviceUser permissions for new owner (admin level)
    new_du_res = await db.execute(
        select(DeviceUser).where(DeviceUser.device_id == device.id, DeviceUser.user_id == new_owner.id)
    )
    new_du = new_du_res.scalar_one_or_none()
    if new_du:
        new_du.permission_level = "admin"
    else:
        db.add(DeviceUser(
            device_id=device.id,
            user_id=new_owner.id,
            permission_level="admin",
            granted_by=current_user.id,
        ))

    # Demote current user's (transferring owner's) permissions on this device to 'view'
    if current_user.id != new_owner.id:
        old_du_res = await db.execute(
            select(DeviceUser).where(DeviceUser.device_id == device.id, DeviceUser.user_id == current_user.id)
        )
        old_du = old_du_res.scalar_one_or_none()
        if old_du:
            old_du.permission_level = "view"

    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        device_id=device.id,
        action=AuditAction.DEVICE_TRANSFERRED,
        description=f"Device '{device.name}' transferred to user {new_owner.name}. Reason: {payload.reason}",
        resource_type="device",
        resource_id=str(device.id),
        log_metadata={"new_owner_id": str(new_owner.id), "reason": payload.reason},
    ))

    return {"message": f"Device ownership transferred to {new_owner.name}."}


# ─── Dashboard Stats ──────────────────────────────────────────────────────────

@router.get("/stats/summary", summary="Get fleet summary for dashboard")
async def get_fleet_summary(current_user: CurrentUser, db: DB):
    devices_res = await db.execute(
        select(Device).where(Device.company_id == current_user.company_id, Device.is_active == True)
    )
    devices = devices_res.scalars().all()

    summary = {
        "total": len(devices),
        "healthy": sum(1 for d in devices if d.status == DeviceStatus.ONLINE and (d.total_health_score or 0) >= 80),
        "warning": sum(1 for d in devices if d.status == DeviceStatus.WARNING),
        "critical": sum(1 for d in devices if d.status == DeviceStatus.CRITICAL),
        "offline": sum(1 for d in devices if d.status == DeviceStatus.OFFLINE),
        "maintenance": sum(1 for d in devices if d.status == DeviceStatus.MAINTENANCE),
    }

    # Active alerts count
    alerts_res = await db.execute(
        select(func.count(Alert.id)).where(
            Alert.company_id == current_user.company_id,
            Alert.status == AlertStatus.ACTIVE,
        )
    )
    summary["active_alerts"] = alerts_res.scalar()

    return summary


# ─── Helpers ──────────────────────────────────────────────────────────────────

def _device_summary(device: Device) -> dict:
    return {
        "id": str(device.id),
        "device_id": device.device_id,
        "name": device.name,
        "location": device.location,
        "status": device.status.value,
        "last_seen_at": device.last_seen_at.isoformat() if device.last_seen_at else None,
        "firmware_version": device.firmware_version,
        "health_score": device.total_health_score,
        "chamber_count": len(device.chambers) if device.chambers else 0,
    }


def _device_detail(device: Device) -> dict:
    data = _device_summary(device)
    data.update({
        "description": device.description,
        "model": device.model,
        "hardware_version": device.hardware_version,
        "mac_address": device.mac_address,
        "wifi_ssid": device.wifi_ssid,
        "signal_strength": device.signal_strength,
        "bluetooth_id": device.bluetooth_id,
        "chambers": [
            {
                "id": str(c.id),
                "name": c.name,
                "chamber_number": c.chamber_number,
                "capacity_kg": c.capacity_kg,
                "health_score": c.health_score,
                "target_temperature": c.target_temperature,
                "target_humidity": c.target_humidity,
                "is_active": c.is_active,
            }
            for c in (device.chambers or [])
        ],
    })
    return data
