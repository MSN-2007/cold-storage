# ColdSmart – Complete System Architecture & PRD
## Production-Grade Cold Storage Operating System

---

## 1. Product Requirements Document (PRD)

### Executive Summary

ColdSmart is an Intelligent Produce Preservation and Cold Storage Operating System that converts raw IoT sensor data into actionable preservation intelligence. Unlike traditional sensor dashboards, ColdSmart focuses on **outcomes**: spoilage prevention, shelf life maximization, inventory value protection, and corrective action guidance.

### Problem Statement

India loses **40% of total produce** (₹92,000 crore annually) due to inadequate cold storage management. Primary causes:
- Reactive management (farmers don't know there's a problem until produce is damaged)
- No actionable guidance when problems occur
- No shelf life visibility until it's too late
- No multi-chamber intelligence or IoT integration at the farm level

### Target Users

| User | Pain Point | ColdSmart Solution |
|---|---|---|
| **Farmer** | "My produce spoiled and I didn't know why" | Real-time alerts with exact cause + corrective action |
| **Cold Storage Operator** | "Managing 20 chambers manually is impossible" | Unified fleet dashboard + automated alerts |
| **Trader/Exporter** | "I can't guarantee quality at destination" | Compliance reports + shelf life tracking |
| **Food Processor** | "Input quality varies too much" | Batch tracking + storage history |
| **Enterprise** | "No visibility across multiple locations" | Multi-tenant fleet management |

### Core Product Philosophy

> The app is NOT a sensor dashboard. It is an Intelligent Produce Preservation System.

**Users care about:**
1. Is my produce safe? (Spoilage risk)
2. How much time do I have? (Shelf life)
3. What is my inventory worth? (Inventory value at risk)
4. What should I do RIGHT NOW? (Corrective action)

**Users do NOT care about:** Raw sensor numbers first.

---

## 2. User Flows

### 2.1 Farmer Onboarding Flow
```
Download App → Register (Phone/OTP) → Company Created → Add Device (QR Scan) →
Add Chamber → Apply Crop Profile → Add Goods Batch → Dashboard Active
```

### 2.2 Alert Response Flow
```
Alert Triggered → Push Notification → Open App → Alert Detail
(Cause + Impact + Recommended Action) → Take Action → Acknowledge Alert →
Action Logged in Audit Trail
```

### 2.3 Device Onboarding Flow
```
Physical Device → Power On → Connect to WiFi → MQTT Connect →
App: Scan QR / Enter Device ID / Bluetooth Discovery → Pair Device →
Server Generates MQTT Credentials → Device Receives Credentials →
Live Data Flowing
```

### 2.4 Report Generation Flow
```
Reports Screen → Select Type (Temperature/Humidity/Gas/Audit) →
Select Devices + Date Range → Generate → Background Processing →
Download (PDF/Excel/CSV) → Share / Email
```

### 2.5 OTA Update Flow
```
Admin Uploads Firmware → Select Target Devices → Initiate Rollout →
MQTT Command Sent → Device Downloads from MinIO (Signed URL) →
Verifies SHA256 Checksum → Installs → Reports Success →
Admin Sees Status → Rollback Available for 24h
```

---

## 3. Information Architecture

