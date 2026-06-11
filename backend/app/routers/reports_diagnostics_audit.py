"""
ColdSmart Reports Router + Diagnostics Router + Audit Router
Report generation (async), diagnostics trigger, and audit log viewer
"""
from datetime import datetime, timezone
from typing import Optional, List
from uuid import UUID

from fastapi import APIRouter, HTTPException, BackgroundTasks, Query
from sqlalchemy import select, func
from pydantic import BaseModel

from app.models import (
    Report, ReportType, ReportFormat, AuditLog, AuditAction,
    Device, DiagnosticResult,
)
from app.dependencies import DB, CurrentUser, Paginate
from app.mqtt.broker_client import mqtt_client

# ─── Reports Router ───────────────────────────────────────────────────────────

reports_router = APIRouter(prefix="/reports", tags=["Reports"])


class GenerateReportRequest(BaseModel):
    report_type: ReportType
    format: ReportFormat
    device_ids: List[UUID]
    date_from: datetime
    date_to: datetime
    title: Optional[str] = None


@reports_router.post("/generate", summary="Generate a compliance report (async)")
async def generate_report(
    payload: GenerateReportRequest,
    current_user: CurrentUser,
    db: DB,
    background_tasks: BackgroundTasks,
):
    title = payload.title or f"{payload.report_type.value.replace('_', ' ').title()} Report"

    report = Report(
        company_id=current_user.company_id,
        generated_by_id=current_user.id,
        report_type=payload.report_type,
        format=payload.format,
        title=title,
        date_from=payload.date_from,
        date_to=payload.date_to,
        filters={"device_ids": [str(d) for d in payload.device_ids]},
        is_ready=False,
    )
    db.add(report)
    await db.flush()
    report_id = report.id

    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        action=AuditAction.REPORT_GENERATED,
        description=f"Report generation started: {title} ({payload.format.value.upper()})",
        resource_type="report",
        resource_id=str(report_id),
    ))

    # Run report generation in background
    background_tasks.add_task(
        _run_report_generation,
        report_id, payload.report_type, payload.format,
        payload.device_ids, payload.date_from, payload.date_to,
        current_user.company_id,
    )

    return {
        "message": "Report generation started.",
        "report_id": str(report_id),
        "status": "generating",
        "estimated_seconds": 10,
    }


@reports_router.get("/", summary="List generated reports")
async def list_reports(current_user: CurrentUser, db: DB, pagination: Paginate):
    result = await db.execute(
        select(Report)
        .where(Report.company_id == current_user.company_id)
        .order_by(Report.created_at.desc())
        .offset(pagination.offset)
        .limit(pagination.page_size)
    )
    reports = result.scalars().all()
    total_res = await db.execute(
        select(func.count(Report.id)).where(Report.company_id == current_user.company_id)
    )

    return {
        "items": [
            {
                "id": str(r.id),
                "title": r.title,
                "report_type": r.report_type.value,
                "format": r.format.value,
                "is_ready": r.is_ready,
                "file_url": r.file_url,
                "file_size_bytes": r.file_size_bytes,
                "error_message": r.error_message,
                "date_from": r.date_from.isoformat(),
                "date_to": r.date_to.isoformat(),
                "created_at": r.created_at.isoformat(),
            }
            for r in reports
        ],
        "total": total_res.scalar(),
    }


@reports_router.get("/{report_id}", summary="Get report status and download URL")
async def get_report(report_id: UUID, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(Report).where(Report.id == report_id, Report.company_id == current_user.company_id)
    )
    report = result.scalar_one_or_none()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found.")

    return {
        "id": str(report.id),
        "title": report.title,
        "report_type": report.report_type.value,
        "format": report.format.value,
        "is_ready": report.is_ready,
        "file_url": report.file_url,
        "file_size_bytes": report.file_size_bytes,
        "error_message": report.error_message,
        "date_from": report.date_from.isoformat(),
        "date_to": report.date_to.isoformat(),
    }


async def _run_report_generation(
    report_id, report_type, format, device_ids, date_from, date_to, company_id
):
    """Background task: generate report and save to MinIO."""
    from app.database import AsyncSessionLocal
    from app.services.report_generator import ReportGenerator
    import boto3
    from botocore.config import Config

    async with AsyncSessionLocal() as db:
        report_res = await db.execute(select(Report).where(Report.id == report_id))
        report = report_res.scalar_one_or_none()
        if not report:
            return

        try:
            generator = ReportGenerator(db)

            if format == ReportFormat.PDF:
                content = await generator.generate_temperature_compliance_pdf(
                    company_id, device_ids, date_from, date_to, report.title
                )
                content_type = "application/pdf"
                ext = "pdf"
            elif format == ReportFormat.EXCEL:
                content = await generator.generate_excel_report(
                    company_id, device_ids, date_from, date_to, report_type
                )
                content_type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                ext = "xlsx"
            else:
                content = await generator.generate_csv_report(
                    company_id, device_ids, date_from, date_to
                )
                content_type = "text/csv"
                ext = "csv"

            # Upload to MinIO
            s3 = boto3.client(
                "s3",
                endpoint_url=f"http://{settings.MINIO_ENDPOINT}",
                aws_access_key_id=settings.MINIO_ACCESS_KEY,
                aws_secret_access_key=settings.MINIO_SECRET_KEY,
                config=Config(signature_version="s3v4"),
            )
            from app.config import settings
            object_key = f"reports/{company_id}/{report_id}/report.{ext}"
            s3.put_object(
                Bucket=settings.MINIO_BUCKET_REPORTS,
                Key=object_key,
                Body=content,
                ContentType=content_type,
            )

            file_url = f"{settings.MINIO_ENDPOINT}/{settings.MINIO_BUCKET_REPORTS}/{object_key}"
            report.file_url = file_url
            report.file_size_bytes = len(content)
            report.is_ready = True

        except Exception as e:
            report.error_message = str(e)
            report.is_ready = False

        await db.commit()


