"""
ColdSmart Authentication Router
Email, Phone, OTP login + JWT + Refresh Token management
"""
from datetime import datetime, timedelta, timezone
from typing import Optional
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from pydantic import BaseModel, EmailStr, Field

from app.database import get_db
from app.models import User, UserSession, OTPRecord, Company, UserRole, AuthProvider, AuditLog, AuditAction, NotificationToken
from app.core.security import (
    hash_password, verify_password, hash_token, hash_otp, generate_otp,
    create_access_token, create_refresh_token, decode_token,
)
from app.config import settings
from app.dependencies import (
    DB, CurrentUser, rate_limit,
    rate_limit_login_target, rate_limit_otp_request, rate_limit_otp_verify
)
from app.services.notification_service import send_otp_sms, send_otp_email

router = APIRouter(prefix="/auth", tags=["Authentication"])


# ─── Schemas ──────────────────────────────────────────────────────────────────

class EmailLoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)


class PhoneLoginRequest(BaseModel):
    phone: str = Field(pattern=r"^\+?[1-9]\d{7,14}$")
    password: str = Field(min_length=8)


class OTPRequestPayload(BaseModel):
    target: str  # email or phone
    purpose: str = "login"  # login | verify | reset


class OTPVerifyPayload(BaseModel):
    target: str
    otp: str = Field(min_length=4, max_length=8)
    purpose: str = "login"


class RefreshRequest(BaseModel):
    refresh_token: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
    user: dict


class RegisterFCMToken(BaseModel):
    token: str
    platform: str = Field(pattern="^(android|ios|web)$")


# ─── Helpers ──────────────────────────────────────────────────────────────────

async def _create_session_tokens(user: User, db: AsyncSession, request: Request) -> TokenResponse:
    session_id = uuid4()
    raw_refresh, refresh_hash = create_refresh_token(user.id, session_id)

    session = UserSession(
        id=session_id,
        user_id=user.id,
        refresh_token_hash=refresh_hash,
        ip_address=request.client.host if request.client else None,
        user_agent=request.headers.get("user-agent"),
        expires_at=datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
        device_info={"platform": request.headers.get("x-platform", "unknown")},
    )
    db.add(session)

    # Update last login
    user.last_login_at = datetime.now(timezone.utc)

    # Audit log
    db.add(AuditLog(
        company_id=user.company_id,
        user_id=user.id,
        action=AuditAction.LOGIN,
        description=f"User logged in via {user.auth_provider.value}",
        ip_address=request.client.host if request.client else None,
        user_agent=request.headers.get("user-agent"),
    ))

    access_token = create_access_token(user.id, user.company_id, user.role)

    return TokenResponse(
        access_token=access_token,
        refresh_token=raw_refresh,
        user={
            "id": str(user.id),
            "name": user.name,
            "email": user.email,
            "phone": user.phone,
            "role": user.role.value,
            "company_id": str(user.company_id),
            "app_mode": user.app_mode,
            "profile_image_url": user.profile_image_url,
        },
    )


# ─── Routes ───────────────────────────────────────────────────────────────────

@router.post(
    "/login/email",
    response_model=TokenResponse,
    summary="Login with email + password",
    dependencies=[rate_limit(10, 60, "login_email_ip"), Depends(rate_limit_login_target)],
)
async def login_email(payload: EmailLoginRequest, request: Request, db: DB):
    result = await db.execute(
        select(User).where(User.email == payload.email.lower(), User.is_active == True)
    )
    user = result.scalar_one_or_none()

    if not user or not user.password_hash or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password.")

    return await _create_session_tokens(user, db, request)


@router.post(
    "/login/phone",
    response_model=TokenResponse,
    summary="Login with phone + password",
    dependencies=[rate_limit(10, 60, "login_phone_ip"), Depends(rate_limit_login_target)],
)
async def login_phone(payload: PhoneLoginRequest, request: Request, db: DB):
    result = await db.execute(
        select(User).where(User.phone == payload.phone, User.is_active == True)
    )
    user = result.scalar_one_or_none()

    if not user or not user.password_hash or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid phone or password.")

    return await _create_session_tokens(user, db, request)


@router.post(
    "/otp/request",
    summary="Request OTP via email or phone",
    dependencies=[rate_limit(10, 60, "otp_request_ip"), Depends(rate_limit_otp_request)],
)
async def request_otp(payload: OTPRequestPayload, background_tasks: BackgroundTasks, db: DB):
    otp = generate_otp(6)
    otp_hash = hash_otp(otp)

    otp_record = OTPRecord(
        target=payload.target,
        otp_hash=otp_hash,
        purpose=payload.purpose,
        expires_at=datetime.now(timezone.utc) + timedelta(seconds=settings.OTP_EXPIRE_SECONDS),
    )
    db.add(otp_record)

    # Send OTP asynchronously
    if "@" in payload.target:
        background_tasks.add_task(send_otp_email, payload.target, otp, payload.purpose)
    else:
        background_tasks.add_task(send_otp_sms, payload.target, otp)

    return {"message": "OTP sent successfully.", "expires_in": settings.OTP_EXPIRE_SECONDS}


