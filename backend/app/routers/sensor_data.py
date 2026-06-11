"""
ColdSmart Sensor Data Router
Historical readings, latest values, aggregated stats, live stream
"""
from datetime import datetime, timezone, timedelta
from typing import Optional, List
from uuid import UUID

from fastapi import APIRouter, HTTPException, Query
from sqlalchemy import select, func, and_
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel

from app.database import get_db
from app.models import SensorReading, Chamber, Device
from app.dependencies import DB, CurrentUser, Paginate

router = APIRouter(prefix="/sensor-data", tags=["Sensor Data"])


# ─── Schemas ──────────────────────────────────────────────────────────────────

class SensorReadingOut(BaseModel):
    recorded_at: datetime
    temperature: Optional[float]
    humidity: Optional[float]
    co2: Optional[float]
    o2: Optional[float]
    ethylene: Optional[float]
    carbon_monoxide: Optional[float]
    methane: Optional[float]
    health_score: Optional[float]


class SensorStats(BaseModel):
    parameter: str
    avg: Optional[float]
    min: Optional[float]
    max: Optional[float]
    latest: Optional[float]
    unit: str


class LatestReadingResponse(BaseModel):
    chamber_id: str
    recorded_at: Optional[datetime]
    readings: dict
    stats: List[SensorStats]


# ─── Routes ───────────────────────────────────────────────────────────────────

@router.get("/{chamber_id}/latest", summary="Get latest sensor readings for a chamber")
async def get_latest_readings(
    chamber_id: UUID,
    current_user: CurrentUser,
    db: DB,
):
    # Verify chamber belongs to user's company
    chamber = await _verify_chamber_access(chamber_id, current_user.company_id, db)

    result = await db.execute(
        select(SensorReading)
        .where(SensorReading.chamber_id == chamber_id)
        .order_by(SensorReading.recorded_at.desc())
        .limit(1)
    )
    reading = result.scalar_one_or_none()

    if not reading:
        return {"chamber_id": str(chamber_id), "recorded_at": None, "readings": {}, "stats": []}

    SENSORS = [
        ("temperature", "°C"),
        ("humidity", "%RH"),
        ("co2", "ppm"),
        ("o2", "%"),
        ("ethylene", "ppm"),
        ("carbon_monoxide", "ppm"),
        ("methane", "ppm"),
    ]

    readings_dict = {}
    stats = []
    for param, unit in SENSORS:
        value = getattr(reading, param, None)
        readings_dict[param] = value
        stats.append(SensorStats(
            parameter=param,
            avg=value,
            min=value,
            max=value,
            latest=value,
            unit=unit,
        ))

    return {
        "chamber_id": str(chamber_id),
        "recorded_at": reading.recorded_at,
        "health_score": reading.health_score,
        "readings": readings_dict,
        "stats": [s.model_dump() for s in stats],
        "chamber": {
            "name": chamber.name,
            "target_temperature": chamber.target_temperature,
            "target_humidity": chamber.target_humidity,
            "temp_min": chamber.temp_min,
            "temp_max": chamber.temp_max,
            "humidity_min": chamber.humidity_min,
            "humidity_max": chamber.humidity_max,
        },
    }


