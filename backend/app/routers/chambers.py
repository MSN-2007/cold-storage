"""
ColdSmart Chambers Router
Chamber configuration, CRUD, and crop profile assignment
"""
from typing import Optional, List
from uuid import UUID

from fastapi import APIRouter, HTTPException, BackgroundTasks, status
from sqlalchemy import select, update, func
from sqlalchemy.orm import selectinload
from pydantic import BaseModel, Field

from app.database import get_db
from app.models import (
    Device, Chamber, CropProfile, AuditLog, AuditAction,
    GoodsBatch, GoodsStage
)
from app.dependencies import DB, CurrentUser, Paginate
from app.mqtt.broker_client import mqtt_client

router = APIRouter(prefix="/chambers", tags=["Chambers"])


# ─── Schemas ──────────────────────────────────────────────────────────────────

class ChamberCreateRequest(BaseModel):
    device_id: UUID
    name: str = Field(min_length=1, max_length=255)
    chamber_number: int = Field(ge=1)
    capacity_kg: Optional[float] = None
    capacity_units: Optional[int] = None


class ChamberUpdateRequest(BaseModel):
    name: Optional[str] = None
    capacity_kg: Optional[float] = None
    capacity_units: Optional[int] = None
    is_active: Optional[bool] = None


class AssignProfileRequest(BaseModel):
    crop_profile_id: Optional[UUID] = None  # None to clear profile


# ─── Chamber Endpoints ────────────────────────────────────────────────────────

@router.get("/", summary="List all chambers for the company")
async def list_chambers(
    current_user: CurrentUser,
    db: DB,
    pagination: Paginate,
    device_id: Optional[UUID] = None,
    is_active: Optional[bool] = True,
):
    query = (
        select(Chamber)
        .join(Device)
        .where(Device.company_id == current_user.company_id)
    )

    if device_id:
        query = query.where(Chamber.device_id == device_id)
    if is_active is not None:
        query = query.where(Chamber.is_active == is_active)

    result = await db.execute(
        query.options(selectinload(Chamber.current_profile))
        .order_by(Chamber.chamber_number.asc())
        .offset(pagination.offset)
        .limit(pagination.page_size)
    )
    chambers = result.scalars().all()

    total_res = await db.execute(
        select(func.count()).select_from(query.subquery())
    )
    total = total_res.scalar()

    return {
        "items": [
            {
                "id": str(c.id),
                "device_id": str(c.device_id),
                "name": c.name,
                "chamber_number": c.chamber_number,
                "capacity_kg": c.capacity_kg,
                "capacity_units": c.capacity_units,
                "is_active": c.is_active,
                "health_score": c.health_score,
                "current_crop_profile": {
                    "id": str(c.current_profile.id),
                    "name": c.current_profile.name,
                    "category": c.current_profile.category,
                } if c.current_profile else None,
                "targets": {
                    "temperature": c.target_temperature,
                    "humidity": c.target_humidity,
                    "co2": c.target_co2,
                    "o2": c.target_o2,
                    "ethylene": c.target_ethylene,
                }
            }
            for c in chambers
        ],
        "total": total,
        "page": pagination.page,
        "page_size": pagination.page_size,
    }


@router.post("/", summary="Create a new chamber on a device", status_code=status.HTTP_201_CREATED)
async def create_chamber(payload: ChamberCreateRequest, current_user: CurrentUser, db: DB):
    # Verify device belongs to user's company
    dev_res = await db.execute(
        select(Device).where(Device.id == payload.device_id, Device.company_id == current_user.company_id)
    )
    device = dev_res.scalar_one_or_none()
    if not device:
        raise HTTPException(status_code=404, detail="Device not found.")

    # Check for unique chamber_number on this device
    existing = await db.execute(
        select(Chamber).where(Chamber.device_id == payload.device_id, Chamber.chamber_number == payload.chamber_number)
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail=f"Chamber number {payload.chamber_number} already exists on this device.")

    chamber = Chamber(
        device_id=payload.device_id,
        name=payload.name,
        chamber_number=payload.chamber_number,
        capacity_kg=payload.capacity_kg,
        capacity_units=payload.capacity_units,
        is_active=True,
    )
    db.add(chamber)
    await db.flush()

    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        device_id=device.id,
        action=AuditAction.PARAM_CHANGE,
        description=f"Chamber '{payload.name}' (#{payload.chamber_number}) created.",
        resource_type="chamber",
        resource_id=str(chamber.id),
    ))
    await db.commit()

    return {"message": "Chamber created successfully.", "id": str(chamber.id)}


