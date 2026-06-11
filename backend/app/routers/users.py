"""
ColdSmart Users Router
User profiles, preferences, and company user management
"""
from typing import Optional, List
from uuid import UUID

from fastapi import APIRouter, HTTPException, status, Depends
from sqlalchemy import select, func
from pydantic import BaseModel, Field, EmailStr

from app.models import User, UserRole, AuthProvider, AuditLog, AuditAction
from app.dependencies import DB, CurrentUser, Paginate, get_manager_or_above, get_owner_or_above
from app.core.security import hash_password

router = APIRouter(prefix="/users", tags=["Users"])


# ─── Schemas ──────────────────────────────────────────────────────────────────

class UserMeUpdateRequest(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    preferred_language: Optional[str] = Field(None, max_length=10)
    app_mode: Optional[str] = Field(None, pattern="^(simple|expert)$")
    notification_preferences: Optional[dict] = None
    profile_image_url: Optional[str] = Field(None, max_length=500)


class UserCreateRequest(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    email: Optional[EmailStr] = None
    phone: Optional[str] = Field(None, pattern=r"^\+?[1-9]\d{7,14}$")
    password: str = Field(min_length=8)
    role: UserRole = UserRole.VIEWER
    app_mode: str = "simple"


class UserUpdateRequest(BaseModel):
    name: Optional[str] = None
    role: Optional[UserRole] = None
    is_active: Optional[bool] = None
    app_mode: Optional[str] = None


# ─── User Profile Endpoints ───────────────────────────────────────────────────

@router.get("/me", summary="Get current user details and preferences")
async def get_my_profile(current_user: CurrentUser):
    return {
        "id": str(current_user.id),
        "company_id": str(current_user.company_id),
        "name": current_user.name,
        "email": current_user.email,
        "phone": current_user.phone,
        "role": current_user.role.value,
        "is_active": current_user.is_active,
        "app_mode": current_user.app_mode,
        "preferred_language": current_user.preferred_language,
        "profile_image_url": current_user.profile_image_url,
        "notification_preferences": current_user.notification_preferences,
        "created_at": current_user.created_at.isoformat(),
    }


@router.put("/me", summary="Update current user details or settings")
async def update_my_profile(payload: UserMeUpdateRequest, current_user: CurrentUser, db: DB):
    if payload.name is not None:
        current_user.name = payload.name
    if payload.preferred_language is not None:
        current_user.preferred_language = payload.preferred_language
    if payload.app_mode is not None:
        current_user.app_mode = payload.app_mode
    if payload.notification_preferences is not None:
        current_user.notification_preferences = payload.notification_preferences
    if payload.profile_image_url is not None:
        current_user.profile_image_url = payload.profile_image_url

    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        action=AuditAction.USER_MODIFIED,
        description="User updated their own profile settings.",
    ))
    await db.commit()

    return {"message": "Profile updated successfully."}


# ─── Administrative User Management Endpoints ─────────────────────────────────

@router.get("/", summary="List all users in the company")
async def list_users(current_user: CurrentUser, db: DB, pagination: Paginate):
    result = await db.execute(
        select(User)
        .where(User.company_id == current_user.company_id)
        .order_by(User.name.asc())
        .offset(pagination.offset)
        .limit(pagination.page_size)
    )
    users = result.scalars().all()

    total_res = await db.execute(
        select(func.count(User.id)).where(User.company_id == current_user.company_id)
    )
    total = total_res.scalar()

    return {
        "items": [
            {
                "id": str(u.id),
                "name": u.name,
                "email": u.email,
                "phone": u.phone,
                "role": u.role.value,
                "is_active": u.is_active,
                "app_mode": u.app_mode,
                "last_login_at": u.last_login_at.isoformat() if u.last_login_at else None,
            }
            for u in users
        ],
        "total": total,
        "page": pagination.page,
        "page_size": pagination.page_size,
    }