```
ColdSmart App
├── Dashboard (Home)
│   ├── Fleet Status (Total/Healthy/Warning/Critical/Offline)
│   ├── Active Alerts (Critical First)
│   ├── Device Cards Grid
│   └── Quick Actions
├── My Storages (Devices)
│   ├── Device List
│   ├── Device Detail
│   │   ├── Chamber List
│   │   ├── Chamber Detail
│   │   │   ├── Current Readings (7 sensors)
│   │   │   ├── Historical Graphs
│   │   │   ├── Target/Range Settings
│   │   │   └── Goods Batches
│   │   └── Device Health
│   └── Add Device (QR/ID/Bluetooth)
├── Inventory (Goods)
│   ├── All Batches
│   ├── Add Batch
│   ├── Batch Detail (Shelf Life, Risk Score)
│   └── Crop Profiles
├── Alerts
│   ├── Active Alerts (Severity sorted)
│   ├── Alert History
│   └── Alert Detail (Cause + Impact + Action)
├── Reports
│   ├── Temperature Compliance
│   ├── Humidity Compliance
│   ├── Gas Compliance
│   ├── Alert Report
│   ├── Audit Report
│   └── Maintenance Report
├── Technician [Role-Gated]
│   ├── Diagnostics
│   ├── Calibration
│   ├── OTA Updates
│   └── Troubleshooting
├── Audit Logs [Manager+]
└── Settings
    ├── Profile
    ├── Notifications
    ├── App Mode (Simple/Expert)
    ├── Team Management
    └── Security
```

---

## 4. Database Schema

### TimescaleDB Hypertable Setup
```sql
-- After tables are created, run:
SELECT create_hypertable('sensor_readings', 'recorded_at', chunk_time_interval => INTERVAL '1 day');
SELECT add_compression_policy('sensor_readings', INTERVAL '30 days');
CREATE INDEX ON sensor_readings (chamber_id, recorded_at DESC);
CREATE INDEX ON sensor_readings (device_id, recorded_at DESC);

-- Continuous aggregate for hourly averages
CREATE MATERIALIZED VIEW sensor_hourly_avg
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 hour', recorded_at) AS bucket,
  chamber_id,
  AVG(temperature) AS avg_temperature,
  MIN(temperature) AS min_temperature,
  MAX(temperature) AS max_temperature,
  AVG(humidity) AS avg_humidity,
  AVG(co2) AS avg_co2,
  AVG(o2) AS avg_o2
FROM sensor_readings
GROUP BY bucket, chamber_id;

-- Daily summary view
CREATE MATERIALIZED VIEW sensor_daily_summary
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 day', recorded_at) AS day,
  chamber_id,
  device_id,
  AVG(temperature) AS avg_temp,
  MIN(temperature) AS min_temp,
  MAX(temperature) AS max_temp,
  AVG(humidity) AS avg_humidity,
  COUNT(*) AS reading_count
FROM sensor_readings
GROUP BY day, chamber_id, device_id;
```

### Entity Relationship Diagram
```
Companies (1) ──< Users (N)
Companies (1) ──< Devices (N)
Devices (1) ──< Chambers (N)
Chambers (1) ──< SensorReadings (TimeSeries)
Chambers (1) ──< GoodsBatches (N)
Chambers (1) ──< Alerts (N)
CropProfiles (1) ──< GoodsBatches (N)
Devices (M) ──< DeviceUsers >── (N) Users
OTAUpdates (1) ──< OTADeployments (N)
Users (1) ──< AuditLogs (N)
```

---

## 5. API Specifications

### Authentication
```
POST   /api/v1/auth/login/email          → JWT + Refresh Token
POST   /api/v1/auth/login/phone          → JWT + Refresh Token
POST   /api/v1/auth/otp/request          → Send OTP
POST   /api/v1/auth/otp/verify           → JWT + Refresh Token
POST   /api/v1/auth/refresh              → Rotate Refresh Token
POST   /api/v1/auth/logout               → Revoke Session
POST   /api/v1/auth/logout/all           → Revoke All Sessions
POST   /api/v1/auth/fcm-token            → Register Push Token
```

### Devices
```
GET    /api/v1/devices/                  → List fleet (paginated)
POST   /api/v1/devices/                  → Register device (+ QR + MQTT creds)
GET    /api/v1/devices/stats/summary     → Dashboard fleet summary
GET    /api/v1/devices/{id}              → Device detail + chambers
PUT    /api/v1/devices/{id}              → Update device metadata
DELETE /api/v1/devices/{id}             → Deactivate device
POST   /api/v1/devices/{id}/transfer-ownership → Transfer ownership
POST   /api/v1/devices/{id}/chambers     → Add chamber
PUT    /api/v1/devices/{id}/chambers/{cid}/parameters → Update chamber params
```

