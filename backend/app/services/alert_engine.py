"""
ColdSmart Alert Engine
Converts raw sensor readings into actionable alerts with
cause, impact, and recommended corrective action.
"""
from datetime import datetime, timezone
from typing import Optional, List, Dict, Any
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models import (
    Alert, AlertSeverity, AlertStatus, Chamber, CropProfile,
    AuditLog, AuditAction, Company, User
)
from app.services.notification_service import send_push_alert


# ─── Alert Rule Definitions ───────────────────────────────────────────────────

class AlertRule:
    def __init__(
        self,
        alert_type: str,
        parameter: str,
        unit: str,
        check_fn,
        severity_fn,
        title_fn,
        cause_fn,
        impact_fn,
        action_fn,
    ):
        self.alert_type = alert_type
        self.parameter = parameter
        self.unit = unit
        self.check_fn = check_fn
        self.severity_fn = severity_fn
        self.title_fn = title_fn
        self.cause_fn = cause_fn
        self.impact_fn = impact_fn
        self.action_fn = action_fn

    def evaluate(self, reading: Dict[str, Any], chamber: Chamber, profile: Optional[CropProfile]) -> Optional[Dict]:
        value = reading.get(self.parameter)
        if value is None:
            return None

        if not self.check_fn(value, chamber, profile):
            return None  # No alert

        severity = self.severity_fn(value, chamber, profile)
        threshold = self._get_threshold(chamber, profile)

        return {
            "alert_type": self.alert_type,
            "parameter": self.parameter,
            "current_value": value,
            "threshold_value": threshold,
            "unit": self.unit,
            "severity": severity,
            "title": self.title_fn(value, chamber),
            "cause": self.cause_fn(value, chamber, profile),
            "impact": self.impact_fn(value, chamber, profile),
            "recommended_action": self.action_fn(value, chamber, profile),
        }

    def _get_threshold(self, chamber: Chamber, profile: Optional[CropProfile]) -> Optional[float]:
        mapping = {
            "temperature": (chamber.temp_min, chamber.temp_max),
            "humidity": (chamber.humidity_min, chamber.humidity_max),
            "co2": (chamber.co2_min, chamber.co2_max),
            "o2": (chamber.o2_min, chamber.o2_max),
            "ethylene": (None, chamber.ethylene_max),
            "carbon_monoxide": (None, chamber.co_max),
            "methane": (None, chamber.methane_max),
        }
        bounds = mapping.get(self.parameter, (None, None))
        return bounds[1] or bounds[0]


# ─── Alert Rules Registry ─────────────────────────────────────────────────────

