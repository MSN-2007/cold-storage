"""
ColdSmart Backend Tests
Alert Engine + Crop Intelligence + Security + Auth
"""
import pytest
import asyncio
from unittest.mock import AsyncMock, MagicMock, patch
from datetime import datetime, timezone, timedelta
from uuid import uuid4

# ─── Alert Engine Tests ───────────────────────────────────────────────────────

class MockChamber:
    def __init__(self, **kwargs):
        self.id = uuid4()
        self.device_id = uuid4()
        self.name = "Test Chamber 1"
        self.chamber_number = 1
        for k, v in kwargs.items():
            setattr(self, k, v)


class TestAlertEngine:
    """Test all 8 alert rules with edge cases."""

    def setup_method(self):
        from app.models import Chamber
        self.chamber = MockChamber(
            temp_min=4.0, temp_max=7.0,
            humidity_min=90.0, humidity_max=95.0,
            co2_min=300.0, co2_max=5000.0,
            o2_min=1.5, o2_max=21.0,
            ethylene_max=0.5,
            co_max=25.0,
            methane_max=100.0,
        )

    def test_temperature_high_warning(self):
        from app.services.alert_engine import ALERT_RULES, AlertRule
        from app.models import AlertSeverity

        rule = next(r for r in ALERT_RULES if r.alert_type == "temperature_high")
        result = rule.evaluate({"temperature": 8.0}, self.chamber, None)

        assert result is not None
        assert result["alert_type"] == "temperature_high"
        assert result["severity"] == AlertSeverity.WARNING
        assert result["current_value"] == 8.0
        assert "cause" in result and len(result["cause"]) > 0
        assert "impact" in result and len(result["impact"]) > 0
        assert "recommended_action" in result and len(result["recommended_action"]) > 0

    def test_temperature_high_critical(self):
        from app.services.alert_engine import ALERT_RULES
        from app.models import AlertSeverity

        rule = next(r for r in ALERT_RULES if r.alert_type == "temperature_high")
        result = rule.evaluate({"temperature": 9.5}, self.chamber, None)  # +2.5 over max

        assert result is not None
        assert result["severity"] == AlertSeverity.CRITICAL

    def test_temperature_high_emergency(self):
        from app.services.alert_engine import ALERT_RULES
        from app.models import AlertSeverity

        rule = next(r for r in ALERT_RULES if r.alert_type == "temperature_high")
        result = rule.evaluate({"temperature": 13.0}, self.chamber, None)  # +6 over max

        assert result is not None
        assert result["severity"] == AlertSeverity.EMERGENCY

    def test_temperature_within_range_no_alert(self):
        from app.services.alert_engine import ALERT_RULES

        rule = next(r for r in ALERT_RULES if r.alert_type == "temperature_high")
        result = rule.evaluate({"temperature": 5.5}, self.chamber, None)
        assert result is None

    def test_humidity_low_alert(self):
        from app.services.alert_engine import ALERT_RULES
        from app.models import AlertSeverity

        rule = next(r for r in ALERT_RULES if r.alert_type == "humidity_low")
        result = rule.evaluate({"humidity": 85.0}, self.chamber, None)

        assert result is not None
        assert result["severity"] == AlertSeverity.WARNING

    def test_co_emergency_always(self):
        """Carbon monoxide alert should always be EMERGENCY."""
        from app.services.alert_engine import ALERT_RULES
        from app.models import AlertSeverity

        rule = next(r for r in ALERT_RULES if r.alert_type == "co_high")
        result = rule.evaluate({"carbon_monoxide": 30.0}, self.chamber, None)

        assert result is not None
        assert result["severity"] == AlertSeverity.EMERGENCY

    def test_methane_emergency_always(self):
        from app.services.alert_engine import ALERT_RULES
        from app.models import AlertSeverity

        rule = next(r for r in ALERT_RULES if r.alert_type == "methane_high")
        result = rule.evaluate({"methane": 150.0}, self.chamber, None)

        assert result is not None
        assert result["severity"] == AlertSeverity.EMERGENCY

    def test_missing_value_no_alert(self):
        """Rules should not fire if sensor value is missing."""
        from app.services.alert_engine import ALERT_RULES

        rule = next(r for r in ALERT_RULES if r.alert_type == "temperature_high")
        result = rule.evaluate({}, self.chamber, None)
        assert result is None

    def test_all_rules_have_required_fields(self):
        from app.services.alert_engine import ALERT_RULES

        for rule in ALERT_RULES:
            assert rule.alert_type
            assert rule.parameter
            assert rule.unit
            assert callable(rule.check_fn)
            assert callable(rule.severity_fn)
            assert callable(rule.title_fn)
            assert callable(rule.cause_fn)
            assert callable(rule.impact_fn)
            assert callable(rule.action_fn)