### Sensor Data
```
GET    /api/v1/sensor-data/{chamber_id}/latest    → Latest readings
GET    /api/v1/sensor-data/{chamber_id}/history   → Historical (time range, aggregation)
GET    /api/v1/sensor-data/{chamber_id}/stats     → Min/max/avg for period
```

### Goods & Inventory
```
GET    /api/v1/goods/                    → All batches (company)
POST   /api/v1/goods/                    → Add goods batch
GET    /api/v1/goods/{id}               → Batch detail + shelf life
PUT    /api/v1/goods/{id}               → Update batch
DELETE /api/v1/goods/{id}              → Remove/mark removed
GET    /api/v1/goods/chamber/{cid}      → Batches for chamber
```

### Crop Profiles
```
GET    /api/v1/crop-profiles/           → All profiles (system + company)
POST   /api/v1/crop-profiles/           → Create custom profile
GET    /api/v1/crop-profiles/{id}       → Profile detail
PUT    /api/v1/crop-profiles/{id}       → Update profile
DELETE /api/v1/crop-profiles/{id}      → Delete custom profile
GET    /api/v1/crop-profiles/search     → Search profiles by produce name
```

### Alerts
```
GET    /api/v1/alerts/                  → List alerts (filtered, paginated)
GET    /api/v1/alerts/{id}             → Alert detail
POST   /api/v1/alerts/{id}/acknowledge → Acknowledge alert
POST   /api/v1/alerts/{id}/resolve     → Mark resolved
GET    /api/v1/alerts/stats            → Alert stats for dashboard
```

### Reports
```
POST   /api/v1/reports/generate         → Trigger report generation (async)
GET    /api/v1/reports/                 → List generated reports
GET    /api/v1/reports/{id}            → Report status + download URL
DELETE /api/v1/reports/{id}           → Delete report
```

### OTA Updates
```
POST   /api/v1/ota/upload              → Upload firmware (multipart)
GET    /api/v1/ota/                    → List firmware versions
POST   /api/v1/ota/{id}/deploy        → Deploy to device(s)
GET    /api/v1/ota/devices/{did}/status → Deployment status
POST   /api/v1/ota/deployments/{id}/rollback → Rollback
```

### Diagnostics
```
POST   /api/v1/diagnostics/{device_id}/run    → Trigger diagnostics (via MQTT)
GET    /api/v1/diagnostics/{device_id}/results → Get latest results
POST   /api/v1/diagnostics/{device_id}/calibrate → Trigger calibration
```

### Audit
```
GET    /api/v1/audit/                   → Audit log (filtered, paginated)
GET    /api/v1/audit/user/{user_id}    → Audit for specific user
GET    /api/v1/audit/device/{device_id} → Audit for specific device
```

---

## 6. Flutter Project Structure

