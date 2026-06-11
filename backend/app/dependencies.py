"""
ColdSmart FastAPI Dependencies
Reusable auth, permission, DB, and rate-limit dependencies
"""
import time
import logging
from typing import Optional, Annotated
from uuid import UUID

from fastapi import Depends, HTTPException, status, Request
from fastapi.security import OAuth2PasswordBearer, HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from redis.asyncio import Redis, from_url

from app.database import get_db
from app.models import User, UserRole, UserSession
from app.core.security import decode_token, hash_token, has_permission, require_permission
from app.config import settings

oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{settings.API_V1_PREFIX}/auth/login")
bearer_scheme = HTTPBearer(auto_error=False)

CREDENTIALS_EXCEPTION = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="Could not validate credentials.",
    headers={"WWW-Authenticate": "Bearer"},
)


async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    db: AsyncSession = Depends(get_db),
) -> User:
    try:
        payload = decode_token(token)
        if payload.get("type") != "access":
            raise CREDENTIALS_EXCEPTION
        user_id: str = payload.get("sub")
        if not user_id:
            raise CREDENTIALS_EXCEPTION
    except JWTError:
        raise CREDENTIALS_EXCEPTION

    result = await db.execute(
        select(User).where(User.id == UUID(user_id), User.is_active == True)
    )
    user = result.scalar_one_or_none()
    if not user:
        raise CREDENTIALS_EXCEPTION
    return user


async def get_current_active_user(
    current_user: Annotated[User, Depends(get_current_user)],
) -> User:
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user.")
    return current_user


class PermissionChecker:
    """Dependency factory for permission-based access control."""

    def __init__(self, required_permission: str):
        self.required_permission = required_permission

    def __call__(self, user: User = Depends(get_current_active_user)) -> User:
        require_permission(user.role, self.required_permission)
        return user


def require(permission: str):
    """Shorthand for PermissionChecker dependency."""
    return Depends(PermissionChecker(permission))


# ─── Role-Specific Dependencies ───────────────────────────────────────────────

async def get_owner_or_above(user: User = Depends(get_current_active_user)) -> User:
    if user.role not in (UserRole.SUPER_ADMIN, UserRole.OWNER):
        raise HTTPException(status_code=403, detail="Owner access required.")
    return user


async def get_manager_or_above(user: User = Depends(get_current_active_user)) -> User:
    if user.role not in (UserRole.SUPER_ADMIN, UserRole.OWNER, UserRole.MANAGER):
        raise HTTPException(status_code=403, detail="Manager access required.")
    return user


async def get_technician_or_above(user: User = Depends(get_current_active_user)) -> User:
    allowed = (UserRole.SUPER_ADMIN, UserRole.OWNER, UserRole.MANAGER, UserRole.TECHNICIAN)
    if user.role not in allowed:
        raise HTTPException(status_code=403, detail="Technician access required.")
    return user


async def get_super_admin(user: User = Depends(get_current_active_user)) -> User:
    if user.role != UserRole.SUPER_ADMIN:
        raise HTTPException(status_code=403, detail="Super admin access required.")
    return user


# ─── Common Pagination ────────────────────────────────────────────────────────

class PaginationParams:
    def __init__(self, page: int = 1, page_size: int = 20):
        if page < 1:
            raise HTTPException(status_code=400, detail="Page must be >= 1.")
        if page_size < 1 or page_size > 100:
            raise HTTPException(status_code=400, detail="Page size must be between 1 and 100.")
        self.page = page
        self.page_size = page_size
        self.offset = (page - 1) * page_size


Paginate = Annotated[PaginationParams, Depends(PaginationParams)]
CurrentUser = Annotated[User, Depends(get_current_active_user)]
DB = Annotated[AsyncSession, Depends(get_db)]


# ─── Rate Limiting System ─────────────────────────────────────────────────────

logger = logging.getLogger(__name__)

# Lazy initialized Redis client for rate limiting with fallback caching
_redis_limiter_client: Optional[Redis] = None
_redis_limiter_offline: bool = False
_redis_last_check: float = 0.0