ALERT_RULES: List[AlertRule] = [

    # Temperature High
    AlertRule(
        alert_type="temperature_high",
        parameter="temperature",
        unit="°C",
        check_fn=lambda v, c, p: c.temp_max is not None and v > c.temp_max,
        severity_fn=lambda v, c, p: (
            AlertSeverity.EMERGENCY if v > (c.temp_max or 0) + 5 else
            AlertSeverity.CRITICAL if v > (c.temp_max or 0) + 2 else
            AlertSeverity.WARNING
        ),
        title_fn=lambda v, c: f"Temperature Too High in {c.name}: {v:.1f}°C",
        cause_fn=lambda v, c, p: (
            f"Chamber temperature is {v:.1f}°C, exceeding the maximum limit of {c.temp_max:.1f}°C. "
            "This could be caused by compressor failure, door left open, or high ambient temperature."
        ),
        impact_fn=lambda v, c, p: (
            f"Elevated temperature accelerates metabolic activity and microbial growth, "
            f"significantly reducing shelf life. Estimated shelf life loss: "
            f"{max(1, int((v - (c.temp_max or 0)) * 2))} days per hour of exposure."
        ),
        action_fn=lambda v, c, p: (
            "1. Check if chamber door is properly sealed.\n"
            "2. Inspect compressor operation and refrigerant levels.\n"
            "3. Verify condenser coils are clean and unobstructed.\n"
            "4. Increase cooling setpoint if possible.\n"
            "5. Contact technician if temperature doesn't drop within 30 minutes."
        ),
    ),

    # Temperature Low
    AlertRule(
        alert_type="temperature_low",
        parameter="temperature",
        unit="°C",
        check_fn=lambda v, c, p: c.temp_min is not None and v < c.temp_min,
        severity_fn=lambda v, c, p: (
            AlertSeverity.CRITICAL if v < (c.temp_min or 0) - 3 else
            AlertSeverity.WARNING
        ),
        title_fn=lambda v, c: f"Temperature Too Low in {c.name}: {v:.1f}°C",
        cause_fn=lambda v, c, p: (
            f"Chamber temperature is {v:.1f}°C, below the minimum of {c.temp_min:.1f}°C. "
            "This may be caused by thermostat malfunction or over-cooling."
        ),
        impact_fn=lambda v, c, p: (
            "Freezing damage can cause cell rupture, leading to mushy texture and rapid "
            "spoilage after thawing. Some produce may be irreversibly damaged."
        ),
        action_fn=lambda v, c, p: (
            "1. Raise the thermostat setpoint immediately.\n"
            "2. Inspect thermostat calibration.\n"
            "3. Verify that produce is not in direct contact with cooling coils.\n"
            "4. Monitor for signs of chilling injury on produce."
        ),
    ),

    # Humidity Low
    AlertRule(
        alert_type="humidity_low",
        parameter="humidity",
        unit="%RH",
        check_fn=lambda v, c, p: c.humidity_min is not None and v < c.humidity_min,
        severity_fn=lambda v, c, p: (
            AlertSeverity.CRITICAL if v < (c.humidity_min or 0) - 15 else
            AlertSeverity.WARNING
        ),
        title_fn=lambda v, c: f"Humidity Too Low in {c.name}: {v:.0f}%",
        cause_fn=lambda v, c, p: (
            f"Relative humidity is {v:.0f}%, below the required minimum of {c.humidity_min:.0f}%. "
            "Possible causes: humidifier failure, air leakage, or excessive air circulation."
        ),
        impact_fn=lambda v, c, p: (
            "Low humidity causes produce to lose water weight (shrinkage), "
            "resulting in wilting, shriveling, and weight loss. "
            "A 5-7% weight loss typically makes produce unmarketable."
        ),
        action_fn=lambda v, c, p: (
            "1. Check humidifier operation and water supply.\n"
            "2. Inspect chamber seals for air leakage.\n"
            "3. Reduce air circulation fan speed if adjustable.\n"
            "4. Apply water misting on produce if available.\n"
            "5. Consider covering produce with wet cloth as emergency measure."
        ),
    ),

    # Humidity High
    AlertRule(
        alert_type="humidity_high",
        parameter="humidity",
        unit="%RH",
        check_fn=lambda v, c, p: c.humidity_max is not None and v > c.humidity_max,
        severity_fn=lambda v, c, p: (
            AlertSeverity.CRITICAL if v > (c.humidity_max or 0) + 10 else
            AlertSeverity.WARNING
        ),
        title_fn=lambda v, c: f"Humidity Too High in {c.name}: {v:.0f}%",
        cause_fn=lambda v, c, p: (
            f"Relative humidity is {v:.0f}%, above the maximum of {c.humidity_max:.0f}%. "
            "Possible causes: humidifier malfunction, water infiltration, or condensation."
        ),
        impact_fn=lambda v, c, p: (
            "Excessive humidity promotes fungal and bacterial growth, leading to "
            "mold, rot, and rapid spoilage. Can affect entire batch within 24-48 hours."
        ),
        action_fn=lambda v, c, p: (
            "1. Switch off humidifier immediately.\n"
            "2. Increase air circulation to reduce moisture.\n"
            "3. Inspect for water leakage inside chamber.\n"
            "4. Check drain system for blockage.\n"
            "5. Apply fungicide treatment if mold is visible."
        ),
    ),

    # CO2 High
    AlertRule(
        alert_type="co2_high",
        parameter="co2",
        unit="ppm",
        check_fn=lambda v, c, p: c.co2_max is not None and v > c.co2_max,
        severity_fn=lambda v, c, p: (
            AlertSeverity.EMERGENCY if v > (c.co2_max or 0) * 2 else
            AlertSeverity.CRITICAL if v > (c.co2_max or 0) * 1.5 else
            AlertSeverity.WARNING
        ),
        title_fn=lambda v, c: f"CO₂ Level Critical in {c.name}: {v:.0f} ppm",
        cause_fn=lambda v, c, p: (
            f"CO₂ level is {v:.0f} ppm, exceeding the maximum of {c.co2_max:.0f} ppm. "
            "Excessive respiration from produce or inadequate ventilation."
        ),
        impact_fn=lambda v, c, p: (
            "High CO₂ causes anaerobic fermentation, producing off-flavors and odors. "
            "Ethanol accumulation makes produce unsuitable for consumption."
        ),
        action_fn=lambda v, c, p: (
            "1. Increase ventilation immediately.\n"
            "2. Check CA (Controlled Atmosphere) system settings.\n"
            "3. Verify CO₂ scrubber is operational.\n"
            "4. Reduce produce density if possible.\n"
            "5. Open chamber briefly for emergency ventilation if safe to do so."
        ),
    ),

    # Ethylene High
    AlertRule(
        alert_type="ethylene_high",
        parameter="ethylene",
        unit="ppm",
        check_fn=lambda v, c, p: c.ethylene_max is not None and v > c.ethylene_max,
        severity_fn=lambda v, c, p: (
            AlertSeverity.CRITICAL if v > (c.ethylene_max or 0) * 3 else
            AlertSeverity.WARNING
        ),
        title_fn=lambda v, c: f"Ethylene High in {c.name}: {v:.2f} ppm",
        cause_fn=lambda v, c, p: (
            f"Ethylene is {v:.2f} ppm, above the safe limit of {c.ethylene_max:.2f} ppm. "
            "Some produce in the chamber may be over-ripening or decaying."
        ),
        impact_fn=lambda v, c, p: (
            "Ethylene is the ripening hormone. High levels accelerate ripening and senescence "
            "of all ethylene-sensitive produce in the chamber, causing premature spoilage."
        ),
        action_fn=lambda v, c, p: (
            "1. Identify and remove any over-ripe or decaying produce immediately.\n"
            "2. Activate ethylene scrubber/absorber if available.\n"
            "3. Increase ventilation to purge ethylene.\n"
            "4. Separate ethylene-producing from ethylene-sensitive produce.\n"
            "5. Check if any damaged packaging is present."
        ),
    ),

    # CO (Carbon Monoxide) High — Safety Alert
    AlertRule(
        alert_type="co_high",
        parameter="carbon_monoxide",
        unit="ppm",
        check_fn=lambda v, c, p: c.co_max is not None and v > c.co_max,
        severity_fn=lambda v, c, p: AlertSeverity.EMERGENCY,  # Always emergency
        title_fn=lambda v, c: f"⚠️ DANGER: CO Detected in {c.name}: {v:.1f} ppm",
        cause_fn=lambda v, c, p: (
            f"Carbon monoxide detected at {v:.1f} ppm — potentially hazardous to human health. "
            "Possible source: combustion equipment, forklift, or generator near intake."
        ),
        impact_fn=lambda v, c, p: (
            "Carbon monoxide is a colorless, odorless toxic gas. "
            "Levels above 35 ppm are dangerous to humans. "
            "Produce contamination may also occur. IMMEDIATE ACTION REQUIRED."
        ),
        action_fn=lambda v, c, p: (
            "🚨 EMERGENCY PROTOCOL:\n"
            "1. DO NOT enter the chamber without respiratory protection.\n"
            "2. Evacuate all personnel from the area immediately.\n"
            "3. Identify and shut down combustion source.\n"
            "4. Ventilate the area thoroughly.\n"
            "5. Contact emergency services if personnel are affected.\n"
            "6. Do NOT operate produce from contaminated chamber until cleared."
        ),
    ),

    # Methane High — Safety Alert
    AlertRule(
        alert_type="methane_high",
        parameter="methane",
        unit="ppm",
        check_fn=lambda v, c, p: c.methane_max is not None and v > c.methane_max,
        severity_fn=lambda v, c, p: AlertSeverity.EMERGENCY,
        title_fn=lambda v, c: f"⚠️ DANGER: Methane Detected in {c.name}: {v:.1f} ppm",
        cause_fn=lambda v, c, p: (
            f"Methane level is {v:.1f} ppm. Possible source: anaerobic decomposition, gas leak, or biogas."
        ),
        impact_fn=lambda v, c, p: (
            "Methane is flammable and explosive at 5-15% concentration. "
            "Anaerobic conditions producing methane indicate serious decomposition in the chamber."
        ),
        action_fn=lambda v, c, p: (
            "🚨 EMERGENCY PROTOCOL:\n"
            "1. DO NOT operate any electrical switches inside the chamber.\n"
            "2. Evacuate all personnel immediately.\n"
            "3. Ventilate the area — ensure no ignition sources nearby.\n"
            "4. Check for gas leaks in refrigerant and gas lines.\n"
            "5. Contact fire department if levels are critically high."
        ),
    ),
]


