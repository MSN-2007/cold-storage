# ❄️ ColdSmart – Cold Storage Operating System

**Intelligent Produce Preservation and Cold Storage Operating System**

> ColdSmart converts raw IoT sensor data into actionable preservation intelligence — helping farmers, cold storage operators, traders, and enterprises prevent spoilage, maximize shelf life, and protect inventory value.

---

## 🏗️ Architecture Overview

| Layer | Technology |
|---|---|
| Mobile App | Flutter 3.x + Riverpod 2 + Go Router + Drift |
| Backend API | FastAPI (Python 3.12) + Async SQLAlchemy |
| Database | PostgreSQL 16 + **TimescaleDB** (time-series) |
| MQTT Broker | **EMQX** 5.x |
| Real-time | MQTT + FastAPI WebSockets |
| Object Storage | MinIO (S3-compatible) |
| Cache | Redis 7 |
| Background Jobs | Celery |
| Auth | JWT (access 15min) + Refresh Tokens (30d) |
| Monitoring | Prometheus + Grafana |
| Deployment | Docker Compose → Kubernetes-ready |

---

## 🚀 Quick Start

### Prerequisites
- Docker Desktop 4.x+
- Docker Compose 2.x+

### 1. Clone and Configure
```bash
git clone <repo-url> cold_v1.0.1
cd cold_v1.0.1
cp .env.example .env
# Edit .env with your secrets
```

### 2. Start All Services
```bash
docker compose up -d
```

### 3. Verify
```bash
# API health
curl http://localhost:8000/health

# API docs
open http://localhost:8000/api/docs

# EMQX Dashboard
open http://localhost:18083

# Grafana
open http://localhost:3000

# MinIO Console
open http://localhost:9001
```

---

## 🌳 Project Structure

```
cold_v1.0.1/
├── backend/                    FastAPI + Python
│   ├── app/
│   │   ├── main.py            ← App entry + WebSocket + lifespan
│   │   ├── config.py          ← All settings (env vars)
│   │   ├── database.py        ← Async SQLAlchemy
│   │   ├── dependencies.py    ← Auth + RBAC dependencies
│   │   ├── models/            ← 20 SQLAlchemy ORM models
│   │   ├── routers/           ← API route handlers (12 modules)
│   │   ├── services/          ← Business logic services
│   │   │   ├── alert_engine.py         ← 8 sensor alert rules
│   │   │   ├── crop_intelligence.py    ← 12+ research-based profiles
│   │   │   ├── report_generator.py     ← PDF/Excel/CSV reports
│   │   │   └── notification_service.py ← FCM + SMS
│   │   ├── mqtt/
│   │   │   └── broker_client.py        ← EMQX integration
│   │   └── core/
│   │       ├── security.py             ← JWT + RBAC + device security
│   │       └── exceptions.py           ← Custom exceptions
│   ├── tests/
│   │   └── test_core.py                ← 24+ test cases
│   ├── requirements.txt
│   └── Dockerfile
├── mobile/                     Flutter App
│   ├── lib/
│   │   ├── main.dart                   ← App entry
│   │   ├── core/
│   │   │   ├── theme/app_theme.dart    ← Design system
│   │   │   ├── router/app_router.dart  ← Go Router
│   │   │   └── local_db/              ← Drift offline DB (7 tables)
│   │   └── features/                  ← 12 feature modules
│   │       └── dashboard/             ← Complete dashboard screen
│   └── pubspec.yaml
├── infra/                      Infrastructure
│   ├── nginx/nginx.conf                ← Reverse proxy + SSL
│   ├── postgres/init.sql               ← DB init + TimescaleDB
│   └── monitoring/prometheus.yml       ← Metrics collection
├── docker-compose.yml          ← 9 services orchestration
├── ARCHITECTURE.md             ← Complete system specification (16 sections)
└── README.md
```

---

## 🔑 Core Features

### For Farmers (Simple Mode)
- ✅ Dashboard: "What's wrong, where, how severe, what to do?"
- ✅ Real-time alerts with cause + impact + corrective action
- ✅ Remaining shelf life per batch
- ✅ Spoilage risk score
- ✅ Inventory value at risk

### For Operators (Expert Mode)
- ✅ 7-sensor monitoring (Temp, Humidity, CO₂, O₂, Ethylene, CO, CH₄)
- ✅ Historical graphs with TimescaleDB aggregates
- ✅ Parameter configuration with acceptable ranges
- ✅ Multi-chamber, multi-device fleet management