# ─── Crop Intelligence Tests ──────────────────────────────────────────────────

class TestCropIntelligence:
    def test_system_profiles_count(self):
        from app.services.crop_intelligence import get_system_profiles
        profiles = get_system_profiles()
        assert len(profiles) >= 10

    def test_all_profiles_have_required_fields(self):
        from app.services.crop_intelligence import get_system_profiles
        required = ["name", "category", "temp_min", "temp_max", "humidity_min", "humidity_max"]
        for profile in get_system_profiles():
            for field in required:
                assert field in profile, f"Profile {profile['name']} missing field: {field}"

    def test_profile_lookup_by_name(self):
        from app.services.crop_intelligence import get_profile_by_name
        profiles = get_profile_by_name("Apple")
        assert len(profiles) >= 1
        assert profiles[0]["name"] == "Apple"

    def test_shelf_life_calculation_at_optimal_temp(self):
        from app.services.crop_intelligence import calculate_shelf_life_remaining
        from datetime import datetime, timezone, timedelta

        storage_date = datetime.now(timezone.utc) - timedelta(days=10)
        remaining = calculate_shelf_life_remaining(
            harvest_date=None,
            storage_date=storage_date,
            storage_duration_days=300,  # Potato
            current_temp=5.0,
            optimal_temp=5.0,
        )
        # At optimal temp, should be 290 days remaining
        assert 285 <= remaining <= 295

    def test_shelf_life_reduced_at_high_temp(self):
        from app.services.crop_intelligence import calculate_shelf_life_remaining
        from datetime import datetime, timezone, timedelta

        storage_date = datetime.now(timezone.utc) - timedelta(days=10)
        remaining_high_temp = calculate_shelf_life_remaining(
            harvest_date=None,
            storage_date=storage_date,
            storage_duration_days=300,
            current_temp=15.0,  # 10°C above optimal
            optimal_temp=5.0,
        )
        remaining_optimal = calculate_shelf_life_remaining(
            harvest_date=None,
            storage_date=storage_date,
            storage_duration_days=300,
            current_temp=5.0,
            optimal_temp=5.0,
        )
        # High temp should reduce shelf life significantly
        assert remaining_high_temp < remaining_optimal

    def test_all_system_profiles_marked_as_system(self):
        from app.services.crop_intelligence import get_system_profiles
        for profile in get_system_profiles():
            assert profile["is_system"] is True


# ─── Security Tests ───────────────────────────────────────────────────────────