# ─── Alert Engine ─────────────────────────────────────────────────────────────

class AlertEngine:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def process_reading(
        self,
        chamber: Chamber,
        reading: Dict[str, Any],
        company_id: UUID,
    ) -> List[Alert]:
        """
        Evaluate all rules against a sensor reading and create alerts as needed.
        Deduplicates: won't create a duplicate alert if one is already ACTIVE for same type.
        """
        profile: Optional[CropProfile] = None
        if chamber.current_crop_profile_id:
            res = await self.db.execute(
                select(CropProfile).where(CropProfile.id == chamber.current_crop_profile_id)
            )
            profile = res.scalar_one_or_none()

        # Load existing active alerts for this chamber
        active_alerts_res = await self.db.execute(
            select(Alert).where(
                Alert.chamber_id == chamber.id,
                Alert.status == AlertStatus.ACTIVE,
            )
        )
        active_alerts = {a.alert_type: a for a in active_alerts_res.scalars().all()}

        created_alerts = []

        for rule in ALERT_RULES:
            result = rule.evaluate(reading, chamber, profile)
            if result:
                # Don't duplicate active alerts
                if result["alert_type"] in active_alerts:
                    continue

                alert = Alert(
                    company_id=company_id,
                    device_id=chamber.device_id,
                    chamber_id=chamber.id,
                    severity=result["severity"],
                    status=AlertStatus.ACTIVE,
                    alert_type=result["alert_type"],
                    title=result["title"],
                    cause=result["cause"],
                    impact=result["impact"],
                    recommended_action=result["recommended_action"],
                    parameter=result["parameter"],
                    current_value=result["current_value"],
                    threshold_value=result["threshold_value"],
                    unit=result["unit"],
                    triggered_at=datetime.now(timezone.utc),
                )
                self.db.add(alert)
                created_alerts.append(alert)

            else:
                # Auto-resolve previously active alert if condition cleared
                if rule.alert_type in active_alerts:
                    active_alert = active_alerts[rule.alert_type]
                    active_alert.status = AlertStatus.RESOLVED
                    active_alert.resolved_at = datetime.now(timezone.utc)

        await self.db.flush()

        # Send push notifications for new alerts
        for alert in created_alerts:
            await send_push_alert(company_id, alert, self.db)

        return created_alerts

    async def acknowledge_alert(self, alert_id: UUID, user: "User") -> Alert:
        res = await self.db.execute(select(Alert).where(Alert.id == alert_id))
        alert = res.scalar_one_or_none()
        if not alert:
            from fastapi import HTTPException
            raise HTTPException(status_code=404, detail="Alert not found.")

        alert.status = AlertStatus.ACKNOWLEDGED
        alert.acknowledged_at = datetime.now(timezone.utc)
        alert.acknowledged_by_id = user.id

        self.db.add(AuditLog(
            company_id=alert.company_id,
            user_id=user.id,
            device_id=alert.device_id,
            action=AuditAction.ALERT_ACKNOWLEDGED,
            description=f"Alert '{alert.title}' acknowledged.",
            resource_type="alert",
            resource_id=str(alert.id),
        ))
        return alert
