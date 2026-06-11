"""
ColdSmart OTA Firmware Update Router
Upload, deploy, rollback, and track firmware updates
"""
import hashlib
import io
from datetime import datetime, timezone
from typing import Optional, List
from uuid import UUID

from fastapi import APIRouter, HTTPException, UploadFile, File, Form, BackgroundTasks
from sqlalchemy import select
from pydantic import BaseModel

from app.models import (
    OTAUpdate, OTADeployment, OTAStatus, Device, AuditLog, AuditAction, UserRole
)
from app.dependencies import DB, CurrentUser, Paginate, require
from app.core.security import sign_ota_payload
from app.mqtt.broker_client import mqtt_client
from app.config import settings

router = APIRouter(prefix="/ota", tags=["OTA Updates"])


# ─── Schemas ──────────────────────────────────────────────────────────────────

class DeployRequest(BaseModel):
    device_ids: List[UUID]
    is_mandatory: bool = False


class RollbackRequest(BaseModel):
    reason: Optional[str] = None


# ─── Routes ───────────────────────────────────────────────────────────────────

@router.post("/upload", summary="Upload a new firmware version")
async def upload_firmware(
    version: str = Form(...),
    description: str = Form(""),
    changelog: str = Form(""),
    is_mandatory: bool = Form(False),
    target_hardware_versions: str = Form("[]"),
    min_firmware_version: Optional[str] = Form(None),
    firmware_file: UploadFile = File(...),
    current_user: CurrentUser = None,
    db: DB = None,
):
    # Only managers and above can upload firmware
    if current_user.role not in (UserRole.SUPER_ADMIN, UserRole.OWNER, UserRole.MANAGER):
        raise HTTPException(status_code=403, detail="Insufficient permissions.")

    # Read firmware file
    content = await firmware_file.read()
    file_size = len(content)

    # Compute SHA256 checksum
    sha256 = hashlib.sha256(content).hexdigest()

    # Check version doesn't already exist
    existing = await db.execute(select(OTAUpdate).where(OTAUpdate.version == version))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail=f"Firmware version {version} already exists.")

    # Upload to MinIO
    import boto3
    from botocore.config import Config

    s3 = boto3.client(
        "s3",
        endpoint_url=f"http{'s' if settings.MINIO_SECURE else ''}://{settings.MINIO_ENDPOINT}",
        aws_access_key_id=settings.MINIO_ACCESS_KEY,
        aws_secret_access_key=settings.MINIO_SECRET_KEY,
        config=Config(signature_version="s3v4"),
    )

    object_key = f"firmware/{version}/firmware_{version}.bin"
    try:
        s3.put_object(
            Bucket=settings.MINIO_BUCKET_FIRMWARE,
            Key=object_key,
            Body=content,
            ContentType="application/octet-stream",
            Metadata={
                "version": version,
                "sha256": sha256,
                "uploaded_by": str(current_user.id),
            },
        )
        firmware_url = f"{settings.MINIO_ENDPOINT}/{settings.MINIO_BUCKET_FIRMWARE}/{object_key}"
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Storage upload failed: {str(e)}")

    import json
    ota = OTAUpdate(
        company_id=current_user.company_id,
        version=version,
        description=description,
        changelog=changelog,
        firmware_url=firmware_url,
        checksum_sha256=sha256,
        file_size_bytes=file_size,
        is_mandatory=is_mandatory,
        is_active=True,
        target_hardware_versions=json.loads(target_hardware_versions),
        min_firmware_version=min_firmware_version,
        released_by_id=current_user.id,
    )
    db.add(ota)

    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        action=AuditAction.FIRMWARE_UPDATE,
        description=f"Firmware v{version} uploaded ({file_size} bytes, SHA256: {sha256[:16]}...)",
        resource_type="ota_update",
        resource_id=str(ota.id) if hasattr(ota, 'id') else None,
    ))

    return {
        "message": "Firmware uploaded successfully.",
        "version": version,
        "file_size_bytes": file_size,
        "checksum_sha256": sha256,
        "firmware_url": firmware_url,
    }


@router.get("/", summary="List all firmware versions")
async def list_firmware(current_user: CurrentUser, db: DB, pagination: Paginate):
    from sqlalchemy import select
    result = await db.execute(
        select(OTAUpdate)
        .where(OTAUpdate.is_active == True)
        .order_by(OTAUpdate.created_at.desc())
        .offset(pagination.offset)
        .limit(pagination.page_size)
    )
    updates = result.scalars().all()

    return {
        "items": [
            {
                "id": str(u.id),
                "version": u.version,
                "description": u.description,
                "changelog": u.changelog,
                "file_size_bytes": u.file_size_bytes,
                "checksum_sha256": u.checksum_sha256,
                "is_mandatory": u.is_mandatory,
                "created_at": u.created_at.isoformat(),
            }
            for u in updates
        ]
    }


def is_downgrade(current_v: Optional[str], target_v: str) -> bool:
    """Returns True if target_v is older/lower than current_v using semver parsing."""
    if not current_v:
        return False
    try:
        def parse_to_tuple(v_str: str) -> tuple[int, ...]:
            cleaned = v_str.lstrip("vV").split("-")[0]
            return tuple(int(x) for x in cleaned.split(".") if x.isdigit())
        curr_parts = parse_to_tuple(current_v)
        targ_parts = parse_to_tuple(target_v)
        return targ_parts < curr_parts
    except Exception:
        return target_v != current_v


