"""
ColdSmart Exception Classes
Production exception hierarchy for consistent error handling
"""
from fastapi import HTTPException


class ColdSmartException(Exception):
    """Base exception for all ColdSmart business logic errors."""
    def __init__(self, message: str, error_code: str, status_code: int = 400):
        self.message = message
        self.error_code = error_code
        self.status_code = status_code
        super().__init__(message)


class DeviceNotFound(ColdSmartException):
    def __init__(self, device_id: str):
        super().__init__(f"Device '{device_id}' not found.", "DEVICE_NOT_FOUND", 404)


class DeviceAlreadyRegistered(ColdSmartException):
    def __init__(self, device_id: str):
        super().__init__(f"Device '{device_id}' is already registered.", "DEVICE_DUPLICATE", 409)


class ChamberNotFound(ColdSmartException):
    def __init__(self):
        super().__init__("Chamber not found.", "CHAMBER_NOT_FOUND", 404)


class AlertNotFound(ColdSmartException):
    def __init__(self):
        super().__init__("Alert not found.", "ALERT_NOT_FOUND", 404)


class OTAUpdateNotFound(ColdSmartException):
    def __init__(self):
        super().__init__("OTA update not found.", "OTA_NOT_FOUND", 404)


class InsufficientPermissions(ColdSmartException):
    def __init__(self, permission: str):
        super().__init__(f"Permission '{permission}' required.", "PERMISSION_DENIED", 403)


class InvalidCredentials(ColdSmartException):
    def __init__(self):
        super().__init__("Invalid credentials.", "INVALID_CREDENTIALS", 401)


class OTPExpired(ColdSmartException):
    def __init__(self):
        super().__init__("OTP has expired.", "OTP_EXPIRED", 400)


class OTPTooManyAttempts(ColdSmartException):
    def __init__(self):
        super().__init__("Too many OTP attempts. Please request a new OTP.", "OTP_RATE_LIMITED", 429)


class SessionExpired(ColdSmartException):
    def __init__(self):
        super().__init__("Session expired. Please log in again.", "SESSION_EXPIRED", 401)


class CompanyLimitExceeded(ColdSmartException):
    def __init__(self, limit: int):
        super().__init__(
            f"Device limit ({limit}) reached for your plan. Upgrade to add more devices.",
            "PLAN_DEVICE_LIMIT",
            402,
        )


class FirmwareChecksumMismatch(ColdSmartException):
    def __init__(self):
        super().__init__("Firmware checksum verification failed.", "FIRMWARE_CHECKSUM_FAIL", 400)


class ReportGenerationFailed(ColdSmartException):
    def __init__(self, reason: str):
        super().__init__(f"Report generation failed: {reason}", "REPORT_FAILED", 500)