@router.get("/{chamber_id}/history", summary="Get historical sensor readings")
async def get_history(
    chamber_id: UUID,
    current_user: CurrentUser,
    db: DB,
    from_dt: Optional[datetime] = Query(None, description="Start datetime (ISO 8601)"),
    to_dt: Optional[datetime] = Query(None, description="End datetime (ISO 8601)"),
    parameter: Optional[str] = Query(None, description="Filter to single parameter"),
    limit: int = Query(500, ge=1, le=5000),
):
    await _verify_chamber_access(chamber_id, current_user.company_id, db)

    now = datetime.now(timezone.utc)
    if not from_dt:
        from_dt = now - timedelta(hours=24)
    if not to_dt:
        to_dt = now

    result = await db.execute(
        select(SensorReading)
        .where(
            SensorReading.chamber_id == chamber_id,
            SensorReading.recorded_at >= from_dt,
            SensorReading.recorded_at <= to_dt,
        )
        .order_by(SensorReading.recorded_at.asc())
        .limit(limit)
    )
    readings = result.scalars().all()

    if parameter:
        # Return single-series format for charts
        return {
            "chamber_id": str(chamber_id),
            "parameter": parameter,
            "from": from_dt.isoformat(),
            "to": to_dt.isoformat(),
            "data": [
                {
                    "t": r.recorded_at.isoformat(),
                    "v": getattr(r, parameter, None),
                }
                for r in readings
                if getattr(r, parameter, None) is not None
            ],
        }

    # Return full multi-series format
    return {
        "chamber_id": str(chamber_id),
        "from": from_dt.isoformat(),
        "to": to_dt.isoformat(),
        "count": len(readings),
        "data": [
            {
                "t": r.recorded_at.isoformat(),
                "temperature": r.temperature,
                "humidity": r.humidity,
                "co2": r.co2,
                "o2": r.o2,
                "ethylene": r.ethylene,
                "carbon_monoxide": r.carbon_monoxide,
                "methane": r.methane,
                "health_score": r.health_score,
            }
            for r in readings
        ],
    }


@router.get("/{chamber_id}/stats", summary="Aggregated sensor stats for a time period")
async def get_stats(
    chamber_id: UUID,
    current_user: CurrentUser,
    db: DB,
    hours: int = Query(24, ge=1, le=8760),
):
    await _verify_chamber_access(chamber_id, current_user.company_id, db)

    since = datetime.now(timezone.utc) - timedelta(hours=hours)

    result = await db.execute(
        select(
            func.avg(SensorReading.temperature).label("avg_temp"),
            func.min(SensorReading.temperature).label("min_temp"),
            func.max(SensorReading.temperature).label("max_temp"),
            func.avg(SensorReading.humidity).label("avg_humidity"),
            func.min(SensorReading.humidity).label("min_humidity"),
            func.max(SensorReading.humidity).label("max_humidity"),
            func.avg(SensorReading.co2).label("avg_co2"),
            func.max(SensorReading.co2).label("max_co2"),
            func.avg(SensorReading.ethylene).label("avg_ethylene"),
            func.max(SensorReading.ethylene).label("max_ethylene"),
            func.count(SensorReading.id).label("reading_count"),
        ).where(
            SensorReading.chamber_id == chamber_id,
            SensorReading.recorded_at >= since,
        )
    )
    row = result.one()

    return {
        "chamber_id": str(chamber_id),
        "period_hours": hours,
        "reading_count": row.reading_count,
        "temperature": {"avg": _r(row.avg_temp), "min": _r(row.min_temp), "max": _r(row.max_temp), "unit": "°C"},
        "humidity": {"avg": _r(row.avg_humidity), "min": _r(row.min_humidity), "max": _r(row.max_humidity), "unit": "%RH"},
        "co2": {"avg": _r(row.avg_co2), "max": _r(row.max_co2), "unit": "ppm"},
        "ethylene": {"avg": _r(row.avg_ethylene), "max": _r(row.max_ethylene), "unit": "ppm"},
    }


# ─── Helper ───────────────────────────────────────────────────────────────────

async def _verify_chamber_access(chamber_id: UUID, company_id: UUID, db: AsyncSession) -> Chamber:
    result = await db.execute(
        select(Chamber)
        .join(Device, Chamber.device_id == Device.id)
        .where(Chamber.id == chamber_id, Device.company_id == company_id)
    )
    chamber = result.scalar_one_or_none()
    if not chamber:
        raise HTTPException(status_code=404, detail="Chamber not found.")
    return chamber


def _r(val) -> Optional[float]:
    return round(float(val), 2) if val is not None else None
