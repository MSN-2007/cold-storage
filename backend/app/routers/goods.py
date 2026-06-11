"""
ColdSmart Goods / Inventory Router
Batch tracking, shelf life, spoilage risk, value-at-risk
"""
from datetime import datetime, timezone, timedelta
from typing import Optional, List
from uuid import UUID, uuid4

from fastapi import APIRouter, HTTPException, Query
from sqlalchemy import select, func
from pydantic import BaseModel, Field

from app.database import get_db
from app.models import (
    GoodsBatch, GoodsStage, Chamber, Device,
    CropProfile, AuditLog, AuditAction,
)
from app.dependencies import DB, CurrentUser, Paginate
from app.services.crop_intelligence import calculate_shelf_life_remaining

router = APIRouter(prefix="/goods", tags=["Goods & Inventory"])


# ─── Schemas ──────────────────────────────────────────────────────────────────

class GoodsBatchCreate(BaseModel):
    chamber_id: UUID
    name: str = Field(min_length=1, max_length=255)
    category: str = Field(pattern="^(fruit|vegetable|flower|custom)$")
    variety: Optional[str] = None
    batch_number: Optional[str] = None
    quantity_kg: Optional[float] = Field(None, ge=0)
    quantity_units: Optional[int] = Field(None, ge=0)
    unit_price: Optional[float] = Field(None, ge=0)
    currency: str = "INR"
    stage: GoodsStage = GoodsStage.STORAGE
    harvest_date: Optional[datetime] = None
    storage_date: Optional[datetime] = None
    expected_out_date: Optional[datetime] = None
    crop_profile_id: Optional[UUID] = None
    notes: Optional[str] = None


class GoodsBatchUpdate(BaseModel):
    name: Optional[str] = None
    quantity_kg: Optional[float] = None
    quantity_units: Optional[int] = None
    stage: Optional[GoodsStage] = None
    notes: Optional[str] = None
    expected_out_date: Optional[datetime] = None


# ─── Routes ───────────────────────────────────────────────────────────────────

@router.get("/", summary="List all goods batches for the company")
async def list_goods(
    current_user: CurrentUser,
    db: DB,
    pagination: Paginate,
    chamber_id: Optional[UUID] = Query(None),
    category: Optional[str] = Query(None),
    stage: Optional[GoodsStage] = Query(None),
    include_removed: bool = Query(False),
):
    query = (
        select(GoodsBatch)
        .join(Chamber, GoodsBatch.chamber_id == Chamber.id)
        .join(Device, Chamber.device_id == Device.id)
        .where(Device.company_id == current_user.company_id)
    )

    if not include_removed:
        query = query.where(GoodsBatch.is_removed == False)
    if chamber_id:
        query = query.where(GoodsBatch.chamber_id == chamber_id)
    if category:
        query = query.where(GoodsBatch.category == category)
    if stage:
        query = query.where(GoodsBatch.stage == stage)

    total_res = await db.execute(select(func.count()).select_from(query.subquery()))
    total = total_res.scalar()

    result = await db.execute(
        query.order_by(GoodsBatch.storage_date.desc())
        .offset(pagination.offset)
        .limit(pagination.page_size)
    )
    batches = result.scalars().all()

    return {
        "items": [_batch_out(b) for b in batches],
        "total": total,
        "page": pagination.page,
        "page_size": pagination.page_size,
    }


@router.post("/", summary="Add a new goods batch")
async def add_goods_batch(
    payload: GoodsBatchCreate,
    current_user: CurrentUser,
    db: DB,
):
    # Verify chamber belongs to company
    chamber_res = await db.execute(
        select(Chamber)
        .join(Device, Chamber.device_id == Device.id)
        .where(Chamber.id == payload.chamber_id, Device.company_id == current_user.company_id)
    )
    chamber = chamber_res.scalar_one_or_none()
    if not chamber:
        raise HTTPException(status_code=404, detail="Chamber not found.")

    # Calculate total value
    total_value = None
    if payload.quantity_kg and payload.unit_price:
        total_value = payload.quantity_kg * payload.unit_price

    now = datetime.now(timezone.utc)
    batch = GoodsBatch(
        chamber_id=payload.chamber_id,
        crop_profile_id=payload.crop_profile_id,
        added_by_id=current_user.id,
        name=payload.name,
        batch_number=payload.batch_number or f"BATCH-{uuid4().hex[:8].upper()}",
        category=payload.category,
        variety=payload.variety,
        quantity_kg=payload.quantity_kg,
        quantity_units=payload.quantity_units,
        unit_price=payload.unit_price,
        currency=payload.currency,
        total_value=total_value,
        stage=payload.stage,
        harvest_date=payload.harvest_date,
        storage_date=payload.storage_date or now,
        expected_out_date=payload.expected_out_date,
        notes=payload.notes,
    )

    # Calculate initial shelf life if profile provided
    if payload.crop_profile_id:
        profile_res = await db.execute(
            select(CropProfile).where(CropProfile.id == payload.crop_profile_id)
        )
        profile = profile_res.scalar_one_or_none()
        if profile and profile.storage_duration_days:
            batch.remaining_shelf_life_days = calculate_shelf_life_remaining(
                harvest_date=payload.harvest_date,
                storage_date=batch.storage_date,
                storage_duration_days=profile.storage_duration_days,
                current_temp=chamber.target_temperature or (profile.temp_optimal or 5.0),
                optimal_temp=profile.temp_optimal or 5.0,
            )
            # Set crop profile on chamber if not set
            if not chamber.current_crop_profile_id:
                chamber.current_crop_profile_id = payload.crop_profile_id

    db.add(batch)
    return {"message": "Goods batch added.", "batch": _batch_out(batch)}