### Alert Engine
- ✅ 8 smart alert rules (Temperature high/low, Humidity high/low, CO₂, Ethylene, CO Emergency, Methane Emergency)
- ✅ Auto-deduplication (no duplicate alerts for same condition)
- ✅ Auto-resolution when condition clears
- ✅ FCM push notifications with severity emoji

### Crop Intelligence
- ✅ 12+ research-based profiles (USDA, FAO, UC Davis data)
- ✅ Q10 temperature coefficient shelf life calculator
- ✅ Custom profile support
- ✅ Maturity stage variants (e.g., green vs. ripe tomato)

### Security
- ✅ JWT access tokens (15 min) + refresh token rotation (30 days)
- ✅ 6-role RBAC with 40+ granular permissions
- ✅ Multi-tenant data isolation
- ✅ Per-device MQTT credentials with ACL
- ✅ OTA firmware HMAC-SHA256 signature + checksum verification

### Compliance Reports
- ✅ PDF (ReportLab with brand colors)
- ✅ Excel (OpenPyXL with charts)
- ✅ CSV (flat export)
- ✅ Temperature, Humidity, Gas, Alert, Audit, Maintenance reports

---

## 🌡️ Supported Produce Profiles

| Produce | Temp Range | Shelf Life |
|---|---|---|
| Tomato (green) | 12–15°C | 21 days |
| Tomato (ripe) | 7–10°C | 10 days |
| Potato | 4–7°C | 300 days |
| Onion | 0–2°C | 365 days |
| Apple (CA) | -1–1°C | 270 days |
| Mango | 10–13°C | 25 days |
| Banana | 13–15°C | 28 days |
| Grapes | -1–0°C | 180 days |
| Carrot | 0–1°C | 270 days |
| Leafy Veg | 0–2°C | 14 days |
| Cut Flowers | 1–3°C | 21 days |
| Pomegranate | 5–7°C | 120 days |

---

## 📡 MQTT Topic Structure

```
cs/{company_id}/device/{device_id}/
├── telemetry         ← Sensor readings (device → cloud, every 30s)
├── status            ← Heartbeat/online status
├── commands          ← Control commands (cloud → device)
└── ota/
    ├── start         ← OTA trigger
    ├── progress      ← Download/install progress
    └── result        ← Success/failure
```

---

## 🔐 User Roles

| Role | Key Permissions |
|---|---|
| Super Admin | Everything + multi-company management |
| Owner | Full access to their company |
| Manager | Operate + configure + report (no user delete) |
| Operator | Read + write sensor params + goods |
| Technician | Diagnostics + calibration + OTA |
| Viewer | Read-only access to all data |

---

## 🧪 Running Tests

### Backend
```bash
cd backend
pip install -r requirements.txt
pytest tests/ -v --cov=app --cov-report=html
```

### Flutter
```bash
cd mobile
flutter pub get
flutter test
flutter build apk --release
```

---

## 📊 Monitoring

| Service | URL | Credentials |
|---|---|---|
| Grafana | http://localhost:3000 | admin / (see .env) |
| Prometheus | http://localhost:9090 | - |
| EMQX Dashboard | http://localhost:18083 | admin / public |
| MinIO Console | http://localhost:9001 | (see .env) |
| API Docs | http://localhost:8000/api/docs | - |

---

## 🛠️ Environment Variables

Copy `.env.example` to `.env` and configure:

```env
SECRET_KEY=your-super-secret-key-change-this
DB_PASSWORD=coldsmart_pass
REDIS_PASSWORD=redis_pass
MINIO_ACCESS_KEY=coldsmart_minio
MINIO_SECRET_KEY=minio_secret_pass
FIREBASE_CREDENTIALS_PATH=/app/firebase-key.json
TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token
TWILIO_FROM_NUMBER=+1234567890
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
GRAFANA_PASSWORD=admin
ENVIRONMENT=production
```

---

## 📚 Documentation

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** — Complete 16-section technical specification
  - PRD, User Flows, Information Architecture
  - Database Schema + TimescaleDB Setup
  - Full API Specification (40+ endpoints)
  - Flutter Project Structure
  - FastAPI Project Structure
  - State Management Architecture
  - MQTT Architecture
  - Security Architecture
  - Offline Sync Architecture
  - OTA Architecture
  - UI/UX Screen List
  - Folder Structure
  - Deployment Architecture
  - Testing Strategy

---

## 🤝 License

Proprietary — ColdSmart v1.0.0 — All rights reserved.

---

*Built for India's cold storage sector. Designed for farmers. Powered by real-time IoT intelligence.*