@router.get("/{chamber_id}", summary="Get chamber detail including active inventory")
async def get_chamber(chamber_id: UUID, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(Chamber)
        .join(Device)
        .where(Chamber.id == chamber_id, Device.company_id == current_user.company_id)
        .options(selectinload(Chamber.current_profile))
    )
    chamber = result.scalar_one_or_none()
    if not chamber:
        raise HTTPException(status_code=404, detail="Chamber not found.")

    # Fetch active goods batches in this chamber
    batches_res = await db.execute(
        select(GoodsBatch)
        .where(GoodsBatch.chamber_id == chamber_id, GoodsBatch.is_removed == False)
    )
    batches = batches_res.scalars().all()

    return {
        "id": str(chamber.id),
        "device_id": str(chamber.device_id),
        "name": chamber.name,
        "chamber_number": chamber.chamber_number,
        "capacity_kg": chamber.capacity_kg,
        "capacity_units": chamber.capacity_units,
        "is_active": chamber.is_active,
        "health_score": chamber.health_score,
        "current_crop_profile": {
            "id": str(chamber.current_profile.id),
            "name": chamber.current_profile.name,
            "category": chamber.current_profile.category,
            "temp_optimal": chamber.current_profile.temp_optimal,
            "humidity_optimal": chamber.current_profile.humidity_optimal,
        } if chamber.current_profile else None,
        "targets": {
            "temperature": chamber.target_temperature,
            "humidity": chamber.target_humidity,
            "co2": chamber.target_co2,
            "o2": chamber.target_o2,
            "ethylene": chamber.target_ethylene,
            "co": chamber.target_co,
            "methane": chamber.target_methane,
        },
        "limits": {
            "temp_min": chamber.temp_min,
            "temp_max": chamber.temp_max,
            "humidity_min": chamber.humidity_min,
            "humidity_max": chamber.humidity_max,
            "co2_min": chamber.co2_min,
            "co2_max": chamber.co2_max,
            "o2_min": chamber.o2_min,
            "o2_max": chamber.o2_max,
            "ethylene_max": chamber.ethylene_max,
        },
        "active_inventory": [
            {
                "id": str(b.id),
                "name": b.name,
                "batch_number": b.batch_number,
                "quantity_kg": b.quantity_kg,
                "stage": b.stage.value,
                "remaining_shelf_life_days": b.remaining_shelf_life_days,
                "spoilage_risk_score": b.spoilage_risk_score,
            }
            for b in batches
        ],
    }


@router.put("/{chamber_id}", summary="Update chamber configuration")
async def update_chamber(chamber_id: UUID, payload: ChamberUpdateRequest, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(Chamber)
        .join(Device)
        .where(Chamber.id == chamber_id, Device.company_id == current_user.company_id)
    )
    chamber = result.scalar_one_or_none()
    if not chamber:
        raise HTTPException(status_code=404, detail="Chamber not found.")

    for field, value in payload.model_dump(exclude_none=True).items():
        setattr(chamber, field, value)

    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        device_id=chamber.device_id,
        action=AuditAction.PARAM_CHANGE,
        description=f"Chamber '{chamber.name}' metadata updated.",
        resource_type="chamber",
        resource_id=str(chamber.id),
    ))
    await db.commit()
    return {"message": "Chamber updated successfully."}


@router.post("/{chamber_id}/assign-profile", summary="Assign crop profile and automatically apply target climate parameters")
async def assign_crop_profile(
    chamber_id: UUID,
    payload: AssignProfileRequest,
    current_user: CurrentUser,
    db: DB,
    background_tasks: BackgroundTasks,
):
    result = await db.execute(
        select(Chamber)
        .join(Device)
        .where(Chamber.id == chamber_id, Device.company_id == current_user.company_id)
        .options(selectinload(Chamber.device))
    )
    chamber = result.scalar_one_or_none()
    if not chamber:
        raise HTTPException(status_code=404, detail="Chamber not found.")

    if not payload.crop_profile_id:
        # Clear profile and targets
        chamber.current_crop_profile_id = None
        desc = f"Cleared crop profile for chamber '{chamber.name}'."
    else:
        # Verify profile is system-wide or owned by this company
        prof_res = await db.execute(
            select(CropProfile).where(
                CropProfile.id == payload.crop_profile_id,
                (CropProfile.is_system == True) | (CropProfile.company_id == current_user.company_id)
            )
        )
        profile = prof_res.scalar_one_or_none()
        if not profile:
            raise HTTPException(status_code=404, detail="Crop profile not found.")

        chamber.current_crop_profile_id = profile.id
        
        # Apply optimal values as targets
        chamber.target_temperature = profile.temp_optimal
        chamber.target_humidity = profile.humidity_optimal
        chamber.target_co2 = profile.co2_max  # Default target to safety upper bound or middle range if not specified
        
        # Apply safety ranges
        chamber.temp_min = profile.temp_min
        chamber.temp_max = profile.temp_max
        chamber.humidity_min = profile.humidity_min
        chamber.humidity_max = profile.humidity_max
        chamber.co2_min = profile.co2_min
        chamber.co2_max = profile.co2_max
        chamber.o2_min = profile.o2_min
        chamber.o2_max = profile.o2_max
        chamber.ethylene_max = profile.ethylene_max
        chamber.co_max = profile.co_max
        chamber.methane_max = profile.methane_max

        desc = f"Assigned crop profile '{profile.name}' to chamber '{chamber.name}' and loaded climate targets."

    # Log audit trail
    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        device_id=chamber.device_id,
        action=AuditAction.PARAM_CHANGE,
        description=desc,
        resource_type="chamber",
        resource_id=str(chamber_id),
    ))
    await db.flush()

    # Send parameter update to device firmware via MQTT
    device = chamber.device
    mqtt_payload = {
        "action": "update_parameters",
        "chamber_number": chamber.chamber_number,
        "target_temperature": chamber.target_temperature,
        "target_humidity": chamber.target_humidity,
        "temp_min": chamber.temp_min,
        "temp_max": chamber.temp_max,
        "humidity_min": chamber.humidity_min,
        "humidity_max": chamber.humidity_max,
    }
    
    background_tasks.add_task(
        mqtt_client.send_command,
        str(current_user.company_id),
        device.device_id,
        mqtt_payload,
    )
    
    await db.commit()

    return {
        "message": "Crop profile assigned and climate parameters pushed to device.",
        "targets": {
            "temperature": chamber.target_temperature,
            "humidity": chamber.target_humidity,
        }
    }