```
mobile/lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart              ✅ Complete (colors, typography, theme)
│   ├── router/
│   │   └── app_router.dart             ✅ Complete (Go Router + auth guards)
│   ├── local_db/
│   │   └── drift_database.dart         ✅ Complete (7 tables, offline-first)
│   ├── network/
│   │   ├── dio_client.dart             (Dio + interceptors + retry)
│   │   ├── auth_interceptor.dart       (JWT injection + refresh)
│   │   └── api_endpoints.dart          (All API constants)
│   ├── mqtt/
│   │   ├── mqtt_service.dart           (MQTT client + pub/sub)
│   │   └── mqtt_provider.dart          (Riverpod provider)
│   ├── sync/
│   │   ├── sync_engine.dart            (Offline sync queue processor)
│   │   └── conflict_resolver.dart      (Last-write-wins logic)
│   ├── security/
│   │   └── secure_storage.dart         (flutter_secure_storage wrapper)
│   ├── shell/
│   │   └── main_shell.dart             (Bottom nav shell)
│   └── widgets/
│       ├── cs_card.dart                (Brand card widget)
│       ├── cs_button.dart              (Primary/secondary buttons)
│       ├── cs_status_badge.dart        (Status indicator)
│       ├── cs_sensor_tile.dart         (Sensor reading tile)
│       ├── cs_gauge.dart               (Circular gauge widget)
│       └── cs_chart.dart               (fl_chart wrapper)
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository_impl.dart
│   │   │   └── auth_remote_datasource.dart
│   │   ├── domain/
│   │   │   ├── auth_repository.dart
│   │   │   ├── auth_provider.dart      (Riverpod auth state)
│   │   │   └── user_model.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── splash_screen.dart
│   │       │   ├── login_screen.dart   (Email/Phone + OTP toggle)
│   │       │   └── otp_screen.dart
│   │       └── widgets/
│   ├── dashboard/
│   │   ├── data/
│   │   ├── domain/
│   │   │   └── dashboard_provider.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── dashboard_screen.dart ✅ Complete
│   │       └── widgets/
│   │           ├── fleet_status_card.dart
│   │           ├── active_alert_card.dart
│   │           ├── storage_card.dart
│   │           └── quick_actions_row.dart
│   ├── devices/      (List, Detail, Add, Pair)
│   ├── chambers/     (Detail, Sensor Graphs, Parameter Edit)
│   ├── goods/        (Inventory, Add Batch, Shelf Life)
│   ├── crop_profiles/ (Browse, Detail, Custom)
│   ├── alerts/       (Center, Detail, History)
│   ├── reports/      (Generate, View, Download)
│   ├── technician/   (Diagnostics, Calibration, OTA)
│   ├── audit/        (Log viewer, Filters)
│   └── settings/     (Profile, Notifications, App Mode, Team)
└── main.dart                           ✅ Complete
```

---

## 7. FastAPI Project Structure

```
backend/app/
├── main.py                             ✅ Complete (App factory + WebSocket + lifespan)
├── config.py                           ✅ Complete (All settings)
├── database.py                         ✅ Complete (Async SQLAlchemy)
├── dependencies.py                     ✅ Complete (Auth + RBAC dependencies)
├── models/
│   └── __init__.py                     ✅ Complete (All 20 ORM models)
├── routers/
│   ├── auth.py                         ✅ Complete (Email/Phone/OTP/Refresh/Logout)
│   ├── devices.py                      ✅ Complete (CRUD + QR + MQTT + Transfer)
│   ├── chambers.py                     (Sensor data + parameter management)
│   ├── sensor_data.py                  (History + aggregates + export)
│   ├── goods.py                        (Inventory CRUD + shelf life)
│   ├── crop_profiles.py                (CRUD + search + system profiles)
│   ├── alerts.py                       (List + ack + resolve + stats)
│   ├── reports.py                      (Generate + download)
│   ├── ota.py                          (Upload + deploy + rollback)
│   ├── diagnostics.py                  (Run + results + calibrate)
│   ├── audit.py                        (Log viewer)
│   ├── users.py                        (User management)
│   └── websocket.py                    (Real-time bridge)
├── services/
│   ├── alert_engine.py                 ✅ Complete (8 alert rules)
│   ├── crop_intelligence.py            ✅ Complete (12+ profiles + Q10 shelf life)
│   ├── report_generator.py             ✅ Complete (PDF/Excel/CSV)
│   ├── notification_service.py         (FCM + SMS push)
│   ├── ota_service.py                  (MinIO + MQTT OTA flow)
│   └── sync_service.py                 (Offline queue processor)
├── mqtt/
│   └── broker_client.py                ✅ Complete (EMQX + message handler)
├── core/
│   ├── security.py                     ✅ Complete (JWT + RBAC + device security)
│   └── exceptions.py                   (Custom exception types)
└── migrations/                         (Alembic migrations)
```

---

## 8. State Management Architecture (Flutter)