# ─── Diagnostics Router ───────────────────────────────────────────────────────

diagnostics_router = APIRouter(prefix="/diagnostics", tags=["Diagnostics"])

ALL_TESTS = [
    "temperature_sensor", "humidity_sensor", "co2_sensor",
    "o2_sensor", "ethylene_sensor", "co_sensor", "methane_sensor",
    "fan", "compressor", "door_sensor", "relays", "alarm",
    "wifi", "bluetooth",
]


@diagnostics_router.post("/{device_id}/run", summary="Trigger device diagnostics (via MQTT)")
async def run_diagnostics(
    device_id: UUID,
    current_user: CurrentUser,
    db: DB,
    background_tasks: BackgroundTasks,
    tests: Optional[List[str]] = Query(None, description="Tests to run (default: all)"),
):
    dev_res = await db.execute(
        select(Device).where(Device.id == device_id, Device.company_id == current_user.company_id)
    )
    device = dev_res.scalar_one_or_none()
    if not device:
        raise HTTPException(status_code=404, detail="Device not found.")

    test_list = tests or ALL_TESTS

    background_tasks.add_task(
        mqtt_client.request_diagnostics,
        str(current_user.company_id),
        device.device_id,
        test_list,
    )

    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        device_id=device.id,
        action=AuditAction.DIAGNOSTICS,
        description=f"Diagnostics triggered: {', '.join(test_list)}",
        resource_type="device",
        resource_id=str(device_id),
    ))

    return {
        "message": "Diagnostics triggered. Results will be available shortly.",
        "device_id": str(device_id),
        "tests_requested": test_list,
    }


@diagnostics_router.get("/{device_id}/results", summary="Get latest diagnostic results")
async def get_diagnostic_results(device_id: UUID, current_user: CurrentUser, db: DB, limit: int = 5):
    dev_res = await db.execute(
        select(Device).where(Device.id == device_id, Device.company_id == current_user.company_id)
    )
    if not dev_res.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Device not found.")

    result = await db.execute(
        select(DiagnosticResult)
        .where(DiagnosticResult.device_id == device_id)
        .order_by(DiagnosticResult.run_at.desc())
        .limit(limit)
    )
    diagnostics = result.scalars().all()

    return {
        "device_id": str(device_id),
        "results": [
            {
                "id": str(d.id),
                "run_at": d.run_at.isoformat(),
                "overall_status": d.overall_status,
                "results": d.results,
                "notes": d.notes,
            }
            for d in diagnostics
        ],
    }


@diagnostics_router.post("/{device_id}/calibrate", summary="Trigger sensor calibration")
async def trigger_calibration(
    device_id: UUID,
    current_user: CurrentUser,
    db: DB,
    background_tasks: BackgroundTasks,
    sensors: Optional[List[str]] = Query(None),
):
    dev_res = await db.execute(
        select(Device).where(Device.id == device_id, Device.company_id == current_user.company_id)
    )
    device = dev_res.scalar_one_or_none()
    if not device:
        raise HTTPException(status_code=404, detail="Device not found.")

    sensors_to_calibrate = sensors or ["temperature", "humidity", "co2"]

    background_tasks.add_task(
        mqtt_client.send_command,
        str(current_user.company_id),
        device.device_id,
        {"action": "calibrate", "sensors": sensors_to_calibrate},
    )

    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        device_id=device.id,
        action=AuditAction.CALIBRATION,
        description=f"Sensor calibration triggered: {', '.join(sensors_to_calibrate)}",
    ))

    return {"message": "Calibration command sent.", "sensors": sensors_to_calibrate}


# ─── Audit Router ─────────────────────────────────────────────────────────────

audit_router = APIRouter(prefix="/audit", tags=["Audit Logs"])


@audit_router.get("/", summary="Company audit log with filters")
async def get_audit_log(
    current_user: CurrentUser,
    db: DB,
    pagination: Paginate,
    user_id: Optional[UUID] = Query(None),
    device_id: Optional[UUID] = Query(None),
    action: Optional[AuditAction] = Query(None),
    from_dt: Optional[datetime] = Query(None),
    to_dt: Optional[datetime] = Query(None),
):
    query = select(AuditLog).where(AuditLog.company_id == current_user.company_id)

    if user_id:
        query = query.where(AuditLog.user_id == user_id)
    if device_id:
        query = query.where(AuditLog.device_id == device_id)
    if action:
        query = query.where(AuditLog.action == action)
    if from_dt:
        query = query.where(AuditLog.timestamp >= from_dt)
    if to_dt:
        query = query.where(AuditLog.timestamp <= to_dt)

    total_res = await db.execute(select(func.count()).select_from(query.subquery()))
    total = total_res.scalar()

    result = await db.execute(
        query.order_by(AuditLog.timestamp.desc())
        .offset(pagination.offset)
        .limit(pagination.page_size)
    )
    logs = result.scalars().all()

    return {
        "items": [
            {
                "id": str(log.id),
                "user_id": str(log.user_id) if log.user_id else None,
                "device_id": str(log.device_id) if log.device_id else None,
                "action": log.action.value,
                "resource_type": log.resource_type,
                "resource_id": log.resource_id,
                "description": log.description,
                "ip_address": log.ip_address,
                "timestamp": log.timestamp.isoformat(),
                "metadata": log.log_metadata,
            }
            for log in logs
        ],
        "total": total,
        "page": pagination.page,
        "page_size": pagination.page_size,
    }


from app.models import AuditAction as _AA  # re-export for import
