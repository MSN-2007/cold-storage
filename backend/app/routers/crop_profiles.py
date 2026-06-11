"""
ColdSmart Crop Profiles Router
Browse system profiles, create custom profiles, search by produce name
"""
from typing import Optional, List
from uuid import UUID

from fastapi import APIRouter, HTTPException, Query
from sqlalchemy import select, func, or_
from pydantic import BaseModel, Field

from app.models import CropProfile, AuditLog, AuditAction, UserRole
from app.dependencies import DB, CurrentUser, Paginate

router = APIRouter(prefix="/crop-profiles", tags=["Crop Profiles"])


# ─── Schemas ──────────────────────────────────────────────────────────────────

class CropProfileCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    category: str = Field(pattern="^(fruit|vegetable|flower|custom)$")
    variety: Optional[str] = None
    maturity_stage: Optional[str] = None
    storage_strategy: Optional[str] = None
    temp_min: Optional[float] = None
    temp_max: Optional[float] = None
    temp_optimal: Optional[float] = None
    humidity_min: Optional[float] = None
    humidity_max: Optional[float] = None
    humidity_optimal: Optional[float] = None
    co2_min: Optional[float] = None
    co2_max: Optional[float] = None
    o2_min: Optional[float] = None
    o2_max: Optional[float] = None
    ethylene_max: Optional[float] = None
    co_max: Optional[float] = None
    methane_max: Optional[float] = None
    storage_duration_days: Optional[int] = Field(None, ge=1)
    shelf_life_days: Optional[int] = Field(None, ge=1)
    description: Optional[str] = None
    handling_notes: Optional[str] = None


# ─── Routes ───────────────────────────────────────────────────────────────────

@router.get("/", summary="List all crop profiles (system + company)")
async def list_profiles(
    current_user: CurrentUser,
    db: DB,
    pagination: Paginate,
    category: Optional[str] = Query(None, pattern="^(fruit|vegetable|flower|custom)$"),
    profile_type: Optional[str] = Query(None),
    search: Optional[str] = Query(None, description="Search by name or variety"),
):
    query = select(CropProfile).where(
        or_(
            CropProfile.is_system == True,
            CropProfile.company_id == current_user.company_id,
        ),
        CropProfile.is_active == True,
    )

    if category:
        query = query.where(CropProfile.category == category)
    if profile_type:
        query = query.where(CropProfile.profile_type == profile_type)
    if search:
        query = query.where(
            or_(
                CropProfile.name.ilike(f"%{search}%"),
                CropProfile.variety.ilike(f"%{search}%"),
            )
        )

    total_res = await db.execute(select(func.count()).select_from(query.subquery()))
    total = total_res.scalar()

    result = await db.execute(
        query.order_by(CropProfile.is_system.desc(), CropProfile.name.asc())
        .offset(pagination.offset)
        .limit(pagination.page_size)
    )
    profiles = result.scalars().all()

    return {
        "items": [_profile_out(p) for p in profiles],
        "total": total,
        "page": pagination.page,
        "page_size": pagination.page_size,
    }


@router.post("/", summary="Create a custom crop profile")
async def create_profile(payload: CropProfileCreate, current_user: CurrentUser, db: DB):
    profile = CropProfile(
        company_id=current_user.company_id,
        profile_type="custom",
        is_system=False,
        **payload.model_dump(),
    )
    db.add(profile)
    await db.flush()

    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        action=AuditAction.PARAM_CHANGE,
        description=f"Custom crop profile created: {payload.name}",
        resource_type="crop_profile",
        resource_id=str(profile.id),
    ))

    return {"message": "Crop profile created.", "profile": _profile_out(profile)}


@router.get("/{profile_id}", summary="Get crop profile detail")
async def get_profile(profile_id: UUID, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(CropProfile).where(
            CropProfile.id == profile_id,
            CropProfile.is_active == True,
            or_(
                CropProfile.is_system == True,
                CropProfile.company_id == current_user.company_id,
            ),
        )
    )
    profile = result.scalar_one_or_none()
    if not profile:
        raise HTTPException(status_code=404, detail="Crop profile not found.")

    return _profile_out(profile, full=True)


@router.put("/{profile_id}", summary="Update a custom crop profile")
async def update_profile(
    profile_id: UUID,
    payload: CropProfileCreate,
    current_user: CurrentUser,
    db: DB,
):
    result = await db.execute(
        select(CropProfile).where(
            CropProfile.id == profile_id,
            CropProfile.company_id == current_user.company_id,
            CropProfile.is_system == False,
        )
    )
    profile = result.scalar_one_or_none()
    if not profile:
        raise HTTPException(status_code=404, detail="Custom profile not found.")

    for field, value in payload.model_dump(exclude_none=True).items():
        setattr(profile, field, value)

    return {"message": "Profile updated.", "profile": _profile_out(profile)}


@router.delete("/{profile_id}", summary="Delete a custom crop profile")
async def delete_profile(profile_id: UUID, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(CropProfile).where(
            CropProfile.id == profile_id,
            CropProfile.company_id == current_user.company_id,
            CropProfile.is_system == False,
        )
    )
    profile = result.scalar_one_or_none()
    if not profile:
        raise HTTPException(status_code=404, detail="Custom profile not found.")

    profile.is_active = False
    return {"message": "Profile deleted."}


@router.get("/categories/summary", summary="Grouped profile count by category")
async def get_categories_summary(current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(CropProfile.category, func.count(CropProfile.id).label("count"))
        .where(
            CropProfile.is_active == True,
            or_(CropProfile.is_system == True, CropProfile.company_id == current_user.company_id),
        )
        .group_by(CropProfile.category)
    )
    rows = result.all()
    return {row.category: row.count for row in rows}


# ─── Helper ───────────────────────────────────────────────────────────────────

def _profile_out(p: CropProfile, full: bool = False) -> dict:
    out = {
        "id": str(p.id),
        "name": p.name,
        "category": p.category,
        "variety": p.variety,
        "profile_type": p.profile_type,
        "maturity_stage": p.maturity_stage,
        "storage_strategy": p.storage_strategy,
        "is_system": p.is_system,
        "temp_min": p.temp_min,
        "temp_max": p.temp_max,
        "temp_optimal": p.temp_optimal,
        "humidity_min": p.humidity_min,
        "humidity_max": p.humidity_max,
        "storage_duration_days": p.storage_duration_days,
        "shelf_life_days": p.shelf_life_days,
    }
    if full:
        out.update({
            "humidity_optimal": p.humidity_optimal,
            "co2_min": p.co2_min,
            "co2_max": p.co2_max,
            "o2_min": p.o2_min,
            "o2_max": p.o2_max,
            "ethylene_max": p.ethylene_max,
            "co_max": p.co_max,
            "methane_max": p.methane_max,
            "respiration_rate": p.respiration_rate,
            "description": p.description,
            "handling_notes": p.handling_notes,
            "compliance_standards": p.compliance_standards,
            "sources": p.sources,
        })
    return out