```
Riverpod 2 + Clean Architecture

┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  Screens + Widgets ──► ConsumerWidget.watch(provider)      │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│                    State Layer (Riverpod)                   │
│  AsyncNotifierProvider ──► AsyncNotifier<T>                │
│  StateNotifierProvider ──► StateNotifier<T>                │
│  StreamProvider ──► Real-time streams (MQTT, WebSocket)     │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│                    Domain Layer                             │
│  Repository Interfaces + Use Cases + Business Entities     │
└──────────┬──────────────────────────────────────┬──────────┘
           │                                      │
┌──────────▼──────────┐              ┌────────────▼──────────┐
│   Remote DataSource  │              │   Local DataSource    │
│   Dio HTTP Client    │              │   Drift SQLite DB     │
│   MQTT Client        │              │   Secure Storage      │
│   WebSocket          │              │   SharedPreferences   │
└─────────────────────┘              └───────────────────────┘

Data Flow (Offline-First):
1. UI requests data → Repository
2. Repository returns LOCAL data immediately (optimistic UI)
3. Repository triggers background API sync
4. On sync success: update local DB → emit new state
5. On sync failure: queue in OfflineSyncQueue → retry on connectivity
```

---

## 9. MQTT Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    IoT Device (ESP32/STM32)                    │
│  Sensors: Temp, Humidity, CO₂, O₂, Ethylene, CO, CH₄          │
│  Publishes: cs/{company}/device/{id}/telemetry (every 30s)    │
│  Subscribes: cs/{company}/device/{id}/commands               │
│              cs/{company}/device/{id}/ota/start              │
└───────────────────────────┬─────────────────────────────────────┘
                            │ MQTT 5 (QoS 1, TLS)
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│                    EMQX Broker                                 │
│  Port 1883 (TCP) | Port 8083 (WS) | Port 8883 (SSL)          │
│  Authentication: Per-device credentials                        │
│  ACL: Device can only pub/sub its own topics                   │
│  Persistence: QoS 1 messages until acknowledged               │
└───────────────────────────┬─────────────────────────────────────┘
                            │ Wildcard subscriptions
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│                FastAPI MQTT Worker                             │
│  Subscribes: cs/+/device/+/telemetry                         │
│              cs/+/device/+/status                            │
│              cs/+/device/+/ota/progress                      │
│              cs/+/device/+/diagnostics/result                │
│  On message: validate → store → run alert engine → notify    │
└───────────────────────────┬─────────────────────────────────────┘
                            │ PostgreSQL LISTEN/NOTIFY
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│              FastAPI WebSocket Server                          │
│  Broadcasts alerts + telemetry to connected mobile clients    │
│  Authentication: JWT token in WebSocket URL param             │
│  Topic: /ws/{company_id}?token={access_token}                │
└───────────────────────────┬─────────────────────────────────────┘
                            │ WebSocket
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│              Flutter Mobile App (MQTT + WebSocket)             │
│  Primary: WebSocket for dashboard real-time                   │
│  Secondary: Direct MQTT over WS for low-latency sensors       │
└─────────────────────────────────────────────────────────────────┘

Topic Hierarchy:
cs/{company_id}/device/{device_id}/
├── telemetry         ← Sensor readings (device → cloud)
├── status            ← Heartbeat/online status
├── alerts            ← Alert notifications (cloud → device)
├── commands          ← Control commands (cloud → device)
└── ota/
    ├── start         ← OTA trigger (cloud → device)
    ├── progress      ← Download/install progress (device → cloud)
    └── result        ← Success/failure (device → cloud)
