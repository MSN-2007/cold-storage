// ColdSmart Offline Sync Engine
// Drift local database schema for offline-first operation

import 'package:drift/drift.dart';
import 'connection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';

part 'drift_database.g.dart';

// ─── Tables ───────────────────────────────────────────────────────────────────

class DevicesTable extends Table {
  TextColumn get id => text()();
  TextColumn get deviceId => text()();
  TextColumn get name => text()();
  TextColumn get status => text().withDefault(const Constant('offline'))();
  TextColumn get location => text().nullable()();
  TextColumn get firmwareVersion => text().nullable()();
  RealColumn get healthScore => real().nullable()();
  TextColumn get lastSeenAt => text().nullable()();
  TextColumn get chambersJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ChamberReadingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get chamberId => text()();
  TextColumn get deviceId => text()();
  TextColumn get recordedAt => text()();
  RealColumn get temperature => real().nullable()();
  RealColumn get humidity => real().nullable()();
  RealColumn get co2 => real().nullable()();
  RealColumn get o2 => real().nullable()();
  RealColumn get ethylene => real().nullable()();
  RealColumn get carbonMonoxide => real().nullable()();
  RealColumn get methane => real().nullable()();
  RealColumn get healthScore => real().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

class AlertsTable extends Table {
  TextColumn get id => text()();
  TextColumn get deviceId => text()();
  TextColumn get chamberId => text().nullable()();
  TextColumn get severity => text()();
  TextColumn get status => text()();
  TextColumn get alertType => text()();
  TextColumn get title => text()();
  TextColumn get cause => text()();
  TextColumn get impact => text()();
  TextColumn get recommendedAction => text()();
  RealColumn get currentValue => real().nullable()();
  TextColumn get triggeredAt => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class GoodsBatchesTable extends Table {
  TextColumn get id => text()();
  TextColumn get chamberId => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  RealColumn get quantityKg => real().nullable()();
  TextColumn get stage => text()();
  TextColumn get harvestDate => text().nullable()();
  TextColumn get storageDate => text().nullable()();
  IntColumn get remainingShelfLifeDays => integer().nullable()();
  RealColumn get spoilageRiskScore => real().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class OfflineSyncQueueTable extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get action => text()(); // create | update | delete
  TextColumn get payloadJson => text()();
  TextColumn get clientTimestamp => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  BoolColumn get isProcessed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class CropProfilesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get profileType => text()();
  RealColumn get tempMin => real().nullable()();
  RealColumn get tempMax => real().nullable()();
  RealColumn get humidityMin => real().nullable()();
  RealColumn get humidityMax => real().nullable()();
  IntColumn get storageDurationDays => integer().nullable()();
  IntColumn get shelfLifeDays => integer().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get cachedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserPrefsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}


// ─── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  DevicesTable,
  ChamberReadingsTable,
  AlertsTable,
  GoodsBatchesTable,
  OfflineSyncQueueTable,
  CropProfilesTable,
  UserPrefsTable,
])
class ColdSmartDatabase extends _$ColdSmartDatabase {
  ColdSmartDatabase() : super(connect());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Future migration strategies here
    },
  );

  Future<void> seedData() async {
    final devices = await getAllDevices();
    if (devices.isNotEmpty) return;

    final now = DateTime.now().toIso8601String();
    
    final dev1Chambers = jsonEncode([
      {
        'id': 'chamber-uuid-1',
        'number': 1,
        'name': 'Chamber 1 - Apples',
        'crop': 'Royal Delicious Apple',
        'temp': 1.2,
        'target_temp': 1.0,
        'humidity': 92.4,
        'co2': 850,
        'o2': 2.1,
        'ethylene': 0.12,
        'health_score': 96.0,
      },
      {
        'id': 'chamber-uuid-2',
        'number': 2,
        'name': 'Chamber 2 - Potatoes',
        'crop': 'Russet Potato',
        'temp': 4.4,
        'target_temp': 4.0,
        'humidity': 90.1,
        'co2': 500,
        'o2': 2.0,
        'ethylene': 0.05,
        'health_score': 88.0,
      },
      {
        'id': 'chamber-uuid-3',
        'number': 3,
        'name': 'Chamber 3 - Seed Storage',
        'crop': 'Custom Grains',
        'temp': 8.5,
        'target_temp': 8.0,
        'humidity': 65.0,
        'co2': 400,
        'o2': 20.9,
        'ethylene': 0.0,
        'health_score': 95.0,
      },
      {
        'id': 'chamber-uuid-4',
        'number': 4,
        'name': 'Chamber 4 - Empty',
        'crop': 'None',
        'temp': 18.2,
        'target_temp': 15.0,
        'humidity': 45.2,
        'co2': 380,
        'o2': 20.9,
        'ethylene': 0.0,
        'health_score': 100.0,
      }
    ]);

    await upsertDevice(DevicesTableCompanion.insert(
      id: 'device-uuid-1',
      deviceId: 'CS-GW-001',
      name: 'Chamber 1-4 Gateway',
      status: const Value('online'),
      location: const Value('North Warehouse Block A'),
      firmwareVersion: const Value('v1.2.4'),
      healthScore: const Value(94.0),
      lastSeenAt: Value(now),
      chambersJson: Value(dev1Chambers),
      isSynced: const Value(true),
      updatedAt: now,
    ));

    await upsertDevice(DevicesTableCompanion.insert(
      id: 'device-uuid-2',
      deviceId: 'CS-ND-082',
      name: 'Potato Storage Unit 5',
      status: const Value('warning'),
      location: const Value('South Facility Shed B'),
      firmwareVersion: const Value('v1.2.3'),
      healthScore: const Value(78.5),
      lastSeenAt: Value(now),
      chambersJson: const Value('[]'),
      isSynced: const Value(true),
      updatedAt: now,
    ));

    await upsertDevice(DevicesTableCompanion.insert(
      id: 'device-uuid-3',
      deviceId: 'CS-GW-003',
      name: 'Apple Pre-Cooling Hub',
      status: const Value('offline'),
      location: const Value('Coldroom C3'),
      firmwareVersion: const Value('v1.2.4'),
      healthScore: const Value(0.0),
      lastSeenAt: Value(now),
      chambersJson: const Value('[]'),
      isSynced: const Value(true),
      updatedAt: now,
    ));

    await upsertAlert(AlertsTableCompanion.insert(
      id: 'alert-uuid-1',
      deviceId: 'CS-GW-001',
      chamberId: const Value('chamber-uuid-1'),
      severity: 'critical',
      status: 'active',
      alertType: 'temperature',
      title: 'Chamber 1 Critical Temperature High',
      cause: 'Chamber evaporator cooling coil detected icing or auxiliary fan failure, causing poor air circulation.',
      impact: 'Accelerated respiration rate in Royal Delicious Apples. If unresolved for 12 hours, shelf life is reduced by approx. 8-10 days.',
      recommendedAction: '1. Check the door seals and latch.\n2. Initiate a manual defrost cycle on the evaporator unit.\n3. Check the evaporator fan relay switch on the IoT node.',
      currentValue: const Value(1.2),
      triggeredAt: now,
      isRead: const Value(false),
      isSynced: const Value(true),
    ));

    await upsertAlert(AlertsTableCompanion.insert(
      id: 'alert-uuid-2',
      deviceId: 'CS-GW-001',
      chamberId: const Value('chamber-uuid-2'),
      severity: 'warning',
      status: 'active',
      alertType: 'humidity',
      title: 'Chamber 2 Humidity Warning Low',
      cause: 'Dehumidification cycles running too long or humidifier water valve blockage.',
      impact: 'Product weight loss and shriveling in Russet Potatoes. High shelf-life reduction potential.',
      recommendedAction: 'Check solenoid water valve of humidifier and clean feed pipe.',
      currentValue: const Value(88.2),
      triggeredAt: now,
      isRead: const Value(false),
      isSynced: const Value(true),
    ));

    await upsertAlert(AlertsTableCompanion.insert(
      id: 'alert-uuid-3',
      deviceId: 'CS-ND-082',
      chamberId: const Value('chamber-uuid-4'),
      severity: 'emergency',
      status: 'active',
      alertType: 'power_loss',
      title: 'Power Supply Disconnect Detected',
      cause: 'Main utility power breaker tripped or AC line disconnect.',
      impact: 'System shutdown in 2 hours on backup battery.',
      recommendedAction: 'Inspect facility breaker panel block D. Reset automatic switch.',
      currentValue: const Value(0.0),
      triggeredAt: now,
      isRead: const Value(false),
      isSynced: const Value(true),
    ));

    await upsertAlert(AlertsTableCompanion.insert(
      id: 'alert-uuid-4',
      deviceId: 'CS-GW-003',
      chamberId: const Value('chamber-uuid-3'),
      severity: 'info',
      status: 'acknowledged',
      alertType: 'sensor_drift',
      title: 'CO₂ Sensor Calibration Drift',
      cause: 'Normal NDIR sensor degradation over time.',
      impact: 'Minor sensor value deviations up to 25ppm.',
      recommendedAction: 'Re-calibrate sensor manually or schedule maintenance service.',
      currentValue: const Value(25.0),
      triggeredAt: now,
      isRead: const Value(true),
      isSynced: const Value(true),
    ));

    await upsertGoods(GoodsBatchesTableCompanion.insert(
      id: 'batch-uuid-1',
      chamberId: 'chamber-uuid-1',
      name: 'Himachal Apples Batch A',
      category: 'Apple',
      quantityKg: const Value(24500.0),
      stage: 'storage',
      remainingShelfLifeDays: const Value(120),
      spoilageRiskScore: const Value(12.0),
      createdAt: now,
    ));

    await upsertGoods(GoodsBatchesTableCompanion.insert(
      id: 'batch-uuid-2',
      chamberId: 'chamber-uuid-2',
      name: 'Shimla Potatoes Lot 2',
      category: 'Potato',
      quantityKg: const Value(18000.0),
      stage: 'storage',
      remainingShelfLifeDays: const Value(160),
      spoilageRiskScore: const Value(8.0),
      createdAt: now,
    ));
  }

  // ── Devices ───────────────────────────────────────────────────────────────

  Future<List<DevicesTableData>> getAllDevices() =>
      (select(devicesTable)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();

  Stream<List<DevicesTableData>> watchAllDevices() =>
      (select(devicesTable)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();

  Future<void> upsertDevice(DevicesTableCompanion device) =>
      into(devicesTable).insertOnConflictUpdate(device);

  // ── Sensor Readings ───────────────────────────────────────────────────────

  Future<List<ChamberReadingsTableData>> getReadingsForChamber(
    String chamberId, {
    int limit = 100,
  }) {
    return (select(chamberReadingsTable)
          ..where((t) => t.chamberId.equals(chamberId))
          ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)])
          ..limit(limit))
        .get();
  }

  Future<int> insertReading(ChamberReadingsTableCompanion reading) =>
      into(chamberReadingsTable).insert(reading);

  Future<List<ChamberReadingsTableData>> getUnsyncedReadings() =>
      (select(chamberReadingsTable)..where((t) => t.isSynced.equals(false))).get();

  Future<void> markReadingsSynced(List<int> ids) async {
    await (update(chamberReadingsTable)..where((t) => t.id.isIn(ids)))
        .write(const ChamberReadingsTableCompanion(isSynced: Value(true)));
  }

  // ── Alerts ────────────────────────────────────────────────────────────────

  Stream<List<AlertsTableData>> watchActiveAlerts() =>
      (select(alertsTable)
            ..where((t) => t.status.equals('active'))
            ..orderBy([(t) => OrderingTerm.desc(t.triggeredAt)]))
          .watch();

  Stream<List<AlertsTableData>> watchAllAlerts() =>
      (select(alertsTable)..orderBy([(t) => OrderingTerm.desc(t.triggeredAt)])).watch();

  Future<void> upsertAlert(AlertsTableCompanion alert) =>
      into(alertsTable).insertOnConflictUpdate(alert);

  Future<int> countUnreadAlerts() async {
    final result = await (selectOnly(alertsTable)
          ..addColumns([alertsTable.id.count()])
          ..where(alertsTable.isRead.equals(false)))
        .getSingle();
    return result.read(alertsTable.id.count()) ?? 0;
  }

  // ── Goods ─────────────────────────────────────────────────────────────────

  Future<List<GoodsBatchesTableData>> getGoodsForChamber(String chamberId) =>
      (select(goodsBatchesTable)..where((t) => t.chamberId.equals(chamberId))).get();

  Stream<List<GoodsBatchesTableData>> watchAllGoods() =>
      select(goodsBatchesTable).watch();

  Future<void> upsertGoods(GoodsBatchesTableCompanion goods) =>
      into(goodsBatchesTable).insertOnConflictUpdate(goods);

  // ── Offline Queue ─────────────────────────────────────────────────────────

  Future<List<OfflineSyncQueueTableData>> getPendingSyncItems() =>
      (select(offlineSyncQueueTable)..where((t) => t.isProcessed.equals(false)))
          .get();

  Future<void> addToSyncQueue(OfflineSyncQueueTableCompanion item) =>
      into(offlineSyncQueueTable).insert(item);

  Future<void> markSyncItemProcessed(String id) async {
    await (update(offlineSyncQueueTable)..where((t) => t.id.equals(id)))
        .write(const OfflineSyncQueueTableCompanion(isProcessed: Value(true)));
  }

  // ── User Prefs ────────────────────────────────────────────────────────────

  Future<String?> getPreference(String key) async {
    final result = await (select(userPrefsTable)..where((t) => t.key.equals(key))).getSingleOrNull();
    return result?.value;
  }

  Future<void> setPreference(String key, String value) =>
      into(userPrefsTable).insertOnConflictUpdate(
        UserPrefsTableCompanion(key: Value(key), value: Value(value)),
      );
}


// ─── Database Provider ────────────────────────────────────────────────────────

@riverpod
ColdSmartDatabase coldSmartDb(ColdSmartDbRef ref) {
  final db = ColdSmartDatabase();
  ref.onDispose(db.close);
  return db;
}