@router.post("/", summary="Add a new user to the company", status_code=status.HTTP_201_CREATED)
async def add_user(
    payload: UserCreateRequest,
    current_user: User = Depends(get_manager_or_above),
    db: DB = None,
):
    if not payload.email and not payload.phone:
        raise HTTPException(status_code=400, detail="Either email or phone number must be provided.")

    # Prevent managers from creating super_admins or owners
    if current_user.role == UserRole.MANAGER and payload.role in (UserRole.SUPER_ADMIN, UserRole.OWNER):
        raise HTTPException(status_code=403, detail="Managers cannot assign owner or super admin roles.")

    # Restrict SUPER_ADMIN creation to existing SUPER_ADMINs
    if payload.role == UserRole.SUPER_ADMIN and current_user.role != UserRole.SUPER_ADMIN:
        raise HTTPException(status_code=403, detail="Only super admins can assign the super admin role.")

    # Check for unique email
    if payload.email:
        existing_email = await db.execute(select(User).where(User.email == payload.email.lower()))
        if existing_email.scalar_one_or_none():
            raise HTTPException(status_code=409, detail="Email already registered.")

    # Check for unique phone
    if payload.phone:
        existing_phone = await db.execute(select(User).where(User.phone == payload.phone))
        if existing_phone.scalar_one_or_none():
            raise HTTPException(status_code=409, detail="Phone number already registered.")

    # Hash the password
    pass_hash = hash_password(payload.password)

    new_user = User(
        company_id=current_user.company_id,
        name=payload.name,
        email=payload.email.lower() if payload.email else None,
        phone=payload.phone,
        password_hash=pass_hash,
        role=payload.role,
        auth_provider=AuthProvider.EMAIL if payload.email else AuthProvider.PHONE,
        app_mode=payload.app_mode,
        is_active=True,
    )
    db.add(new_user)
    await db.flush()

    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        action=AuditAction.USER_CREATED,
        description=f"Created user '{payload.name}' with role '{payload.role.value}'.",
        resource_type="user",
        resource_id=str(new_user.id),
    ))
    await db.commit()

    return {"message": "User added successfully.", "id": str(new_user.id)}


@router.get("/{user_id}", summary="Get user details by ID")
async def get_user(user_id: UUID, current_user: CurrentUser, db: DB):
    result = await db.execute(
        select(User).where(User.id == user_id, User.company_id == current_user.company_id)
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")

    return {
        "id": str(user.id),
        "company_id": str(user.company_id),
        "name": user.name,
        "email": user.email,
        "phone": user.phone,
        "role": user.role.value,
        "is_active": user.is_active,
        "app_mode": user.app_mode,
        "preferred_language": user.preferred_language,
        "profile_image_url": user.profile_image_url,
        "created_at": user.created_at.isoformat(),
    }


@router.put("/{user_id}", summary="Update user role or active status")
async def update_user(
    user_id: UUID,
    payload: UserUpdateRequest,
    current_user: User = Depends(get_manager_or_above),
    db: DB = None,
):
    result = await db.execute(
        select(User).where(User.id == user_id, User.company_id == current_user.company_id)
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")

    # Restrict permissions for updates
    if current_user.id == user.id and payload.role is not None and payload.role != current_user.role:
        raise HTTPException(status_code=400, detail="Users cannot change their own roles.")

    # Restrict SUPER_ADMIN modifications or promotions to existing SUPER_ADMINs
    if (user.role == UserRole.SUPER_ADMIN or payload.role == UserRole.SUPER_ADMIN) and current_user.role != UserRole.SUPER_ADMIN:
        raise HTTPException(status_code=403, detail="Only super admins can modify or assign the super admin role.")

    if current_user.role == UserRole.MANAGER:
        # Managers can't modify owners/super_admins, nor elevate others to those roles
        if user.role in (UserRole.SUPER_ADMIN, UserRole.OWNER):
            raise HTTPException(status_code=403, detail="Managers cannot modify owners or super admins.")
        if payload.role in (UserRole.SUPER_ADMIN, UserRole.OWNER):
            raise HTTPException(status_code=403, detail="Managers cannot assign owner or super admin roles.")

    if payload.name is not None:
        user.name = payload.name
    if payload.role is not None:
        user.role = payload.role
    if payload.is_active is not None:
        user.is_active = payload.is_active
    if payload.app_mode is not None:
        user.app_mode = payload.app_mode

    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        action=AuditAction.USER_MODIFIED,
        description=f"Modified user '{user.name}' ({user_id}).",
        resource_type="user",
        resource_id=str(user_id),
    ))
    await db.commit()

    return {"message": "User updated successfully."}


@router.delete("/{user_id}", summary="Deactivate user (soft delete)")
async def deactivate_user(
    user_id: UUID,
    current_user: User = Depends(get_manager_or_above),
    db: DB = None,
):
    result = await db.execute(
        select(User).where(User.id == user_id, User.company_id == current_user.company_id)
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")

    if user.id == current_user.id:
        raise HTTPException(status_code=400, detail="You cannot deactivate your own account.")

    if current_user.role == UserRole.MANAGER and user.role in (UserRole.SUPER_ADMIN, UserRole.OWNER):
        raise HTTPException(status_code=403, detail="Managers cannot deactivate owners or super admins.")

    user.is_active = False

    db.add(AuditLog(
        company_id=current_user.company_id,
        user_id=current_user.id,
        action=AuditAction.USER_DELETED,
        description=f"Deactivated user '{user.name}' ({user_id}).",
        resource_type="user",
        resource_id=str(user_id),
    ))
    await db.commit()

    return {"message": "User deactivated successfully."}
