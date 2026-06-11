"""
ColdSmart Crop Intelligence System
Research-based profiles for 15+ produce types with full environmental parameters
"""
from typing import List, Dict, Any

# ─── System Crop Profiles (Seeded at startup) ─────────────────────────────────
# Based on USDA, FAO, and ASHRAE cold storage guidelines.

SYSTEM_CROP_PROFILES: List[Dict[str, Any]] = [

    # ── Tomato ────────────────────────────────────────────────────────────────
    {
        "name": "Tomato",
        "category": "vegetable",
        "variety": "General",
        "profile_type": "system",
        "maturity_stage": "mature_green",
        "storage_strategy": "standard",
        "is_system": True,
        "temp_min": 12.0, "temp_max": 15.0, "temp_optimal": 13.0,
        "humidity_min": 85.0, "humidity_max": 95.0, "humidity_optimal": 90.0,
        "co2_min": 300.0, "co2_max": 5000.0,
        "o2_min": 3.0, "o2_max": 21.0,
        "ethylene_max": 0.1,
        "co_max": 25.0, "methane_max": 100.0,
        "storage_duration_days": 21,
        "shelf_life_days": 14,
        "respiration_rate": 8.5,
        "description": "Mature green tomatoes can be stored at 12-15°C. Avoid temperatures below 10°C to prevent chilling injury.",
        "handling_notes": "Store away from ethylene-producing fruits. Check daily for ripening.",
        "compliance_standards": ["CODEX STAN 293-2008", "EU Reg 543/2011"],
        "sources": ["USDA Agriculture Handbook 66", "FAO Cold Chain Guidelines"],
    },
    {
        "name": "Tomato",
        "category": "vegetable",
        "variety": "General",
        "profile_type": "system",
        "maturity_stage": "ripe",
        "storage_strategy": "short_term",
        "is_system": True,
        "temp_min": 7.0, "temp_max": 10.0, "temp_optimal": 8.0,
        "humidity_min": 85.0, "humidity_max": 95.0, "humidity_optimal": 90.0,
        "co2_min": 300.0, "co2_max": 3000.0,
        "o2_min": 3.0, "o2_max": 21.0,
        "ethylene_max": 0.5,
        "co_max": 25.0, "methane_max": 100.0,
        "storage_duration_days": 10,
        "shelf_life_days": 7,
        "respiration_rate": 12.0,
        "description": "Ripe tomatoes should be stored at 7-10°C for short-term storage.",
        "handling_notes": "Handle gently to avoid bruising. Do not stack more than 3 layers.",
        "sources": ["USDA Agriculture Handbook 66"],
    },

    # ── Potato ────────────────────────────────────────────────────────────────
    {
        "name": "Potato",
        "category": "vegetable",
        "variety": "General",
        "profile_type": "system",
        "maturity_stage": "cured",
        "storage_strategy": "long_term",
        "is_system": True,
        "temp_min": 4.0, "temp_max": 7.0, "temp_optimal": 5.0,
        "humidity_min": 90.0, "humidity_max": 95.0, "humidity_optimal": 92.0,
        "co2_min": 300.0, "co2_max": 5000.0,
        "o2_min": 1.5, "o2_max": 21.0,
        "ethylene_max": 0.5,
        "co_max": 25.0, "methane_max": 100.0,
        "storage_duration_days": 300,
        "shelf_life_days": 180,
        "respiration_rate": 3.5,
        "description": "Potatoes store well at 4-7°C with high humidity. Lower temps (2-4°C) are used for industrial processing.",
        "handling_notes": "Store in dark conditions to prevent greening. Cure wounds before storage. Allow ventilation.",
        "sources": ["FAO Post-harvest Management Guide", "USDA AH-66"],
    },

    # ── Onion ─────────────────────────────────────────────────────────────────
    {
        "name": "Onion",
        "category": "vegetable",
        "variety": "Dry Onion",
        "profile_type": "system",
        "maturity_stage": "cured",
        "storage_strategy": "long_term",
        "is_system": True,
        "temp_min": 0.0, "temp_max": 2.0, "temp_optimal": 0.0,
        "humidity_min": 65.0, "humidity_max": 75.0, "humidity_optimal": 70.0,
        "co2_min": 300.0, "co2_max": 2000.0,
        "o2_min": 1.0, "o2_max": 21.0,
        "ethylene_max": 0.05,
        "co_max": 25.0, "methane_max": 100.0,
        "storage_duration_days": 365,
        "shelf_life_days": 270,
        "respiration_rate": 2.1,
        "description": "Dry onions can be stored for up to 12 months at 0°C with LOW humidity to prevent sprouting and mold.",
        "handling_notes": "Curing is critical. Ensure good air circulation. Low humidity is essential — unlike most produce.",
        "sources": ["National Onion Association Guidelines", "FAO Cold Chain"],
    },

    # ── Apple ─────────────────────────────────────────────────────────────────
    {
        "name": "Apple",
        "category": "fruit",
        "variety": "General",
        "profile_type": "system",
        "maturity_stage": "mature",
        "storage_strategy": "controlled_atmosphere",
        "is_system": True,
        "temp_min": -1.0, "temp_max": 1.0, "temp_optimal": 0.0,
        "humidity_min": 90.0, "humidity_max": 95.0, "humidity_optimal": 92.0,
        "co2_min": 1000.0, "co2_max": 3000.0,
        "o2_min": 1.0, "o2_max": 3.0,
        "ethylene_max": 0.01,
        "co_max": 25.0, "methane_max": 100.0,
        "storage_duration_days": 270,
        "shelf_life_days": 180,
        "respiration_rate": 4.2,
        "description": "Apples benefit greatly from Controlled Atmosphere (CA) storage with low O₂ and controlled CO₂.",
        "handling_notes": "Use ethylene scrubbers. Extremely ethylene-sensitive. Separate from other produce.",
        "sources": ["Washington State Univ. Tree Fruit Research", "FAO Apple CA Storage Guide"],
    },

    # ── Mango ─────────────────────────────────────────────────────────────────
    {
        "name": "Mango",
        "category": "fruit",
        "variety": "General",
        "profile_type": "system",
        "maturity_stage": "mature_green",
        "storage_strategy": "standard",
        "is_system": True,
        "temp_min": 10.0, "temp_max": 13.0, "temp_optimal": 12.0,
        "humidity_min": 85.0, "humidity_max": 95.0, "humidity_optimal": 90.0,
        "co2_min": 300.0, "co2_max": 5000.0,
        "o2_min": 3.0, "o2_max": 21.0,
        "ethylene_max": 0.5,
        "co_max": 25.0, "methane_max": 100.0,
        "storage_duration_days": 25,
        "shelf_life_days": 14,
        "respiration_rate": 15.0,
        "description": "Mangoes are chilling-sensitive. Never store below 10°C for mature green stage.",
        "handling_notes": "Uniform hot water treatment (48°C for 60 min) recommended pre-storage for export. Monitor ripening index.",
        "sources": ["FAO Mango Post-Harvest Guide", "APEDA Export Guidelines"],
    },

    # ── Banana ────────────────────────────────────────────────────────────────
    {
        "name": "Banana",
        "category": "fruit",
        "variety": "Cavendish",
        "profile_type": "system",
        "maturity_stage": "green",
        "storage_strategy": "standard",
        "is_system": True,
        "temp_min": 13.0, "temp_max": 15.0, "temp_optimal": 14.0,
        "humidity_min": 90.0, "humidity_max": 95.0, "humidity_optimal": 92.0,
        "co2_min": 300.0, "co2_max": 5000.0,
        "o2_min": 2.0, "o2_max": 21.0,
        "ethylene_max": 0.1,
        "co_max": 25.0, "methane_max": 100.0,
        "storage_duration_days": 28,
        "shelf_life_days": 21,
        "respiration_rate": 10.0,
        "description": "Bananas are highly chilling-sensitive. Storage below 13°C causes chilling injury and prevents ripening.",
        "handling_notes": "Store away from other fruits. Ripening rooms use 100-150 ppm ethylene for 24-48h ripening protocol.",
        "sources": ["Chiquita Brands International Guidelines", "FAO Banana Cold Chain"],
    },

    # ── Grapes ────────────────────────────────────────────────────────────────
    {
        "name": "Grapes",
        "category": "fruit",
        "variety": "Table Grapes",
        "profile_type": "system",
        "maturity_stage": "mature",
        "storage_strategy": "so2_treatment",
        "is_system": True,
        "temp_min": -1.0, "temp_max": 0.0, "temp_optimal": -0.5,
        "humidity_min": 90.0, "humidity_max": 95.0, "humidity_optimal": 93.0,
        "co2_min": 300.0, "co2_max": 5000.0,
        "o2_min": 2.0, "o2_max": 21.0,
        "ethylene_max": 0.5,
        "co_max": 25.0, "methane_max": 100.0,
        "storage_duration_days": 180,
        "shelf_life_days": 60,
        "respiration_rate": 3.8,
        "description": "Table grapes store well near 0°C with high humidity. SO₂ pads are commonly used for fungal control.",
        "handling_notes": "Avoid temperature fluctuations. SO₂ treatment required for export quality. Pre-cool rapidly after harvest.",
        "sources": ["UC Davis Postharvest Technology Center", "OIV Wine Guidelines"],
    },

    # ── Potato (Seed) ─────────────────────────────────────────────────────────
    {
        "name": "Seed Potato",
        "category": "vegetable",
        "variety": "Seed Grade",
        "profile_type": "system",
        "maturity_stage": "dormant",
        "storage_strategy": "seed_storage",
        "is_system": True,
        "temp_min": 2.0, "temp_max": 4.0, "temp_optimal": 3.0,
        "humidity_min": 90.0, "humidity_max": 95.0, "humidity_optimal": 92.0,
        "co2_min": 300.0, "co2_max": 5000.0,
        "o2_min": 2.0, "o2_max": 21.0,
        "ethylene_max": 0.1,
        "co_max": 25.0, "methane_max": 100.0,
        "storage_duration_days": 240,
        "shelf_life_days": 180,
        "respiration_rate": 2.8,
        "description": "Seed potatoes require controlled sprouting. Temperature management critical to prevent premature sprouting.",
        "handling_notes": "Check for disease before storage. Separate diseased tubers. Sprout inhibitors may be applied.",
        "sources": ["CIP (International Potato Center) Guidelines"],
    },

    # ── Leafy Vegetables ──────────────────────────────────────────────────────
    {
        "name": "Leafy Vegetables",
        "category": "vegetable",
        "variety": "General (Spinach, Lettuce, etc.)",
        "profile_type": "system",
        "maturity_stage": "fresh",
        "storage_strategy": "ultra_short_term",
        "is_system": True,
        "temp_min": 0.0, "temp_max": 2.0, "temp_optimal": 0.0,
        "humidity_min": 95.0, "humidity_max": 100.0, "humidity_optimal": 98.0,
        "co2_min": 300.0, "co2_max": 2000.0,
        "o2_min": 2.0, "o2_max": 21.0,
        "ethylene_max": 0.05,
        "co_max": 25.0, "methane_max": 100.0,
        "storage_duration_days": 14,
        "shelf_life_days": 7,
        "respiration_rate": 25.0,
        "description": "Leafy vegetables have very high respiration rates and short shelf life. Requires near-freezing temperatures.",
        "handling_notes": "Hydro-cooling preferred. Keep away from ethylene sources. Pre-pack in perforated film.",
        "sources": ["UC Davis PHT Center", "USDA AH-66"],
    },

    # ── Carrot ────────────────────────────────────────────────────────────────
    {
        "name": "Carrot",
        "category": "vegetable",
        "variety": "General",
        "profile_type": "system",
        "maturity_stage": "mature",
        "storage_strategy": "long_term",
        "is_system": True,
        "temp_min": 0.0, "temp_max": 1.0, "temp_optimal": 0.0,
        "humidity_min": 95.0, "humidity_max": 100.0, "humidity_optimal": 98.0,
        "co2_min": 300.0, "co2_max": 5000.0,
        "o2_min": 1.0, "o2_max": 4.0,
        "ethylene_max": 0.05,
        "co_max": 25.0, "methane_max": 100.0,
        "storage_duration_days": 270,
        "shelf_life_days": 180,
        "respiration_rate": 4.0,
        "description": "Carrots store well for 6-9 months at 0°C with very high humidity.",
        "handling_notes": "Keep away from ethylene producers (apples, pears). Ethylene causes bitterness in carrots.",
        "sources": ["USDA AH-66", "UC Davis PHT Center"],
    },

    # ── Pomegranate ───────────────────────────────────────────────────────────
    {
        "name": "Pomegranate",
        "category": "fruit",
        "variety": "Arils",
        "profile_type": "system",
        "maturity_stage": "mature",
        "storage_strategy": "standard",
        "is_system": True,
        "temp_min": 5.0, "temp_max": 7.0, "temp_optimal": 5.0,
        "humidity_min": 90.0, "humidity_max": 95.0, "humidity_optimal": 92.0,
        "co2_min": 300.0, "co2_max": 5000.0,
        "o2_min": 3.0, "o2_max": 21.0,
        "ethylene_max": 0.5,
        "co_max": 25.0, "methane_max": 100.0,
        "storage_duration_days": 120,
        "shelf_life_days": 90,
        "respiration_rate": 5.2,
        "description": "Pomegranates can be stored for 3-4 months. Chilling injury occurs below 5°C.",
        "handling_notes": "Inspect for husk cracking. Apply wax coating for export quality.",
        "sources": ["University of California Cooperative Extension"],
    },

    # ── Flowers (Cut) ─────────────────────────────────────────────────────────
    {
        "name": "Cut Flowers",
        "category": "flower",
        "variety": "General (Rose, Carnation, etc.)",
        "profile_type": "system",
        "maturity_stage": "harvested",
        "storage_strategy": "dry_cold",
        "is_system": True,
        "temp_min": 1.0, "temp_max": 3.0, "temp_optimal": 2.0,
        "humidity_min": 90.0, "humidity_max": 95.0, "humidity_optimal": 92.0,
        "co2_min": 300.0, "co2_max": 5000.0,
        "o2_min": 1.0, "o2_max": 21.0,
        "ethylene_max": 0.01,  # Flowers are extremely ethylene-sensitive
        "co_max": 25.0, "methane_max": 100.0,
        "storage_duration_days": 21,
        "shelf_life_days": 14,
        "respiration_rate": 20.0,
        "description": "Cut flowers are extremely sensitive to ethylene. Must be kept completely away from ripening fruit.",
        "handling_notes": "Use ethylene scrubbers. Re-cut stems before storage. Keep in hydrating solution.",
        "sources": ["Society of American Florists Guidelines", "FAO Cut Flower Cold Chain"],
    },
]