```

---

## 10. Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Security Layers                          │
├─────────────────────────────────────────────────────────────────┤
│ 1. Transport Security                                         │
│    • All API: HTTPS/TLS 1.3                                   │
│    • MQTT: TLS with device certificates                       │
│    • WebSocket: WSS                                           │
├─────────────────────────────────────────────────────────────────┤
│ 2. Authentication                                             │
│    • JWT Access Token (HS256, 15min)                          │
│    • Refresh Token (signed JWT + SHA256 hash stored in DB)    │
│    • Refresh token rotation on every use                      │
│    • OTP: 6-digit, HMAC-SHA256, 5min expiry, 5 attempt limit  │
├─────────────────────────────────────────────────────────────────┤
│ 3. Authorization (RBAC)                                       │
│    • 6 roles with 40+ granular permissions                    │
│    • Permission checked at dependency injection layer         │
│    • Company-scoped data isolation (multi-tenant)             │
│    • Device-level access control (DeviceUser table)           │
├─────────────────────────────────────────────────────────────────┤
│ 4. Device Security                                            │
│    • Unique MQTT credentials per device                       │
│    • EMQX ACL: device can only access its own topic space     │
│    • QR pairing with signed secret                            │
│    • OTA payload HMAC-SHA256 signature verification           │
│    • SHA256 firmware checksum before installation             │
├─────────────────────────────────────────────────────────────────┤
│ 5. Data Security                                              │
│    • Passwords: bcrypt (cost factor 12)                       │
│    • Sensitive device data: encrypted JSONB column            │
│    • Audit trail: immutable, timestamped                      │
│    • Multi-tenant isolation at DB query level                 │
├─────────────────────────────────────────────────────────────────┤
│ 6. Mobile Security                                            │
│    • Tokens in flutter_secure_storage (Keychain/Keystore)     │
│    • Biometric lock support                                   │
│    • Certificate pinning (production)                         │
│    • Jailbreak/root detection (production)                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 11. Offline Sync Architecture

```
Offline-First Strategy: Local DB is Source of Truth

Online Mode:
  App → Repository → [Local DB + Remote API] simultaneously

Offline Mode:
  App → Repository → Local DB only
  Failed API calls → OfflineSyncQueue (SQLite)

Return to Connectivity:
  SyncEngine monitors connectivity (connectivity_plus)
  On reconnect:
    1. Process OfflineSyncQueue items (FIFO, with retry)
    2. Fetch remote changes (server timestamp comparison)
    3. Conflict Resolution: Last-Write-Wins by default
       (server timestamp wins for critical data like alerts)
    4. Update Local DB with remote changes
    5. Emit new state to UI

Sync Queue Item Structure:
  { id, entity_type, entity_id, action, payload, client_timestamp, retry_count }

Conflict Resolution Strategy:
  - Sensor readings: Server wins (device is source of truth)
  - User-created goods: Client wins if server has no newer version
  - Parameter changes: Last-write wins (compare updated_at timestamps)
  - Alerts: Server wins always (generated by alert engine)
```

---

## 12. OTA Architecture

```
Phase 1: Upload
  Admin → API: POST /ota/upload (multipart firmware)
  → Backend: validate, compute SHA256, store in MinIO
  → DB: Create OTAUpdate record

Phase 2: Deploy
  Admin → API: POST /ota/{id}/deploy { device_ids: [...] }
  → DB: Create OTADeployment records (status: pending)
  → MQTT: Publish to cs/{company}/device/{id}/ota/start
    { firmware_url: signed_url, version, sha256, signature }

Phase 3: Device Download
  Device receives OTA start message
  → Verifies HMAC signature
  → Downloads firmware from MinIO (pre-signed URL, 1hr expiry)
  → Verifies SHA256 checksum
  → MQTT: Publish progress (0% → 100%)

Phase 4: Install
  Device enters install mode (write to secondary partition)
  → MQTT: Publishes installing status
  → Device reboots to new firmware
  → Reports success with new version

Phase 5: Rollback
  Device/Admin can trigger rollback
  → Device boots to backup partition (previous firmware)
  → MQTT: Reports rollback status
  → DB: Updates deployment to ROLLED_BACK

Failure Recovery:
  - Download failure: Retry 3 times with backoff
  - Install failure: Auto-boot to backup partition
  - Checksum mismatch: Discard and report failure
  - Signed URL expired: Request new URL from backend