def get_redis_limiter_client() -> Optional[Redis]:
    global _redis_limiter_client, _redis_limiter_offline, _redis_last_check
    now = time.time()
    if _redis_limiter_offline:
        # Check if cooldown of 30 seconds has expired
        if now - _redis_last_check < 30:
            return None
        _redis_limiter_offline = False

    if _redis_limiter_client is None:
        try:
            # Enforce tight connection timeouts to prevent SRE blocking issues
            _redis_limiter_client = from_url(
                settings.REDIS_URL,
                encoding="utf-8",
                decode_responses=True,
                socket_timeout=0.5,
                socket_connect_timeout=0.5,
            )
        except Exception as e:
            logger.warning(f"Failed to initialize Redis client: {e}. Cooldown activated.")
            _redis_limiter_offline = True
            _redis_last_check = now
            _redis_limiter_client = None
    return _redis_limiter_client


class RateLimiter:
    """Sliding-window rate limiter using Redis with a thread-safe local fallback."""
    _in_memory_cache: dict[str, list[float]] = {}

    def __init__(self, requests: int, window: int, key_prefix: str = "rate_limit"):
        self.requests = requests
        self.window = window
        self.key_prefix = key_prefix

    async def __call__(self, request: Request, identifier: Optional[str] = None) -> None:
        # Fallback to IP address if no custom identifier is provided
        if not identifier:
            identifier = request.client.host if request.client else "unknown"

        key = f"{self.key_prefix}:{identifier}"
        now = time.time()
        clear_before = now - self.window

        redis = get_redis_limiter_client()
        if redis:
            try:
                # Atomically clear old and add new using pipeline
                async with redis.pipeline(transaction=True) as pipe:
                    pipe.zremrangebyscore(key, 0, clear_before)
                    pipe.zadd(key, {str(now): now})
                    pipe.zcard(key)
                    pipe.expire(key, self.window)
                    _, _, count, _ = await pipe.execute()
                
                if count > self.requests:
                    raise HTTPException(
                        status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                        detail=f"Too many requests. Limit is {self.requests} requests per {self.window} seconds."
                    )
                return
            except HTTPException:
                raise
            except Exception as e:
                logger.warning(f"Redis rate limiter failed: {e}. Falling back to in-memory sliding window.")
                # Mark Redis offline to prevent further timeout attempts for 30s
                global _redis_limiter_offline, _redis_last_check
                _redis_limiter_offline = True
                _redis_last_check = time.time()

        # In-memory sliding window implementation
        history = self._in_memory_cache.get(key, [])
        # Filter out old events
        history = [t for t in history if t > clear_before]
        history.append(now)
        self._in_memory_cache[key] = history

        if len(history) > self.requests:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=f"Too many requests. Limit is {self.requests} requests per {self.window} seconds."
            )


def rate_limit(requests: int, window: int, key_prefix: str = "rl"):
    """Generic rate-limiting dependency by IP address."""
    limiter = RateLimiter(requests, window, key_prefix)
    async def dependency(request: Request):
        ip = request.client.host if request.client else "unknown"
        await limiter(request, ip)
    return Depends(dependency)


async def rate_limit_login_target(request: Request):
    """Rate limits login attempts by target identifier (email or phone)."""
    try:
        body = await request.json()
        target = body.get("email") or body.get("phone") or body.get("target")
    except Exception:
        target = None
    
    if target:
        # Max 5 attempts per 60 seconds per account target
        limiter = RateLimiter(5, 60, "login_target")
        await limiter(request, str(target).lower().strip())


async def rate_limit_otp_request(request: Request):
    """Rate limits OTP requests to prevent SMS/email billing abuse."""
    try:
        body = await request.json()
        target = body.get("target")
    except Exception:
        target = None
    
    if target:
        # Max 3 OTP requests per 5 minutes per target identifier
        limiter = RateLimiter(3, 300, "otp_request")
        await limiter(request, str(target).lower().strip())


async def rate_limit_otp_verify(request: Request):
    """Rate limits OTP verification attempts to prevent brute-forcing."""
    try:
        body = await request.json()
        target = body.get("target")
    except Exception:
        target = None
    
    if target:
        # Max 5 verification attempts per 5 minutes per target identifier
        limiter = RateLimiter(5, 300, "otp_verify")
        await limiter(request, str(target).lower().strip())
