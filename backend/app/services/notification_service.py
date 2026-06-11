"""
ColdSmart Notification Service
Firebase Cloud Messaging (FCM) + SMS (Twilio) for alerts and OTP
"""
import logging
from typing import Optional, List
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.config import settings
from app.models import Alert, AlertSeverity, NotificationToken, User

logger = logging.getLogger(__name__)


# ─── FCM Push Notifications ───────────────────────────────────────────────────

async def send_push_alert(company_id: UUID, alert: Alert, db: AsyncSession):
    """Send push notification for a new alert to all relevant users."""
    if not settings.FIREBASE_CREDENTIALS_PATH:
        logger.warning("Firebase credentials not configured. Skipping push notification.")
        return

    try:
        import firebase_admin
        from firebase_admin import messaging

        # Get notification tokens for all active users in company
        users_res = await db.execute(
            select(User).where(
                User.company_id == company_id,
                User.is_active == True,
            )
        )
        users = users_res.scalars().all()
        user_ids = [u.id for u in users]

        tokens_res = await db.execute(
            select(NotificationToken).where(
                NotificationToken.user_id.in_(user_ids),
                NotificationToken.is_active == True,
            )
        )
        tokens = tokens_res.scalars().all()

        if not tokens:
            return

        # Build notification payload
        severity_emoji = {
            AlertSeverity.INFO: "ℹ️",
            AlertSeverity.WARNING: "⚠️",
            AlertSeverity.CRITICAL: "🚨",
            AlertSeverity.EMERGENCY: "🆘",
        }

        notification_title = f"{severity_emoji.get(alert.severity, '⚠️')} {alert.title}"
        notification_body = alert.recommended_action[:200]

        # Send to all tokens
        token_strings = [t.token for t in tokens]

        if len(token_strings) == 1:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=notification_title,
                    body=notification_body,
                ),
                data={
                    "alert_id": str(alert.id),
                    "severity": alert.severity.value,
                    "device_id": str(alert.device_id),
                    "type": "alert",
                },
                token=token_strings[0],
                android=messaging.AndroidConfig(priority="high"),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(sound="default", badge=1)
                    )
                ),
            )
            messaging.send(message)
        else:
            multicast = messaging.MulticastMessage(
                notification=messaging.Notification(
                    title=notification_title,
                    body=notification_body,
                ),
                data={
                    "alert_id": str(alert.id),
                    "severity": alert.severity.value,
                    "device_id": str(alert.device_id),
                    "type": "alert",
                },
                tokens=token_strings[:500],  # FCM limit
                android=messaging.AndroidConfig(priority="high"),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(sound="default", badge=1)
                    )
                ),
            )
            response = messaging.send_each_for_multicast(multicast)
            logger.info(f"Push sent: {response.success_count} success, {response.failure_count} failures")

        # Mark alert as notification sent
        alert.notification_sent = True

    except Exception as e:
        logger.error(f"Failed to send push notification: {e}", exc_info=True)


# ─── OTP Delivery ─────────────────────────────────────────────────────────────

async def send_otp_sms(phone: str, otp: str):
    """Send OTP via Twilio SMS."""
    if not all([settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN, settings.TWILIO_FROM_NUMBER]):
        logger.warning(f"[DEV] OTP for {phone}: {otp}")  # Log OTP in development
        return

    try:
        from twilio.rest import Client
        client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
        message = client.messages.create(
            body=f"Your ColdSmart verification code is: {otp}. Valid for {settings.OTP_EXPIRE_SECONDS // 60} minutes.",
            from_=settings.TWILIO_FROM_NUMBER,
            to=phone,
        )
        logger.info(f"SMS OTP sent to {phone}: SID={message.sid}")
    except Exception as e:
        logger.error(f"Failed to send SMS OTP to {phone}: {e}")


async def send_otp_email(email: str, otp: str, purpose: str = "login"):
    """Send OTP via email (SMTP)."""
    purpose_text = {
        "login": "sign in to",
        "verify": "verify your email for",
        "reset": "reset your password for",
    }.get(purpose, "access")

    html_body = f"""
    <div style="font-family: 'Outfit', Arial, sans-serif; max-width: 500px; margin: 0 auto; background: #0B1120; padding: 32px; border-radius: 16px; color: #F9FAFB;">
        <div style="text-align: center; margin-bottom: 24px;">
            <h1 style="color: #0EA5E9; font-size: 28px; margin: 0;">❄️ ColdSmart</h1>
        </div>
        <h2 style="color: #F9FAFB;">Your Verification Code</h2>
        <p style="color: #9CA3AF;">Use this code to {purpose_text} your ColdSmart account:</p>
        <div style="background: #1F2937; border: 2px solid #0EA5E9; border-radius: 12px; padding: 24px; text-align: center; margin: 24px 0;">
            <span style="font-size: 40px; font-weight: 700; letter-spacing: 12px; color: #0EA5E9;">{otp}</span>
        </div>
        <p style="color: #9CA3AF; font-size: 14px;">This code expires in {settings.OTP_EXPIRE_SECONDS // 60} minutes.</p>
        <p style="color: #6B7280; font-size: 12px;">If you didn't request this, please ignore this email.</p>
        <hr style="border: none; border-top: 1px solid #374151; margin: 24px 0;" />
        <p style="color: #4B5563; font-size: 11px; text-align: center;">ColdSmart – Intelligent Cold Storage Operating System</p>
    </div>
    """

    if not settings.SMTP_USER:
        logger.warning(f"[DEV] Email OTP for {email}: {otp}")
        return

    try:
        import smtplib
        from email.mime.multipart import MIMEMultipart
        from email.mime.text import MIMEText

        msg = MIMEMultipart("alternative")
        msg["Subject"] = f"ColdSmart: Your verification code is {otp}"
        msg["From"] = settings.SMTP_FROM
        msg["To"] = email
        msg.attach(MIMEText(html_body, "html"))

        with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT) as server:
            server.starttls()
            server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
            server.sendmail(settings.SMTP_FROM, email, msg.as_string())

        logger.info(f"Email OTP sent to {email}")
    except Exception as e:
        logger.error(f"Failed to send email OTP to {email}: {e}")