```

---

## 13. Complete UI/UX Screen List

| Screen | Mode | Key Features |
|---|---|---|
| Splash | Both | Logo animation, auth check, deep link routing |
| Login | Both | Email/Phone toggle, password, OTP option |
| OTP Verify | Both | 6-digit input, countdown timer, resend |
| Dashboard | Simple | Fleet status, critical alerts, device cards, quick actions |
| Device List | Both | Search, filter by status, last updated |
| Device Detail | Expert | Status, chambers list, health score, last seen |
| Chamber Detail | Expert | Live readings, 7 sensor gauges, historical graphs |
| Parameter Edit | Expert | Set target values and acceptable ranges |
| Add Device | Both | QR scan, manual ID, Bluetooth discovery |
| Goods / Inventory | Simple | Batch list, shelf life countdown, spoilage risk |
| Add Goods | Simple | Name, quantity, harvest date, crop profile |
| Crop Profiles | Both | Browse system profiles, search by produce |
| Alert Center | Both | Severity sorted, acknowledge, action button |
| Alert Detail | Both | Cause + Impact + Recommended Action |
| Reports | Expert | Select type, date range, generate, download |
| Technician Hub | Technician | Diagnostics, calibration, OTA panel |
| Diagnostics | Expert | Per-sensor test, hardware test, one-click all |
| OTA Updates | Expert | Upload, rollout, progress tracking, rollback |
| Audit Log | Manager+ | Timeline, filter by user/device/action |
| Settings | Both | Profile, notifications, app mode, team |
| Notification Prefs | Both | Per-severity, per-device push settings |

---

## 14. Folder Structure (Complete Project)

```
cold_v1.0.1/
├── backend/                            FastAPI Backend
│   ├── app/
│   │   ├── main.py                     ✅
│   │   ├── config.py                   ✅
│   │   ├── database.py                 ✅
│   │   ├── dependencies.py             ✅
│   │   ├── models/__init__.py          ✅ (All 20 models)
│   │   ├── routers/
│   │   │   ├── auth.py                 ✅
│   │   │   ├── devices.py              ✅
│   │   │   └── [10 more routers]
│   │   ├── services/
│   │   │   ├── alert_engine.py         ✅
│   │   │   ├── crop_intelligence.py    ✅
│   │   │   ├── report_generator.py     ✅
│   │   │   └── [notification, ota, sync]
│   │   ├── mqtt/
│   │   │   └── broker_client.py        ✅
│   │   └── core/
│   │       └── security.py             ✅
│   ├── requirements.txt                ✅
│   └── Dockerfile                      ✅
├── mobile/                             Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart                   ✅
│   │   ├── core/
│   │   │   ├── theme/app_theme.dart    ✅ (Full design system)
│   │   │   ├── router/app_router.dart  ✅ (All 15+ routes)
│   │   │   └── local_db/drift_database.dart ✅ (7 tables)
│   │   └── features/
│   │       ├── dashboard/screens/      ✅
│   │       └── [11 more features]
│   └── pubspec.yaml                    ✅
├── docker-compose.yml                  ✅ (9 services)
├── infra/
│   ├── nginx/nginx.conf
│   ├── emqx/acl.conf
│   ├── postgres/init.sql
│   └── monitoring/
│       ├── prometheus.yml
│       └── grafana/
└── README.md
```

---

## 15. Deployment Architecture

```
Production Deployment (Docker → Kubernetes-ready)

Internet
    │ HTTPS/443
    ▼
┌──────────┐
│  Nginx   │ Rate limiting, SSL termination, reverse proxy
│  Proxy   │ Static files, gzip
└────┬─────┘
     │