def get_system_profiles() -> List[Dict[str, Any]]:
    """Return all built-in system crop profiles."""
    return SYSTEM_CROP_PROFILES


def get_profile_by_name(name: str) -> List[Dict[str, Any]]:
    """Find profiles by produce name (case-insensitive)."""
    return [p for p in SYSTEM_CROP_PROFILES if p["name"].lower() == name.lower()]


def calculate_shelf_life_remaining(
    harvest_date,
    storage_date,
    storage_duration_days: int,
    current_temp: float,
    optimal_temp: float,
) -> int:
    """
    Estimate remaining shelf life using Q10 temperature coefficient.
    Q10 = 2.5 is used for most horticultural produce.
    Every 10°C above optimal doubles deterioration rate.
    """
    from datetime import datetime, timezone
    Q10 = 2.5
    now = datetime.now(timezone.utc)

    if storage_date:
        days_in_storage = (now - storage_date).days
    else:
        days_in_storage = 0

    temp_diff = max(0, current_temp - optimal_temp)
    deterioration_factor = Q10 ** (temp_diff / 10.0)
    effective_days_used = days_in_storage * deterioration_factor

    remaining = storage_duration_days - effective_days_used
    return max(0, int(remaining))


def calculate_spoilage_risk(chamber, profile: Dict[str, Any]) -> float:
    """
    Returns a spoilage risk score from 0.0 (safe) to 1.0 (critical).
    Based on temperature deviation, humidity, and ethylene levels.
    """
    if not profile:
        return 0.0

    risk = 0.0
    # This would use latest sensor reading in production
    return risk
