"""
ColdSmart Alerts Router
List, filter, acknowledge, resolve, stats, and alert configuration
"""
from datetime import datetime, timezone
from typing import Optional, List
from uuid import UUID

from fastapi import APIRouter, HTTPException, Query
from sqlalchemy import select, func, update
from pydantic import BaseModel

from app.models import Alert, AlertSeverity, AlertStatus, AuditLog, AuditAction, Device
from app.dependencies import DB, CurrentUser, Paginate

router = APIRouter(prefix="/alerts", tags=["Alerts"])


# ─── Schemas ──────────────────────────────────────────────────────────────────

class AlertAcknowledgeRequest(BaseModel):
    note: Optional[str] = None


class AlertResolveRequest(BaseModel):
    resolution_note: Optional[str] = None


# ─── Routes ───────────────────────────────────────────────────────────────────

@router.get("/", summary="List alerts with filters")
async def list_alerts(
    current_user: CurrentUser,
    db: DB,
    pagination: Paginate,
    status: Optional[AlertStatus] = Query(None),
    severity: Optional[AlertSeverity] = Query(None),
    device_id: Optional[UUID] = Query(None),
    chamber_id: Optional[UUID] = Query(None),
    from_dt: Optional[datetime] = Query(None),
    to_dt: Optional[datetime] = Query(None),
):
    query = select(Alert).where(Alert.company_id == current_user.company_id)

    if status:
        query = query.where(Alert.status == status)
    if severity:
        query = query.where(Alert.severity == severity)
    if device_id:
        query = query.where(Alert.device_id == device_id)
    if chamber_id:
        query = query.where(Alert.chamber_id == chamber_id)
    if from_dt:
        query = query.where(Alert.triggered_at >= from_dt)
    if to_dt:
        query = query.where(Alert.triggered_at <= to_dt)

    # Sort: active first, then by severity (emergency first), then by time
    severity_order = {
        AlertSeverity.EMERGENCY: 0,
        AlertSeverity.CRITICAL: 1,
        AlertSeverity.WARNING: 2,
        AlertSeverity.INFO: 3,
    }

    total_res = await db.execute(select(func.count()).select_from(query.subquery()))
    total = total_res.scalar()

    result = await db.execute(
        query.order_by(Alert.triggered_at.desc())
        .offset(pagination.offset)
        .limit(pagination.page_size)
    )
    alerts = result.scalars().all()

    # Sort active before resolved
    active = [a for a in alerts if a.status == AlertStatus.ACTIVE]
    other = [a for a in alerts if a.status != AlertStatus.ACTIVE]
    sorted_alerts = sorted(active, key=lambda a: list(AlertSeverity).index(a.severity)) + other

    return {
        "items": [_alert_out(a) for a in sorted_alerts],
        "total": total,
        "page": pagination.page,
        "page_size": pagination.page_size,
    }


@router.get("/stats", summary="Alert statistics for dashboard")
async def get_alert_stats(current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(
            Alert.severity,
            Alert.status,
            func.count(Alert.id).label("count"),
        )
        .where(Alert.company_id == current_user.company_id)
        .group_by(Alert.severity, Alert.status)
    )
    rows = result.all()

    stats = {
        "total_active": 0,
        "emergency": 0,
        "critical": 0,
        "warning": 0,
        "info": 0,
        "resolved_24h": 0,
    }

    for row in rows:
        if row.status == AlertStatus.ACTIVE:
            stats["total_active"] += row.count
            sev_key = row.severity.value
            if sev_key in stats:
                stats[sev_key] += row.count

    # Resolved in last 24h
    from datetime import timedelta
    resolved_res = await db.execute(
        select(func.count(Alert.id)).where(
            Alert.company_id == current_user.company_id,
            Alert.status == AlertStatus.RESOLVED,
            Alert.resolved_at >= datetime.now(timezone.utc) - timedelta(hours=24),
        )
    )
    stats["resolved_24h"] = resolved_res.scalar() or 0

    return stats


@router.get("/{alert_id}", summary="Get alert detail with cause, impact, and action")
async def get_alert(alert_id: UUID, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(Alert).where(
            Alert.id == alert_id,
            Alert.company_id == current_user.company_id,
        )
    )
    alert = result.scalar_one_or_none()
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found.")

    return _alert_out(alert, full=True)


@router.post("/{alert_id}/acknowledge", summary="Acknowledge an active alert")
async def acknowledge_alert(
    alert_id: UUID,
    payload: AlertAcknowledgeRequest,
    current_user: CurrentUser,
    db: DB,
):
    result = await db.execute(
        select(Alert).where(Alert.id == alert_id, Alert.company_id == current_user.company_id)
    )
    alert = result.scalar_one_or_none()
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found.")
    if alert.status == AlertStatus.RESOLVED:
        raise HTTPException(status_code=400, detail="Alert is already resolved.")

    alert.status = AlertStatus.ACKNOWLEDGED
    alert.acknowledged_at = datetime.now(timezone.utc)
    alert.acknowledged_by_id = current_user.id

    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        device_id=alert.device_id,
        action=AuditAction.ALERT_ACKNOWLEDGED,
        description=f"Alert acknowledged: {alert.title}",
        resource_type="alert",
        resource_id=str(alert.id),
        log_metadata={"note": payload.note},
    ))

    return {"message": "Alert acknowledged.", "alert": _alert_out(alert)}


@router.post("/{alert_id}/resolve", summary="Mark alert as resolved")
async def resolve_alert(
    alert_id: UUID,
    payload: AlertResolveRequest,
    current_user: CurrentUser,
    db: DB,
):
    result = await db.execute(
        select(Alert).where(Alert.id == alert_id, Alert.company_id == current_user.company_id)
    )
    alert = result.scalar_one_or_none()
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found.")

    alert.status = AlertStatus.RESOLVED
    alert.resolved_at = datetime.now(timezone.utc)
    alert.resolved_by_id = current_user.id

    return {"message": "Alert resolved.", "alert": _alert_out(alert)}


# ─── Helper ───────────────────────────────────────────────────────────────────

def _alert_out(alert: Alert, full: bool = False) -> dict:
    out = {
        "id": str(alert.id),
        "device_id": str(alert.device_id),
        "chamber_id": str(alert.chamber_id) if alert.chamber_id else None,
        "severity": alert.severity.value,
        "status": alert.status.value,
        "alert_type": alert.alert_type,
        "title": alert.title,
        "parameter": alert.parameter,
        "current_value": alert.current_value,
        "threshold_value": alert.threshold_value,
        "unit": alert.unit,
        "triggered_at": alert.triggered_at.isoformat() if alert.triggered_at else None,
        "acknowledged_at": alert.acknowledged_at.isoformat() if alert.acknowledged_at else None,
        "resolved_at": alert.resolved_at.isoformat() if alert.resolved_at else None,
        "notification_sent": alert.notification_sent,
    }
    if full:
        out.update({
            "cause": alert.cause,
            "impact": alert.impact,
            "recommended_action": alert.recommended_action,
        })
    return out