class TestSecurity:
    def test_password_hash_and_verify(self):
        from app.core.security import hash_password, verify_password
        plain = "SecurePassword123!"
        hashed = hash_password(plain)
        assert hashed != plain
        assert verify_password(plain, hashed)
        assert not verify_password("wrong_password", hashed)

    def test_access_token_creation_and_decode(self):
        from app.core.security import create_access_token, decode_token
        from app.models import UserRole

        user_id = uuid4()
        company_id = uuid4()
        token = create_access_token(user_id, company_id, UserRole.OWNER)

        assert token
        payload = decode_token(token)
        assert payload["sub"] == str(user_id)
        assert payload["company_id"] == str(company_id)
        assert payload["role"] == "owner"
        assert payload["type"] == "access"

    def test_refresh_token_creation(self):
        from app.core.security import create_refresh_token, decode_token, hash_token

        user_id = uuid4()
        session_id = uuid4()
        raw, hashed = create_refresh_token(user_id, session_id)

        assert raw != hashed
        payload = decode_token(raw)
        assert payload["type"] == "refresh"
        assert payload["sub"] == str(user_id)

    def test_rbac_super_admin_has_all_permissions(self):
        from app.core.security import has_permission, ROLE_PERMISSIONS
        from app.models import UserRole

        super_perms = ROLE_PERMISSIONS[UserRole.SUPER_ADMIN]
        owner_perms = ROLE_PERMISSIONS[UserRole.OWNER]

        # Super admin should have all owner permissions
        assert owner_perms.issubset(super_perms)

    def test_rbac_viewer_restricted(self):
        from app.core.security import has_permission
        from app.models import UserRole

        assert has_permission(UserRole.VIEWER, "device:read") is True
        assert has_permission(UserRole.VIEWER, "device:delete") is False
        assert has_permission(UserRole.VIEWER, "ota:deploy") is False
        assert has_permission(UserRole.VIEWER, "user:write") is False

    def test_otp_generation_is_numeric(self):
        from app.core.security import generate_otp
        otp = generate_otp(6)
        assert len(otp) == 6
        assert otp.isdigit()

    def test_mqtt_credentials_generation(self):
        from app.core.security import generate_mqtt_credentials
        creds = generate_mqtt_credentials("CS-001-ABCDEF", str(uuid4()))
        assert "mqtt_username" in creds
        assert "mqtt_password" in creds
        assert "mqtt_password_hash" in creds
        assert creds["mqtt_username"].startswith("device_")
        assert creds["mqtt_password"] != creds["mqtt_password_hash"]

    def test_ota_signature_verify(self):
        from app.core.security import sign_ota_payload, verify_ota_signature
        url = "https://minio.coldsmart.io/firmware/v2.0.0.bin"
        version = "2.0.0"
        checksum = "abc123def456"

        sig = sign_ota_payload(url, version, checksum)
        assert verify_ota_signature(url, version, checksum, sig) is True
        assert verify_ota_signature(url, "2.0.1", checksum, sig) is False


# ─── Hardening & QA Audit Tests ───────────────────────────────────────────────

class TestHardeningAndQA:
    def test_semantic_version_downgrade(self):
        from app.routers.ota import is_downgrade
        assert is_downgrade("1.0.0", "0.9.9") is True
        assert is_downgrade("1.2.0", "1.1.5") is True
        assert is_downgrade("2.0.0", "2.0.0") is False
        assert is_downgrade("1.5.0", "1.5.1") is False
        assert is_downgrade("v2.1.0", "v2.0.9") is True
        assert is_downgrade(None, "1.0.0") is False

    @pytest.mark.asyncio
    async def test_rate_limiter_in_memory_sliding_window(self):
        from app.dependencies import RateLimiter
        from fastapi import HTTPException
        
        # Limit: 3 requests per 2 seconds
        limiter = RateLimiter(3, 2, "test_limit")
        # Reset cache
        RateLimiter._in_memory_cache = {}
        
        # Should succeed 3 times
        mock_request = MagicMock()
        mock_request.client.host = "127.0.0.1"
        
        await limiter(mock_request, "client_1")
        await limiter(mock_request, "client_1")
        await limiter(mock_request, "client_1")
        
        # 4th time should raise 429 Too Many Requests
        with pytest.raises(HTTPException) as exc:
            await limiter(mock_request, "client_1")
        assert exc.value.status_code == 429


# ─── Configuration ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