┌────▼──────────────────────────────────────────────┐
│              Docker Compose Network               │
│                                                   │
│  ┌────────────┐  ┌────────────┐  ┌─────────────┐ │
│  │  FastAPI   │  │   EMQX     │  │    MinIO    │ │
│  │ (4 workers)│  │   MQTT     │  │   Storage   │ │
│  └─────┬──────┘  └─────┬──────┘  └─────────────┘ │
│        │               │                          │
│  ┌─────▼──────┐  ┌─────▼──────┐                  │
│  │ PostgreSQL │  │   Redis    │                   │
│  │ +TimescaleDB  │  (Cache+Queue)│                 │
│  └────────────┘  └────────────┘                  │
│                                                   │
│  ┌────────────┐  ┌────────────┐                  │
│  │   Celery   │  │ Prometheus │                   │
│  │  Worker    │  │ + Grafana  │                   │
│  └────────────┘  └────────────┘                  │
└───────────────────────────────────────────────────┘

Scaling Strategy:
  Phase 1 (Startup): Single Docker Compose server (4 cores, 8GB RAM)
    → Supports: 100 devices, 500 users
  Phase 2 (Growth): Docker Swarm / K3s
    → Supports: 1,000 devices, 5,000 users
  Phase 3 (Enterprise): Kubernetes + managed DB + CDN
    → Supports: 100,000+ devices
```

---

## 16. Testing Strategy

### Backend Tests (pytest)
```
tests/
├── unit/
│   ├── test_alert_engine.py          Alert rule evaluation for all 8 rules
│   ├── test_crop_intelligence.py     Profile lookup, shelf life calculation
│   ├── test_security.py              JWT creation, verification, RBAC
│   └── test_report_generator.py      PDF/Excel/CSV output validation
├── integration/
│   ├── test_auth.py                  Full auth flow (email/phone/OTP)
│   ├── test_devices.py               Device registration + MQTT creds
│   ├── test_sensor_ingestion.py      MQTT → DB → alert pipeline
│   └── test_offline_sync.py          Sync queue processing
└── e2e/
    └── test_full_flow.py             Device pair → data → alert → ack
```

### Flutter Tests
```
test/
├── unit/
│   ├── auth_provider_test.dart
│   ├── dashboard_provider_test.dart
│   └── sync_engine_test.dart
├── widget/
│   ├── dashboard_screen_test.dart
│   ├── alert_card_test.dart
│   └── sensor_gauge_test.dart
└── integration/
    └── device_onboarding_test.dart
```

### CI/CD Pipeline
```yaml
# GitHub Actions
on: [push, pull_request]
jobs:
  backend:
    - pytest --cov=app --cov-report=xml
    - mypy app/
    - ruff check app/
  mobile:
    - flutter test
    - flutter build apk --release
    - flutter build ios --release (macOS runner)
  deploy:
    - docker compose build
    - docker compose push
    - SSH deploy to production
```

---

## Crop Profile Reference Data

| Produce | Temp (°C) | Humidity (%) | CO₂ (ppm) | O₂ (%) | Shelf Life |
|---|---|---|---|---|---|
| Tomato (mature green) | 12–15 | 85–95 | 300–5000 | 3–21 | 21 days |
| Tomato (ripe) | 7–10 | 85–95 | 300–3000 | 3–21 | 10 days |
| Potato | 4–7 | 90–95 | 300–5000 | 1.5–21 | 300 days |
| Onion | 0–2 | 65–75 | 300–2000 | 1–21 | 365 days |
| Apple (CA) | -1–1 | 90–95 | 1000–3000 | 1–3 | 270 days |
| Mango | 10–13 | 85–95 | 300–5000 | 3–21 | 25 days |
| Banana | 13–15 | 90–95 | 300–5000 | 2–21 | 28 days |
| Grapes | -1–0 | 90–95 | 300–5000 | 2–21 | 180 days |
| Carrot | 0–1 | 95–100 | 300–5000 | 1–4 | 270 days |
| Leafy Veg | 0–2 | 95–100 | 300–2000 | 2–21 | 14 days |
| Cut Flowers | 1–3 | 90–95 | 300–5000 | 1–21 | 21 days |
| Pomegranate | 5–7 | 90–95 | 300–5000 | 3–21 | 120 days |

*Sources: USDA AH-66, FAO Cold Chain Guidelines, UC Davis PHT Center*