@router.post(
    "/otp/verify",
    response_model=TokenResponse,
    summary="Verify OTP and get tokens",
    dependencies=[rate_limit(10, 60, "otp_verify_ip"), Depends(rate_limit_otp_verify)],
)
async def verify_otp(payload: OTPVerifyPayload, request: Request, db: DB):
    result = await db.execute(
        select(OTPRecord).where(
            OTPRecord.target == payload.target,
            OTPRecord.purpose == payload.purpose,
            OTPRecord.is_used == False,
            OTPRecord.expires_at > datetime.now(timezone.utc),
        ).order_by(OTPRecord.created_at.desc()).limit(1)
    )
    record = result.scalar_one_or_none()

    if not record:
        raise HTTPException(status_code=400, detail="OTP expired or not found.")

    if record.attempts >= 5:
        raise HTTPException(status_code=429, detail="Too many OTP attempts.")

    expected_hash = hash_otp(payload.otp)
    if record.otp_hash != expected_hash:
        record.attempts += 1
        raise HTTPException(status_code=400, detail="Invalid OTP.")

    record.is_used = True

    # Find or reject user
    if "@" in payload.target:
        res = await db.execute(select(User).where(User.email == payload.target, User.is_active == True))
    else:
        res = await db.execute(select(User).where(User.phone == payload.target, User.is_active == True))

    user = res.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")

    return await _create_session_tokens(user, db, request)


@router.post("/refresh", response_model=TokenResponse, summary="Refresh access token")
async def refresh_token(payload: RefreshRequest, request: Request, db: DB):
    try:
        claims = decode_token(payload.refresh_token)
        if claims.get("type") != "refresh":
            raise HTTPException(status_code=401, detail="Invalid token type.")
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid refresh token.")

    token_hash = hash_token(payload.refresh_token)
    result = await db.execute(
        select(UserSession).where(
            UserSession.refresh_token_hash == token_hash,
            UserSession.is_revoked == False,
            UserSession.expires_at > datetime.now(timezone.utc),
        )
    )
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=401, detail="Session expired or revoked.")

    user_res = await db.execute(select(User).where(User.id == session.user_id, User.is_active == True))
    user = user_res.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="User not found.")

    # Rotate refresh token (token rotation for security)
    new_raw, new_hash = create_refresh_token(user.id, session.id)
    session.refresh_token_hash = new_hash
    session.last_used_at = datetime.now(timezone.utc)
    access_token = create_access_token(user.id, user.company_id, user.role)

    return TokenResponse(
        access_token=access_token,
        refresh_token=new_raw,
        user={
            "id": str(user.id),
            "name": user.name,
            "email": user.email,
            "phone": user.phone,
            "role": user.role.value,
            "company_id": str(user.company_id),
            "app_mode": user.app_mode,
            "profile_image_url": user.profile_image_url,
        },
    )


@router.post("/logout", summary="Logout and revoke session")
async def logout(current_user: CurrentUser, request: Request, db: DB):
    auth_header = request.headers.get("authorization", "")
    access_token = auth_header.replace("Bearer ", "")

    try:
        claims = decode_token(access_token)
    except Exception:
        return {"message": "Logged out."}

    # Find and revoke the current session
    result = await db.execute(
        select(UserSession).where(
            UserSession.user_id == current_user.id,
            UserSession.is_revoked == False,
        ).limit(1)
    )
    session = result.scalar_one_or_none()
    if session:
        session.is_revoked = True

    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        action=AuditAction.LOGOUT,
        description="User logged out.",
        ip_address=request.client.host if request.client else None,
    ))

    return {"message": "Logged out successfully."}


@router.post("/logout/all", summary="Revoke all sessions")
async def logout_all(current_user: CurrentUser, db: DB):
    await db.execute(
        update(UserSession)
        .where(UserSession.user_id == current_user.id, UserSession.is_revoked == False)
        .values(is_revoked=True)
    )
    return {"message": "All sessions revoked."}


@router.post("/fcm-token", summary="Register FCM push notification token")
async def register_fcm_token(payload: RegisterFCMToken, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(NotificationToken).where(
            NotificationToken.user_id == current_user.id,
            NotificationToken.token == payload.token,
        )
    )
    existing = result.scalar_one_or_none()
    if not existing:
        db.add(NotificationToken(
            user_id=current_user.id,
            token=payload.token,
            platform=payload.platform,
        ))
    return {"message": "Token registered."}