@router.post("/{ota_id}/deploy", summary="Deploy firmware to selected devices")
async def deploy_firmware(
    ota_id: UUID,
    payload: DeployRequest,
    current_user: CurrentUser,
    db: DB,
    background_tasks: BackgroundTasks,
):
    # Load firmware
    ota_res = await db.execute(select(OTAUpdate).where(OTAUpdate.id == ota_id, OTAUpdate.is_active == True))
    ota = ota_res.scalar_one_or_none()
    if not ota:
        raise HTTPException(status_code=404, detail="Firmware not found.")

    deployments_created = []

    for device_id in payload.device_ids:
        # Verify device
        dev_res = await db.execute(
            select(Device).where(Device.id == device_id, Device.company_id == current_user.company_id)
        )
        device = dev_res.scalar_one_or_none()
        if not device:
            continue

        # Check for firmware downgrade
        if device.firmware_version and is_downgrade(device.firmware_version, ota.version):
            raise HTTPException(
                status_code=400,
                detail=f"Cannot deploy v{ota.version} to device {device.name} as it is a downgrade from current v{device.firmware_version}."
            )

        # Create deployment record
        deployment = OTADeployment(
            ota_update_id=ota.id,
            device_id=device.id,
            status=OTAStatus.PENDING,
            previous_firmware_version=device.firmware_version,
            initiated_by_id=current_user.id,
        )
        db.add(deployment)
        deployments_created.append(device)

        # Sign the OTA payload for device verification
        signature = sign_ota_payload(ota.firmware_url, ota.version, ota.checksum_sha256)

        # Generate a pre-signed URL (1 hour expiry)
        # In production this would use MinIO presigned URLs
        signed_url = ota.firmware_url  # Simplified for now

        # Trigger OTA via MQTT (background to not block response)
        background_tasks.add_task(
            mqtt_client.trigger_ota,
            str(current_user.company_id),
            device.device_id,
            {
                "ota_id": str(ota.id),
                "version": ota.version,
                "firmware_url": signed_url,
                "checksum_sha256": ota.checksum_sha256,
                "signature": signature,
                "file_size_bytes": ota.file_size_bytes,
                "is_mandatory": payload.is_mandatory,
            },
        )

        db.add(AuditLog(
            company_id=current_user.company_id,
            user_id=current_user.id,
            device_id=device.id,
            action=AuditAction.FIRMWARE_UPDATE,
            description=f"OTA v{ota.version} deployment initiated for device {device.name}.",
            resource_type="ota_deployment",
        ))

    return {
        "message": f"OTA deployment initiated for {len(deployments_created)} device(s).",
        "version": ota.version,
        "devices": [str(d.id) for d in deployments_created],
    }


@router.get("/devices/{device_id}/status", summary="Get OTA deployment status for a device")
async def get_device_ota_status(device_id: UUID, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(OTADeployment, OTAUpdate)
        .join(OTAUpdate, OTADeployment.ota_update_id == OTAUpdate.id)
        .where(OTADeployment.device_id == device_id)
        .order_by(OTADeployment.created_at.desc())
        .limit(10)
    )
    rows = result.all()

    return {
        "device_id": str(device_id),
        "deployments": [
            {
                "id": str(dep.id),
                "version": upd.version,
                "status": dep.status.value,
                "progress_percent": dep.progress_percent,
                "started_at": dep.started_at.isoformat() if dep.started_at else None,
                "completed_at": dep.completed_at.isoformat() if dep.completed_at else None,
                "error_message": dep.error_message,
                "rollback_available": dep.rollback_available,
                "previous_version": dep.previous_firmware_version,
            }
            for dep, upd in rows
        ],
    }


@router.post("/deployments/{deployment_id}/rollback", summary="Rollback to previous firmware")
async def rollback_firmware(
    deployment_id: UUID,
    payload: RollbackRequest,
    current_user: CurrentUser,
    db: DB,
    background_tasks: BackgroundTasks,
):
    dep_res = await db.execute(
        select(OTADeployment)
        .join(Device, OTADeployment.device_id == Device.id)
        .where(OTADeployment.id == deployment_id, Device.company_id == current_user.company_id)
    )
    deployment = dep_res.scalar_one_or_none()
    if not deployment:
        raise HTTPException(status_code=404, detail="Deployment not found.")
    if not deployment.rollback_available:
        raise HTTPException(status_code=400, detail="Rollback not available for this deployment.")

    dev_res = await db.execute(select(Device).where(Device.id == deployment.device_id))
    device = dev_res.scalar_one()

    # Send rollback command via MQTT
    background_tasks.add_task(
        mqtt_client.send_command,
        str(current_user.company_id),
        device.device_id,
        {
            "action": "rollback",
            "deployment_id": str(deployment_id),
            "target_version": deployment.previous_firmware_version,
            "reason": payload.reason,
        },
    )

    deployment.rollback_available = False
    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        device_id=device.id,
        action=AuditAction.FIRMWARE_UPDATE,
        description=f"OTA rollback initiated. Reason: {payload.reason}",
        resource_type="ota_deployment",
        resource_id=str(deployment_id),
    ))

    return {"message": "Rollback initiated.", "target_version": deployment.previous_firmware_version}