@router.get("/{batch_id}", summary="Get goods batch detail with shelf life")
async def get_goods_batch(batch_id: UUID, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(GoodsBatch)
        .join(Chamber, GoodsBatch.chamber_id == Chamber.id)
        .join(Device, Chamber.device_id == Device.id)
        .where(GoodsBatch.id == batch_id, Device.company_id == current_user.company_id)
    )
    batch = result.scalar_one_or_none()
    if not batch:
        raise HTTPException(status_code=404, detail="Batch not found.")

    out = _batch_out(batch)

    # Enrich with crop profile info
    if batch.crop_profile_id:
        profile_res = await db.execute(select(CropProfile).where(CropProfile.id == batch.crop_profile_id))
        profile = profile_res.scalar_one_or_none()
        if profile:
            out["crop_profile"] = {
                "id": str(profile.id),
                "name": profile.name,
                "temp_min": profile.temp_min,
                "temp_max": profile.temp_max,
                "humidity_min": profile.humidity_min,
                "humidity_max": profile.humidity_max,
                "storage_duration_days": profile.storage_duration_days,
                "shelf_life_days": profile.shelf_life_days,
            }

    return out


@router.put("/{batch_id}", summary="Update a goods batch")
async def update_goods_batch(batch_id: UUID, payload: GoodsBatchUpdate, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(GoodsBatch)
        .join(Chamber, GoodsBatch.chamber_id == Chamber.id)
        .join(Device, Chamber.device_id == Device.id)
        .where(GoodsBatch.id == batch_id, Device.company_id == current_user.company_id)
    )
    batch = result.scalar_one_or_none()
    if not batch:
        raise HTTPException(status_code=404, detail="Batch not found.")

    for field, value in payload.model_dump(exclude_none=True).items():
        setattr(batch, field, value)

    return {"message": "Batch updated.", "batch": _batch_out(batch)}


@router.post("/{batch_id}/remove", summary="Mark batch as removed from chamber")
async def remove_goods_batch(batch_id: UUID, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(GoodsBatch)
        .join(Chamber, GoodsBatch.chamber_id == Chamber.id)
        .join(Device, Chamber.device_id == Device.id)
        .where(GoodsBatch.id == batch_id, Device.company_id == current_user.company_id)
    )
    batch = result.scalar_one_or_none()
    if not batch:
        raise HTTPException(status_code=404, detail="Batch not found.")

    batch.is_removed = True
    batch.removed_at = datetime.now(timezone.utc)

    return {"message": "Batch marked as removed."}


@router.get("/summary/value-at-risk", summary="Total inventory value and spoilage risk")
async def get_value_at_risk(current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(
            func.sum(GoodsBatch.total_value).label("total_value"),
            func.count(GoodsBatch.id).label("batch_count"),
            func.sum(GoodsBatch.quantity_kg).label("total_kg"),
        )
        .join(Chamber, GoodsBatch.chamber_id == Chamber.id)
        .join(Device, Chamber.device_id == Device.id)
        .where(
            Device.company_id == current_user.company_id,
            GoodsBatch.is_removed == False,
        )
    )
    row = result.one()

    # Batches expiring in 7 days
    soon_res = await db.execute(
        select(func.count(GoodsBatch.id))
        .join(Chamber, GoodsBatch.chamber_id == Chamber.id)
        .join(Device, Chamber.device_id == Device.id)
        .where(
            Device.company_id == current_user.company_id,
            GoodsBatch.is_removed == False,
            GoodsBatch.remaining_shelf_life_days <= 7,
            GoodsBatch.remaining_shelf_life_days > 0,
        )
    )
    expiring_soon = soon_res.scalar() or 0

    return {
        "total_value": float(row.total_value or 0),
        "batch_count": row.batch_count or 0,
        "total_kg": float(row.total_kg or 0),
        "expiring_in_7_days": expiring_soon,
        "currency": "INR",
    }


# ─── Helper ───────────────────────────────────────────────────────────────────

def _batch_out(b: GoodsBatch) -> dict:
    days = b.remaining_shelf_life_days
    urgency = "safe"
    if days is not None:
        if days <= 3:
            urgency = "critical"
        elif days <= 7:
            urgency = "warning"

    return {
        "id": str(b.id),
        "chamber_id": str(b.chamber_id),
        "name": b.name,
        "batch_number": b.batch_number,
        "category": b.category,
        "variety": b.variety,
        "quantity_kg": b.quantity_kg,
        "quantity_units": b.quantity_units,
        "unit_price": b.unit_price,
        "total_value": b.total_value,
        "currency": b.currency,
        "stage": b.stage.value if b.stage else None,
        "harvest_date": b.harvest_date.isoformat() if b.harvest_date else None,
        "storage_date": b.storage_date.isoformat() if b.storage_date else None,
        "expected_out_date": b.expected_out_date.isoformat() if b.expected_out_date else None,
        "remaining_shelf_life_days": days,
        "shelf_life_urgency": urgency,
        "spoilage_risk_score": b.spoilage_risk_score,
        "is_removed": b.is_removed,
        "notes": b.notes,
        "created_at": b.created_at.isoformat() if b.created_at else None,
    }
