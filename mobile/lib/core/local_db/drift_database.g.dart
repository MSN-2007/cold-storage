// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $DevicesTableTable extends DevicesTable
    with TableInfo<$DevicesTableTable, DevicesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('offline'));
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _firmwareVersionMeta =
      const VerificationMeta('firmwareVersion');
  @override
  late final GeneratedColumn<String> firmwareVersion = GeneratedColumn<String>(
      'firmware_version', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _healthScoreMeta =
      const VerificationMeta('healthScore');
  @override
  late final GeneratedColumn<double> healthScore = GeneratedColumn<double>(
      'health_score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _lastSeenAtMeta =
      const VerificationMeta('lastSeenAt');
  @override
  late final GeneratedColumn<String> lastSeenAt = GeneratedColumn<String>(
      'last_seen_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chambersJsonMeta =
      const VerificationMeta('chambersJson');
  @override
  late final GeneratedColumn<String> chambersJson = GeneratedColumn<String>(
      'chambers_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deviceId,
        name,
        status,
        location,
        firmwareVersion,
        healthScore,
        lastSeenAt,
        chambersJson,
        isSynced,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices_table';
  @override
  VerificationContext validateIntegrity(Insertable<DevicesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('firmware_version')) {
      context.handle(
          _firmwareVersionMeta,
          firmwareVersion.isAcceptableOrUnknown(
              data['firmware_version']!, _firmwareVersionMeta));
    }
    if (data.containsKey('health_score')) {
      context.handle(
          _healthScoreMeta,
          healthScore.isAcceptableOrUnknown(
              data['health_score']!, _healthScoreMeta));
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
          _lastSeenAtMeta,
          lastSeenAt.isAcceptableOrUnknown(
              data['last_seen_at']!, _lastSeenAtMeta));
    }
    if (data.containsKey('chambers_json')) {
      context.handle(
          _chambersJsonMeta,
          chambersJson.isAcceptableOrUnknown(
              data['chambers_json']!, _chambersJsonMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DevicesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevicesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      firmwareVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}firmware_version']),
      healthScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}health_score']),
      lastSeenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_seen_at']),
      chambersJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chambers_json'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DevicesTableTable createAlias(String alias) {
    return $DevicesTableTable(attachedDatabase, alias);
  }
}

class DevicesTableData extends DataClass
    implements Insertable<DevicesTableData> {
  final String id;
  final String deviceId;
  final String name;
  final String status;
  final String? location;
  final String? firmwareVersion;
  final double? healthScore;
  final String? lastSeenAt;
  final String chambersJson;
  final bool isSynced;
  final String updatedAt;
  const DevicesTableData(
      {required this.id,
      required this.deviceId,
      required this.name,
      required this.status,
      this.location,
      this.firmwareVersion,
      this.healthScore,
      this.lastSeenAt,
      required this.chambersJson,
      required this.isSynced,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['name'] = Variable<String>(name);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || firmwareVersion != null) {
      map['firmware_version'] = Variable<String>(firmwareVersion);
    }
    if (!nullToAbsent || healthScore != null) {
      map['health_score'] = Variable<double>(healthScore);
    }
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<String>(lastSeenAt);
    }
    map['chambers_json'] = Variable<String>(chambersJson);
    map['is_synced'] = Variable<bool>(isSynced);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  DevicesTableCompanion toCompanion(bool nullToAbsent) {
    return DevicesTableCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      name: Value(name),
      status: Value(status),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      firmwareVersion: firmwareVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(firmwareVersion),
      healthScore: healthScore == null && nullToAbsent
          ? const Value.absent()
          : Value(healthScore),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      chambersJson: Value(chambersJson),
      isSynced: Value(isSynced),
      updatedAt: Value(updatedAt),
    );
  }

  factory DevicesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevicesTableData(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      status: serializer.fromJson<String>(json['status']),
      location: serializer.fromJson<String?>(json['location']),
      firmwareVersion: serializer.fromJson<String?>(json['firmwareVersion']),
      healthScore: serializer.fromJson<double?>(json['healthScore']),
      lastSeenAt: serializer.fromJson<String?>(json['lastSeenAt']),
      chambersJson: serializer.fromJson<String>(json['chambersJson']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'name': serializer.toJson<String>(name),
      'status': serializer.toJson<String>(status),
      'location': serializer.toJson<String?>(location),
      'firmwareVersion': serializer.toJson<String?>(firmwareVersion),
      'healthScore': serializer.toJson<double?>(healthScore),
      'lastSeenAt': serializer.toJson<String?>(lastSeenAt),
      'chambersJson': serializer.toJson<String>(chambersJson),
      'isSynced': serializer.toJson<bool>(isSynced),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  DevicesTableData copyWith(
          {String? id,
          String? deviceId,
          String? name,
          String? status,
          Value<String?> location = const Value.absent(),
          Value<String?> firmwareVersion = const Value.absent(),
          Value<double?> healthScore = const Value.absent(),
          Value<String?> lastSeenAt = const Value.absent(),
          String? chambersJson,
          bool? isSynced,
          String? updatedAt}) =>
      DevicesTableData(
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        name: name ?? this.name,
        status: status ?? this.status,
        location: location.present ? location.value : this.location,
        firmwareVersion: firmwareVersion.present
            ? firmwareVersion.value
            : this.firmwareVersion,
        healthScore: healthScore.present ? healthScore.value : this.healthScore,
        lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
        chambersJson: chambersJson ?? this.chambersJson,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DevicesTableData copyWithCompanion(DevicesTableCompanion data) {
    return DevicesTableData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      location: data.location.present ? data.location.value : this.location,
      firmwareVersion: data.firmwareVersion.present
          ? data.firmwareVersion.value
          : this.firmwareVersion,
      healthScore:
          data.healthScore.present ? data.healthScore.value : this.healthScore,
      lastSeenAt:
          data.lastSeenAt.present ? data.lastSeenAt.value : this.lastSeenAt,
      chambersJson: data.chambersJson.present
          ? data.chambersJson.value
          : this.chambersJson,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevicesTableData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('location: $location, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('healthScore: $healthScore, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('chambersJson: $chambersJson, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      deviceId,
      name,
      status,
      location,
      firmwareVersion,
      healthScore,
      lastSeenAt,
      chambersJson,
      isSynced,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevicesTableData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.status == this.status &&
          other.location == this.location &&
          other.firmwareVersion == this.firmwareVersion &&
          other.healthScore == this.healthScore &&
          other.lastSeenAt == this.lastSeenAt &&
          other.chambersJson == this.chambersJson &&
          other.isSynced == this.isSynced &&
          other.updatedAt == this.updatedAt);
}

class DevicesTableCompanion extends UpdateCompanion<DevicesTableData> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<String> name;
  final Value<String> status;
  final Value<String?> location;
  final Value<String?> firmwareVersion;
  final Value<double?> healthScore;
  final Value<String?> lastSeenAt;
  final Value<String> chambersJson;
  final Value<bool> isSynced;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const DevicesTableCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.location = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.healthScore = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.chambersJson = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesTableCompanion.insert({
    required String id,
    required String deviceId,
    required String name,
    this.status = const Value.absent(),
    this.location = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.healthScore = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.chambersJson = const Value.absent(),
    this.isSynced = const Value.absent(),
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        name = Value(name),
        updatedAt = Value(updatedAt);
  static Insertable<DevicesTableData> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<String>? status,
    Expression<String>? location,
    Expression<String>? firmwareVersion,
    Expression<double>? healthScore,
    Expression<String>? lastSeenAt,
    Expression<String>? chambersJson,
    Expression<bool>? isSynced,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (location != null) 'location': location,
      if (firmwareVersion != null) 'firmware_version': firmwareVersion,
      if (healthScore != null) 'health_score': healthScore,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (chambersJson != null) 'chambers_json': chambersJson,
      if (isSynced != null) 'is_synced': isSynced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? deviceId,
      Value<String>? name,
      Value<String>? status,
      Value<String?>? location,
      Value<String?>? firmwareVersion,
      Value<double?>? healthScore,
      Value<String?>? lastSeenAt,
      Value<String>? chambersJson,
      Value<bool>? isSynced,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return DevicesTableCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      status: status ?? this.status,
      location: location ?? this.location,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      healthScore: healthScore ?? this.healthScore,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      chambersJson: chambersJson ?? this.chambersJson,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (firmwareVersion.present) {
      map['firmware_version'] = Variable<String>(firmwareVersion.value);
    }
    if (healthScore.present) {
      map['health_score'] = Variable<double>(healthScore.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<String>(lastSeenAt.value);
    }
    if (chambersJson.present) {
      map['chambers_json'] = Variable<String>(chambersJson.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesTableCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('location: $location, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('healthScore: $healthScore, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('chambersJson: $chambersJson, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChamberReadingsTableTable extends ChamberReadingsTable
    with TableInfo<$ChamberReadingsTableTable, ChamberReadingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChamberReadingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _chamberIdMeta =
      const VerificationMeta('chamberId');
  @override
  late final GeneratedColumn<String> chamberId = GeneratedColumn<String>(
      'chamber_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<String> recordedAt = GeneratedColumn<String>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _temperatureMeta =
      const VerificationMeta('temperature');
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
      'temperature', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _humidityMeta =
      const VerificationMeta('humidity');
  @override
  late final GeneratedColumn<double> humidity = GeneratedColumn<double>(
      'humidity', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _co2Meta = const VerificationMeta('co2');
  @override
  late final GeneratedColumn<double> co2 = GeneratedColumn<double>(
      'co2', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _o2Meta = const VerificationMeta('o2');
  @override
  late final GeneratedColumn<double> o2 = GeneratedColumn<double>(
      'o2', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _ethyleneMeta =
      const VerificationMeta('ethylene');
  @override
  late final GeneratedColumn<double> ethylene = GeneratedColumn<double>(
      'ethylene', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _carbonMonoxideMeta =
      const VerificationMeta('carbonMonoxide');
  @override
  late final GeneratedColumn<double> carbonMonoxide = GeneratedColumn<double>(
      'carbon_monoxide', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _methaneMeta =
      const VerificationMeta('methane');
  @override
  late final GeneratedColumn<double> methane = GeneratedColumn<double>(
      'methane', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _healthScoreMeta =
      const VerificationMeta('healthScore');
  @override
  late final GeneratedColumn<double> healthScore = GeneratedColumn<double>(
      'health_score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chamberId,
        deviceId,
        recordedAt,
        temperature,
        humidity,
        co2,
        o2,
        ethylene,
        carbonMonoxide,
        methane,
        healthScore,
        isSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chamber_readings_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ChamberReadingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chamber_id')) {
      context.handle(_chamberIdMeta,
          chamberId.isAcceptableOrUnknown(data['chamber_id']!, _chamberIdMeta));
    } else if (isInserting) {
      context.missing(_chamberIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('temperature')) {
      context.handle(
          _temperatureMeta,
          temperature.isAcceptableOrUnknown(
              data['temperature']!, _temperatureMeta));
    }
    if (data.containsKey('humidity')) {
      context.handle(_humidityMeta,
          humidity.isAcceptableOrUnknown(data['humidity']!, _humidityMeta));
    }
    if (data.containsKey('co2')) {
      context.handle(
          _co2Meta, co2.isAcceptableOrUnknown(data['co2']!, _co2Meta));
    }
    if (data.containsKey('o2')) {
      context.handle(_o2Meta, o2.isAcceptableOrUnknown(data['o2']!, _o2Meta));
    }
    if (data.containsKey('ethylene')) {
      context.handle(_ethyleneMeta,
          ethylene.isAcceptableOrUnknown(data['ethylene']!, _ethyleneMeta));
    }
    if (data.containsKey('carbon_monoxide')) {
      context.handle(
          _carbonMonoxideMeta,
          carbonMonoxide.isAcceptableOrUnknown(
              data['carbon_monoxide']!, _carbonMonoxideMeta));
    }
    if (data.containsKey('methane')) {
      context.handle(_methaneMeta,
          methane.isAcceptableOrUnknown(data['methane']!, _methaneMeta));
    }
    if (data.containsKey('health_score')) {
      context.handle(
          _healthScoreMeta,
          healthScore.isAcceptableOrUnknown(
              data['health_score']!, _healthScoreMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChamberReadingsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChamberReadingsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      chamberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chamber_id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recorded_at'])!,
      temperature: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}temperature']),
      humidity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}humidity']),
      co2: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}co2']),
      o2: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}o2']),
      ethylene: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ethylene']),
      carbonMonoxide: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbon_monoxide']),
      methane: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}methane']),
      healthScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}health_score']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $ChamberReadingsTableTable createAlias(String alias) {
    return $ChamberReadingsTableTable(attachedDatabase, alias);
  }
}

class ChamberReadingsTableData extends DataClass
    implements Insertable<ChamberReadingsTableData> {
  final int id;
  final String chamberId;
  final String deviceId;
  final String recordedAt;
  final double? temperature;
  final double? humidity;
  final double? co2;
  final double? o2;
  final double? ethylene;
  final double? carbonMonoxide;
  final double? methane;
  final double? healthScore;
  final bool isSynced;
  const ChamberReadingsTableData(
      {required this.id,
      required this.chamberId,
      required this.deviceId,
      required this.recordedAt,
      this.temperature,
      this.humidity,
      this.co2,
      this.o2,
      this.ethylene,
      this.carbonMonoxide,
      this.methane,
      this.healthScore,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chamber_id'] = Variable<String>(chamberId);
    map['device_id'] = Variable<String>(deviceId);
    map['recorded_at'] = Variable<String>(recordedAt);
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<double>(temperature);
    }
    if (!nullToAbsent || humidity != null) {
      map['humidity'] = Variable<double>(humidity);
    }
    if (!nullToAbsent || co2 != null) {
      map['co2'] = Variable<double>(co2);
    }
    if (!nullToAbsent || o2 != null) {
      map['o2'] = Variable<double>(o2);
    }
    if (!nullToAbsent || ethylene != null) {
      map['ethylene'] = Variable<double>(ethylene);
    }
    if (!nullToAbsent || carbonMonoxide != null) {
      map['carbon_monoxide'] = Variable<double>(carbonMonoxide);
    }
    if (!nullToAbsent || methane != null) {
      map['methane'] = Variable<double>(methane);
    }
    if (!nullToAbsent || healthScore != null) {
      map['health_score'] = Variable<double>(healthScore);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  ChamberReadingsTableCompanion toCompanion(bool nullToAbsent) {
    return ChamberReadingsTableCompanion(
      id: Value(id),
      chamberId: Value(chamberId),
      deviceId: Value(deviceId),
      recordedAt: Value(recordedAt),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      humidity: humidity == null && nullToAbsent
          ? const Value.absent()
          : Value(humidity),
      co2: co2 == null && nullToAbsent ? const Value.absent() : Value(co2),
      o2: o2 == null && nullToAbsent ? const Value.absent() : Value(o2),
      ethylene: ethylene == null && nullToAbsent
          ? const Value.absent()
          : Value(ethylene),
      carbonMonoxide: carbonMonoxide == null && nullToAbsent
          ? const Value.absent()
          : Value(carbonMonoxide),
      methane: methane == null && nullToAbsent
          ? const Value.absent()
          : Value(methane),
      healthScore: healthScore == null && nullToAbsent
          ? const Value.absent()
          : Value(healthScore),
      isSynced: Value(isSynced),
    );
  }

  factory ChamberReadingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChamberReadingsTableData(
      id: serializer.fromJson<int>(json['id']),
      chamberId: serializer.fromJson<String>(json['chamberId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      recordedAt: serializer.fromJson<String>(json['recordedAt']),
      temperature: serializer.fromJson<double?>(json['temperature']),
      humidity: serializer.fromJson<double?>(json['humidity']),
      co2: serializer.fromJson<double?>(json['co2']),
      o2: serializer.fromJson<double?>(json['o2']),
      ethylene: serializer.fromJson<double?>(json['ethylene']),
      carbonMonoxide: serializer.fromJson<double?>(json['carbonMonoxide']),
      methane: serializer.fromJson<double?>(json['methane']),
      healthScore: serializer.fromJson<double?>(json['healthScore']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chamberId': serializer.toJson<String>(chamberId),
      'deviceId': serializer.toJson<String>(deviceId),
      'recordedAt': serializer.toJson<String>(recordedAt),
      'temperature': serializer.toJson<double?>(temperature),
      'humidity': serializer.toJson<double?>(humidity),
      'co2': serializer.toJson<double?>(co2),
      'o2': serializer.toJson<double?>(o2),
      'ethylene': serializer.toJson<double?>(ethylene),
      'carbonMonoxide': serializer.toJson<double?>(carbonMonoxide),
      'methane': serializer.toJson<double?>(methane),
      'healthScore': serializer.toJson<double?>(healthScore),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  ChamberReadingsTableData copyWith(
          {int? id,
          String? chamberId,
          String? deviceId,
          String? recordedAt,
          Value<double?> temperature = const Value.absent(),
          Value<double?> humidity = const Value.absent(),
          Value<double?> co2 = const Value.absent(),
          Value<double?> o2 = const Value.absent(),
          Value<double?> ethylene = const Value.absent(),
          Value<double?> carbonMonoxide = const Value.absent(),
          Value<double?> methane = const Value.absent(),
          Value<double?> healthScore = const Value.absent(),
          bool? isSynced}) =>
      ChamberReadingsTableData(
        id: id ?? this.id,
        chamberId: chamberId ?? this.chamberId,
        deviceId: deviceId ?? this.deviceId,
        recordedAt: recordedAt ?? this.recordedAt,
        temperature: temperature.present ? temperature.value : this.temperature,
        humidity: humidity.present ? humidity.value : this.humidity,
        co2: co2.present ? co2.value : this.co2,
        o2: o2.present ? o2.value : this.o2,
        ethylene: ethylene.present ? ethylene.value : this.ethylene,
        carbonMonoxide:
            carbonMonoxide.present ? carbonMonoxide.value : this.carbonMonoxide,
        methane: methane.present ? methane.value : this.methane,
        healthScore: healthScore.present ? healthScore.value : this.healthScore,
        isSynced: isSynced ?? this.isSynced,
      );
  ChamberReadingsTableData copyWithCompanion(
      ChamberReadingsTableCompanion data) {
    return ChamberReadingsTableData(
      id: data.id.present ? data.id.value : this.id,
      chamberId: data.chamberId.present ? data.chamberId.value : this.chamberId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      temperature:
          data.temperature.present ? data.temperature.value : this.temperature,
      humidity: data.humidity.present ? data.humidity.value : this.humidity,
      co2: data.co2.present ? data.co2.value : this.co2,
      o2: data.o2.present ? data.o2.value : this.o2,
      ethylene: data.ethylene.present ? data.ethylene.value : this.ethylene,
      carbonMonoxide: data.carbonMonoxide.present
          ? data.carbonMonoxide.value
          : this.carbonMonoxide,
      methane: data.methane.present ? data.methane.value : this.methane,
      healthScore:
          data.healthScore.present ? data.healthScore.value : this.healthScore,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChamberReadingsTableData(')
          ..write('id: $id, ')
          ..write('chamberId: $chamberId, ')
          ..write('deviceId: $deviceId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('temperature: $temperature, ')
          ..write('humidity: $humidity, ')
          ..write('co2: $co2, ')
          ..write('o2: $o2, ')
          ..write('ethylene: $ethylene, ')
          ..write('carbonMonoxide: $carbonMonoxide, ')
          ..write('methane: $methane, ')
          ..write('healthScore: $healthScore, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      chamberId,
      deviceId,
      recordedAt,
      temperature,
      humidity,
      co2,
      o2,
      ethylene,
      carbonMonoxide,
      methane,
      healthScore,
      isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChamberReadingsTableData &&
          other.id == this.id &&
          other.chamberId == this.chamberId &&
          other.deviceId == this.deviceId &&
          other.recordedAt == this.recordedAt &&
          other.temperature == this.temperature &&
          other.humidity == this.humidity &&
          other.co2 == this.co2 &&
          other.o2 == this.o2 &&
          other.ethylene == this.ethylene &&
          other.carbonMonoxide == this.carbonMonoxide &&
          other.methane == this.methane &&
          other.healthScore == this.healthScore &&
          other.isSynced == this.isSynced);
}

class ChamberReadingsTableCompanion
    extends UpdateCompanion<ChamberReadingsTableData> {
  final Value<int> id;
  final Value<String> chamberId;
  final Value<String> deviceId;
  final Value<String> recordedAt;
  final Value<double?> temperature;
  final Value<double?> humidity;
  final Value<double?> co2;
  final Value<double?> o2;
  final Value<double?> ethylene;
  final Value<double?> carbonMonoxide;
  final Value<double?> methane;
  final Value<double?> healthScore;
  final Value<bool> isSynced;
  const ChamberReadingsTableCompanion({
    this.id = const Value.absent(),
    this.chamberId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.temperature = const Value.absent(),
    this.humidity = const Value.absent(),
    this.co2 = const Value.absent(),
    this.o2 = const Value.absent(),
    this.ethylene = const Value.absent(),
    this.carbonMonoxide = const Value.absent(),
    this.methane = const Value.absent(),
    this.healthScore = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  ChamberReadingsTableCompanion.insert({
    this.id = const Value.absent(),
    required String chamberId,
    required String deviceId,
    required String recordedAt,
    this.temperature = const Value.absent(),
    this.humidity = const Value.absent(),
    this.co2 = const Value.absent(),
    this.o2 = const Value.absent(),
    this.ethylene = const Value.absent(),
    this.carbonMonoxide = const Value.absent(),
    this.methane = const Value.absent(),
    this.healthScore = const Value.absent(),
    this.isSynced = const Value.absent(),
  })  : chamberId = Value(chamberId),
        deviceId = Value(deviceId),
        recordedAt = Value(recordedAt);
  static Insertable<ChamberReadingsTableData> custom({
    Expression<int>? id,
    Expression<String>? chamberId,
    Expression<String>? deviceId,
    Expression<String>? recordedAt,
    Expression<double>? temperature,
    Expression<double>? humidity,
    Expression<double>? co2,
    Expression<double>? o2,
    Expression<double>? ethylene,
    Expression<double>? carbonMonoxide,
    Expression<double>? methane,
    Expression<double>? healthScore,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chamberId != null) 'chamber_id': chamberId,
      if (deviceId != null) 'device_id': deviceId,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (temperature != null) 'temperature': temperature,
      if (humidity != null) 'humidity': humidity,
      if (co2 != null) 'co2': co2,
      if (o2 != null) 'o2': o2,
      if (ethylene != null) 'ethylene': ethylene,
      if (carbonMonoxide != null) 'carbon_monoxide': carbonMonoxide,
      if (methane != null) 'methane': methane,
      if (healthScore != null) 'health_score': healthScore,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  ChamberReadingsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? chamberId,
      Value<String>? deviceId,
      Value<String>? recordedAt,
      Value<double?>? temperature,
      Value<double?>? humidity,
      Value<double?>? co2,
      Value<double?>? o2,
      Value<double?>? ethylene,
      Value<double?>? carbonMonoxide,
      Value<double?>? methane,
      Value<double?>? healthScore,
      Value<bool>? isSynced}) {
    return ChamberReadingsTableCompanion(
      id: id ?? this.id,
      chamberId: chamberId ?? this.chamberId,
      deviceId: deviceId ?? this.deviceId,
      recordedAt: recordedAt ?? this.recordedAt,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      co2: co2 ?? this.co2,
      o2: o2 ?? this.o2,
      ethylene: ethylene ?? this.ethylene,
      carbonMonoxide: carbonMonoxide ?? this.carbonMonoxide,
      methane: methane ?? this.methane,
      healthScore: healthScore ?? this.healthScore,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chamberId.present) {
      map['chamber_id'] = Variable<String>(chamberId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<String>(recordedAt.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (humidity.present) {
      map['humidity'] = Variable<double>(humidity.value);
    }
    if (co2.present) {
      map['co2'] = Variable<double>(co2.value);
    }
    if (o2.present) {
      map['o2'] = Variable<double>(o2.value);
    }
    if (ethylene.present) {
      map['ethylene'] = Variable<double>(ethylene.value);
    }
    if (carbonMonoxide.present) {
      map['carbon_monoxide'] = Variable<double>(carbonMonoxide.value);
    }
    if (methane.present) {
      map['methane'] = Variable<double>(methane.value);
    }
    if (healthScore.present) {
      map['health_score'] = Variable<double>(healthScore.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChamberReadingsTableCompanion(')
          ..write('id: $id, ')
          ..write('chamberId: $chamberId, ')
          ..write('deviceId: $deviceId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('temperature: $temperature, ')
          ..write('humidity: $humidity, ')
          ..write('co2: $co2, ')
          ..write('o2: $o2, ')
          ..write('ethylene: $ethylene, ')
          ..write('carbonMonoxide: $carbonMonoxide, ')
          ..write('methane: $methane, ')
          ..write('healthScore: $healthScore, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $AlertsTableTable extends AlertsTable
    with TableInfo<$AlertsTableTable, AlertsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chamberIdMeta =
      const VerificationMeta('chamberId');
  @override
  late final GeneratedColumn<String> chamberId = GeneratedColumn<String>(
      'chamber_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _alertTypeMeta =
      const VerificationMeta('alertType');
  @override
  late final GeneratedColumn<String> alertType = GeneratedColumn<String>(
      'alert_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _causeMeta = const VerificationMeta('cause');
  @override
  late final GeneratedColumn<String> cause = GeneratedColumn<String>(
      'cause', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _impactMeta = const VerificationMeta('impact');
  @override
  late final GeneratedColumn<String> impact = GeneratedColumn<String>(
      'impact', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recommendedActionMeta =
      const VerificationMeta('recommendedAction');
  @override
  late final GeneratedColumn<String> recommendedAction =
      GeneratedColumn<String>('recommended_action', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentValueMeta =
      const VerificationMeta('currentValue');
  @override
  late final GeneratedColumn<double> currentValue = GeneratedColumn<double>(
      'current_value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _triggeredAtMeta =
      const VerificationMeta('triggeredAt');
  @override
  late final GeneratedColumn<String> triggeredAt = GeneratedColumn<String>(
      'triggered_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deviceId,
        chamberId,
        severity,
        status,
        alertType,
        title,
        cause,
        impact,
        recommendedAction,
        currentValue,
        triggeredAt,
        isRead,
        isSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alerts_table';
  @override
  VerificationContext validateIntegrity(Insertable<AlertsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('chamber_id')) {
      context.handle(_chamberIdMeta,
          chamberId.isAcceptableOrUnknown(data['chamber_id']!, _chamberIdMeta));
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('alert_type')) {
      context.handle(_alertTypeMeta,
          alertType.isAcceptableOrUnknown(data['alert_type']!, _alertTypeMeta));
    } else if (isInserting) {
      context.missing(_alertTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cause')) {
      context.handle(
          _causeMeta, cause.isAcceptableOrUnknown(data['cause']!, _causeMeta));
    } else if (isInserting) {
      context.missing(_causeMeta);
    }
    if (data.containsKey('impact')) {
      context.handle(_impactMeta,
          impact.isAcceptableOrUnknown(data['impact']!, _impactMeta));
    } else if (isInserting) {
      context.missing(_impactMeta);
    }
    if (data.containsKey('recommended_action')) {
      context.handle(
          _recommendedActionMeta,
          recommendedAction.isAcceptableOrUnknown(
              data['recommended_action']!, _recommendedActionMeta));
    } else if (isInserting) {
      context.missing(_recommendedActionMeta);
    }
    if (data.containsKey('current_value')) {
      context.handle(
          _currentValueMeta,
          currentValue.isAcceptableOrUnknown(
              data['current_value']!, _currentValueMeta));
    }
    if (data.containsKey('triggered_at')) {
      context.handle(
          _triggeredAtMeta,
          triggeredAt.isAcceptableOrUnknown(
              data['triggered_at']!, _triggeredAtMeta));
    } else if (isInserting) {
      context.missing(_triggeredAtMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlertsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      chamberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chamber_id']),
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      alertType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alert_type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      cause: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cause'])!,
      impact: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}impact'])!,
      recommendedAction: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recommended_action'])!,
      currentValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_value']),
      triggeredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}triggered_at'])!,
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $AlertsTableTable createAlias(String alias) {
    return $AlertsTableTable(attachedDatabase, alias);
  }
}

class AlertsTableData extends DataClass implements Insertable<AlertsTableData> {
  final String id;
  final String deviceId;
  final String? chamberId;
  final String severity;
  final String status;
  final String alertType;
  final String title;
  final String cause;
  final String impact;
  final String recommendedAction;
  final double? currentValue;
  final String triggeredAt;
  final bool isRead;
  final bool isSynced;
  const AlertsTableData(
      {required this.id,
      required this.deviceId,
      this.chamberId,
      required this.severity,
      required this.status,
      required this.alertType,
      required this.title,
      required this.cause,
      required this.impact,
      required this.recommendedAction,
      this.currentValue,
      required this.triggeredAt,
      required this.isRead,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || chamberId != null) {
      map['chamber_id'] = Variable<String>(chamberId);
    }
    map['severity'] = Variable<String>(severity);
    map['status'] = Variable<String>(status);
    map['alert_type'] = Variable<String>(alertType);
    map['title'] = Variable<String>(title);
    map['cause'] = Variable<String>(cause);
    map['impact'] = Variable<String>(impact);
    map['recommended_action'] = Variable<String>(recommendedAction);
    if (!nullToAbsent || currentValue != null) {
      map['current_value'] = Variable<double>(currentValue);
    }
    map['triggered_at'] = Variable<String>(triggeredAt);
    map['is_read'] = Variable<bool>(isRead);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  AlertsTableCompanion toCompanion(bool nullToAbsent) {
    return AlertsTableCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      chamberId: chamberId == null && nullToAbsent
          ? const Value.absent()
          : Value(chamberId),
      severity: Value(severity),
      status: Value(status),
      alertType: Value(alertType),
      title: Value(title),
      cause: Value(cause),
      impact: Value(impact),
      recommendedAction: Value(recommendedAction),
      currentValue: currentValue == null && nullToAbsent
          ? const Value.absent()
          : Value(currentValue),
      triggeredAt: Value(triggeredAt),
      isRead: Value(isRead),
      isSynced: Value(isSynced),
    );
  }

  factory AlertsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertsTableData(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      chamberId: serializer.fromJson<String?>(json['chamberId']),
      severity: serializer.fromJson<String>(json['severity']),
      status: serializer.fromJson<String>(json['status']),
      alertType: serializer.fromJson<String>(json['alertType']),
      title: serializer.fromJson<String>(json['title']),
      cause: serializer.fromJson<String>(json['cause']),
      impact: serializer.fromJson<String>(json['impact']),
      recommendedAction: serializer.fromJson<String>(json['recommendedAction']),
      currentValue: serializer.fromJson<double?>(json['currentValue']),
      triggeredAt: serializer.fromJson<String>(json['triggeredAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'chamberId': serializer.toJson<String?>(chamberId),
      'severity': serializer.toJson<String>(severity),
      'status': serializer.toJson<String>(status),
      'alertType': serializer.toJson<String>(alertType),
      'title': serializer.toJson<String>(title),
      'cause': serializer.toJson<String>(cause),
      'impact': serializer.toJson<String>(impact),
      'recommendedAction': serializer.toJson<String>(recommendedAction),
      'currentValue': serializer.toJson<double?>(currentValue),
      'triggeredAt': serializer.toJson<String>(triggeredAt),
      'isRead': serializer.toJson<bool>(isRead),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  AlertsTableData copyWith(
          {String? id,
          String? deviceId,
          Value<String?> chamberId = const Value.absent(),
          String? severity,
          String? status,
          String? alertType,
          String? title,
          String? cause,
          String? impact,
          String? recommendedAction,
          Value<double?> currentValue = const Value.absent(),
          String? triggeredAt,
          bool? isRead,
          bool? isSynced}) =>
      AlertsTableData(
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        chamberId: chamberId.present ? chamberId.value : this.chamberId,
        severity: severity ?? this.severity,
        status: status ?? this.status,
        alertType: alertType ?? this.alertType,
        title: title ?? this.title,
        cause: cause ?? this.cause,
        impact: impact ?? this.impact,
        recommendedAction: recommendedAction ?? this.recommendedAction,
        currentValue:
            currentValue.present ? currentValue.value : this.currentValue,
        triggeredAt: triggeredAt ?? this.triggeredAt,
        isRead: isRead ?? this.isRead,
        isSynced: isSynced ?? this.isSynced,
      );
  AlertsTableData copyWithCompanion(AlertsTableCompanion data) {
    return AlertsTableData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      chamberId: data.chamberId.present ? data.chamberId.value : this.chamberId,
      severity: data.severity.present ? data.severity.value : this.severity,
      status: data.status.present ? data.status.value : this.status,
      alertType: data.alertType.present ? data.alertType.value : this.alertType,
      title: data.title.present ? data.title.value : this.title,
      cause: data.cause.present ? data.cause.value : this.cause,
      impact: data.impact.present ? data.impact.value : this.impact,
      recommendedAction: data.recommendedAction.present
          ? data.recommendedAction.value
          : this.recommendedAction,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      triggeredAt:
          data.triggeredAt.present ? data.triggeredAt.value : this.triggeredAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlertsTableData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('chamberId: $chamberId, ')
          ..write('severity: $severity, ')
          ..write('status: $status, ')
          ..write('alertType: $alertType, ')
          ..write('title: $title, ')
          ..write('cause: $cause, ')
          ..write('impact: $impact, ')
          ..write('recommendedAction: $recommendedAction, ')
          ..write('currentValue: $currentValue, ')
          ..write('triggeredAt: $triggeredAt, ')
          ..write('isRead: $isRead, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      deviceId,
      chamberId,
      severity,
      status,
      alertType,
      title,
      cause,
      impact,
      recommendedAction,
      currentValue,
      triggeredAt,
      isRead,
      isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertsTableData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.chamberId == this.chamberId &&
          other.severity == this.severity &&
          other.status == this.status &&
          other.alertType == this.alertType &&
          other.title == this.title &&
          other.cause == this.cause &&
          other.impact == this.impact &&
          other.recommendedAction == this.recommendedAction &&
          other.currentValue == this.currentValue &&
          other.triggeredAt == this.triggeredAt &&
          other.isRead == this.isRead &&
          other.isSynced == this.isSynced);
}

class AlertsTableCompanion extends UpdateCompanion<AlertsTableData> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<String?> chamberId;
  final Value<String> severity;
  final Value<String> status;
  final Value<String> alertType;
  final Value<String> title;
  final Value<String> cause;
  final Value<String> impact;
  final Value<String> recommendedAction;
  final Value<double?> currentValue;
  final Value<String> triggeredAt;
  final Value<bool> isRead;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const AlertsTableCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.chamberId = const Value.absent(),
    this.severity = const Value.absent(),
    this.status = const Value.absent(),
    this.alertType = const Value.absent(),
    this.title = const Value.absent(),
    this.cause = const Value.absent(),
    this.impact = const Value.absent(),
    this.recommendedAction = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.triggeredAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertsTableCompanion.insert({
    required String id,
    required String deviceId,
    this.chamberId = const Value.absent(),
    required String severity,
    required String status,
    required String alertType,
    required String title,
    required String cause,
    required String impact,
    required String recommendedAction,
    this.currentValue = const Value.absent(),
    required String triggeredAt,
    this.isRead = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        severity = Value(severity),
        status = Value(status),
        alertType = Value(alertType),
        title = Value(title),
        cause = Value(cause),
        impact = Value(impact),
        recommendedAction = Value(recommendedAction),
        triggeredAt = Value(triggeredAt);
  static Insertable<AlertsTableData> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<String>? chamberId,
    Expression<String>? severity,
    Expression<String>? status,
    Expression<String>? alertType,
    Expression<String>? title,
    Expression<String>? cause,
    Expression<String>? impact,
    Expression<String>? recommendedAction,
    Expression<double>? currentValue,
    Expression<String>? triggeredAt,
    Expression<bool>? isRead,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (chamberId != null) 'chamber_id': chamberId,
      if (severity != null) 'severity': severity,
      if (status != null) 'status': status,
      if (alertType != null) 'alert_type': alertType,
      if (title != null) 'title': title,
      if (cause != null) 'cause': cause,
      if (impact != null) 'impact': impact,
      if (recommendedAction != null) 'recommended_action': recommendedAction,
      if (currentValue != null) 'current_value': currentValue,
      if (triggeredAt != null) 'triggered_at': triggeredAt,
      if (isRead != null) 'is_read': isRead,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? deviceId,
      Value<String?>? chamberId,
      Value<String>? severity,
      Value<String>? status,
      Value<String>? alertType,
      Value<String>? title,
      Value<String>? cause,
      Value<String>? impact,
      Value<String>? recommendedAction,
      Value<double?>? currentValue,
      Value<String>? triggeredAt,
      Value<bool>? isRead,
      Value<bool>? isSynced,
      Value<int>? rowid}) {
    return AlertsTableCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      chamberId: chamberId ?? this.chamberId,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      alertType: alertType ?? this.alertType,
      title: title ?? this.title,
      cause: cause ?? this.cause,
      impact: impact ?? this.impact,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      currentValue: currentValue ?? this.currentValue,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      isRead: isRead ?? this.isRead,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (chamberId.present) {
      map['chamber_id'] = Variable<String>(chamberId.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (alertType.present) {
      map['alert_type'] = Variable<String>(alertType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (cause.present) {
      map['cause'] = Variable<String>(cause.value);
    }
    if (impact.present) {
      map['impact'] = Variable<String>(impact.value);
    }
    if (recommendedAction.present) {
      map['recommended_action'] = Variable<String>(recommendedAction.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<double>(currentValue.value);
    }
    if (triggeredAt.present) {
      map['triggered_at'] = Variable<String>(triggeredAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertsTableCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('chamberId: $chamberId, ')
          ..write('severity: $severity, ')
          ..write('status: $status, ')
          ..write('alertType: $alertType, ')
          ..write('title: $title, ')
          ..write('cause: $cause, ')
          ..write('impact: $impact, ')
          ..write('recommendedAction: $recommendedAction, ')
          ..write('currentValue: $currentValue, ')
          ..write('triggeredAt: $triggeredAt, ')
          ..write('isRead: $isRead, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoodsBatchesTableTable extends GoodsBatchesTable
    with TableInfo<$GoodsBatchesTableTable, GoodsBatchesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoodsBatchesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chamberIdMeta =
      const VerificationMeta('chamberId');
  @override
  late final GeneratedColumn<String> chamberId = GeneratedColumn<String>(
      'chamber_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityKgMeta =
      const VerificationMeta('quantityKg');
  @override
  late final GeneratedColumn<double> quantityKg = GeneratedColumn<double>(
      'quantity_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
      'stage', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _harvestDateMeta =
      const VerificationMeta('harvestDate');
  @override
  late final GeneratedColumn<String> harvestDate = GeneratedColumn<String>(
      'harvest_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _storageDateMeta =
      const VerificationMeta('storageDate');
  @override
  late final GeneratedColumn<String> storageDate = GeneratedColumn<String>(
      'storage_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remainingShelfLifeDaysMeta =
      const VerificationMeta('remainingShelfLifeDays');
  @override
  late final GeneratedColumn<int> remainingShelfLifeDays = GeneratedColumn<int>(
      'remaining_shelf_life_days', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _spoilageRiskScoreMeta =
      const VerificationMeta('spoilageRiskScore');
  @override
  late final GeneratedColumn<double> spoilageRiskScore =
      GeneratedColumn<double>('spoilage_risk_score', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chamberId,
        name,
        category,
        quantityKg,
        stage,
        harvestDate,
        storageDate,
        remainingShelfLifeDays,
        spoilageRiskScore,
        isSynced,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goods_batches_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<GoodsBatchesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chamber_id')) {
      context.handle(_chamberIdMeta,
          chamberId.isAcceptableOrUnknown(data['chamber_id']!, _chamberIdMeta));
    } else if (isInserting) {
      context.missing(_chamberIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('quantity_kg')) {
      context.handle(
          _quantityKgMeta,
          quantityKg.isAcceptableOrUnknown(
              data['quantity_kg']!, _quantityKgMeta));
    }
    if (data.containsKey('stage')) {
      context.handle(
          _stageMeta, stage.isAcceptableOrUnknown(data['stage']!, _stageMeta));
    } else if (isInserting) {
      context.missing(_stageMeta);
    }
    if (data.containsKey('harvest_date')) {
      context.handle(
          _harvestDateMeta,
          harvestDate.isAcceptableOrUnknown(
              data['harvest_date']!, _harvestDateMeta));
    }
    if (data.containsKey('storage_date')) {
      context.handle(
          _storageDateMeta,
          storageDate.isAcceptableOrUnknown(
              data['storage_date']!, _storageDateMeta));
    }
    if (data.containsKey('remaining_shelf_life_days')) {
      context.handle(
          _remainingShelfLifeDaysMeta,
          remainingShelfLifeDays.isAcceptableOrUnknown(
              data['remaining_shelf_life_days']!, _remainingShelfLifeDaysMeta));
    }
    if (data.containsKey('spoilage_risk_score')) {
      context.handle(
          _spoilageRiskScoreMeta,
          spoilageRiskScore.isAcceptableOrUnknown(
              data['spoilage_risk_score']!, _spoilageRiskScoreMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoodsBatchesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoodsBatchesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chamberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chamber_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      quantityKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity_kg']),
      stage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stage'])!,
      harvestDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}harvest_date']),
      storageDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_date']),
      remainingShelfLifeDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}remaining_shelf_life_days']),
      spoilageRiskScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}spoilage_risk_score']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GoodsBatchesTableTable createAlias(String alias) {
    return $GoodsBatchesTableTable(attachedDatabase, alias);
  }
}

class GoodsBatchesTableData extends DataClass
    implements Insertable<GoodsBatchesTableData> {
  final String id;
  final String chamberId;
  final String name;
  final String category;
  final double? quantityKg;
  final String stage;
  final String? harvestDate;
  final String? storageDate;
  final int? remainingShelfLifeDays;
  final double? spoilageRiskScore;
  final bool isSynced;
  final String createdAt;
  const GoodsBatchesTableData(
      {required this.id,
      required this.chamberId,
      required this.name,
      required this.category,
      this.quantityKg,
      required this.stage,
      this.harvestDate,
      this.storageDate,
      this.remainingShelfLifeDays,
      this.spoilageRiskScore,
      required this.isSynced,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chamber_id'] = Variable<String>(chamberId);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || quantityKg != null) {
      map['quantity_kg'] = Variable<double>(quantityKg);
    }
    map['stage'] = Variable<String>(stage);
    if (!nullToAbsent || harvestDate != null) {
      map['harvest_date'] = Variable<String>(harvestDate);
    }
    if (!nullToAbsent || storageDate != null) {
      map['storage_date'] = Variable<String>(storageDate);
    }
    if (!nullToAbsent || remainingShelfLifeDays != null) {
      map['remaining_shelf_life_days'] = Variable<int>(remainingShelfLifeDays);
    }
    if (!nullToAbsent || spoilageRiskScore != null) {
      map['spoilage_risk_score'] = Variable<double>(spoilageRiskScore);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  GoodsBatchesTableCompanion toCompanion(bool nullToAbsent) {
    return GoodsBatchesTableCompanion(
      id: Value(id),
      chamberId: Value(chamberId),
      name: Value(name),
      category: Value(category),
      quantityKg: quantityKg == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityKg),
      stage: Value(stage),
      harvestDate: harvestDate == null && nullToAbsent
          ? const Value.absent()
          : Value(harvestDate),
      storageDate: storageDate == null && nullToAbsent
          ? const Value.absent()
          : Value(storageDate),
      remainingShelfLifeDays: remainingShelfLifeDays == null && nullToAbsent
          ? const Value.absent()
          : Value(remainingShelfLifeDays),
      spoilageRiskScore: spoilageRiskScore == null && nullToAbsent
          ? const Value.absent()
          : Value(spoilageRiskScore),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
    );
  }

  factory GoodsBatchesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoodsBatchesTableData(
      id: serializer.fromJson<String>(json['id']),
      chamberId: serializer.fromJson<String>(json['chamberId']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      quantityKg: serializer.fromJson<double?>(json['quantityKg']),
      stage: serializer.fromJson<String>(json['stage']),
      harvestDate: serializer.fromJson<String?>(json['harvestDate']),
      storageDate: serializer.fromJson<String?>(json['storageDate']),
      remainingShelfLifeDays:
          serializer.fromJson<int?>(json['remainingShelfLifeDays']),
      spoilageRiskScore:
          serializer.fromJson<double?>(json['spoilageRiskScore']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chamberId': serializer.toJson<String>(chamberId),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'quantityKg': serializer.toJson<double?>(quantityKg),
      'stage': serializer.toJson<String>(stage),
      'harvestDate': serializer.toJson<String?>(harvestDate),
      'storageDate': serializer.toJson<String?>(storageDate),
      'remainingShelfLifeDays': serializer.toJson<int?>(remainingShelfLifeDays),
      'spoilageRiskScore': serializer.toJson<double?>(spoilageRiskScore),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  GoodsBatchesTableData copyWith(
          {String? id,
          String? chamberId,
          String? name,
          String? category,
          Value<double?> quantityKg = const Value.absent(),
          String? stage,
          Value<String?> harvestDate = const Value.absent(),
          Value<String?> storageDate = const Value.absent(),
          Value<int?> remainingShelfLifeDays = const Value.absent(),
          Value<double?> spoilageRiskScore = const Value.absent(),
          bool? isSynced,
          String? createdAt}) =>
      GoodsBatchesTableData(
        id: id ?? this.id,
        chamberId: chamberId ?? this.chamberId,
        name: name ?? this.name,
        category: category ?? this.category,
        quantityKg: quantityKg.present ? quantityKg.value : this.quantityKg,
        stage: stage ?? this.stage,
        harvestDate: harvestDate.present ? harvestDate.value : this.harvestDate,
        storageDate: storageDate.present ? storageDate.value : this.storageDate,
        remainingShelfLifeDays: remainingShelfLifeDays.present
            ? remainingShelfLifeDays.value
            : this.remainingShelfLifeDays,
        spoilageRiskScore: spoilageRiskScore.present
            ? spoilageRiskScore.value
            : this.spoilageRiskScore,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
      );
  GoodsBatchesTableData copyWithCompanion(GoodsBatchesTableCompanion data) {
    return GoodsBatchesTableData(
      id: data.id.present ? data.id.value : this.id,
      chamberId: data.chamberId.present ? data.chamberId.value : this.chamberId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      quantityKg:
          data.quantityKg.present ? data.quantityKg.value : this.quantityKg,
      stage: data.stage.present ? data.stage.value : this.stage,
      harvestDate:
          data.harvestDate.present ? data.harvestDate.value : this.harvestDate,
      storageDate:
          data.storageDate.present ? data.storageDate.value : this.storageDate,
      remainingShelfLifeDays: data.remainingShelfLifeDays.present
          ? data.remainingShelfLifeDays.value
          : this.remainingShelfLifeDays,
      spoilageRiskScore: data.spoilageRiskScore.present
          ? data.spoilageRiskScore.value
          : this.spoilageRiskScore,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoodsBatchesTableData(')
          ..write('id: $id, ')
          ..write('chamberId: $chamberId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('quantityKg: $quantityKg, ')
          ..write('stage: $stage, ')
          ..write('harvestDate: $harvestDate, ')
          ..write('storageDate: $storageDate, ')
          ..write('remainingShelfLifeDays: $remainingShelfLifeDays, ')
          ..write('spoilageRiskScore: $spoilageRiskScore, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      chamberId,
      name,
      category,
      quantityKg,
      stage,
      harvestDate,
      storageDate,
      remainingShelfLifeDays,
      spoilageRiskScore,
      isSynced,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoodsBatchesTableData &&
          other.id == this.id &&
          other.chamberId == this.chamberId &&
          other.name == this.name &&
          other.category == this.category &&
          other.quantityKg == this.quantityKg &&
          other.stage == this.stage &&
          other.harvestDate == this.harvestDate &&
          other.storageDate == this.storageDate &&
          other.remainingShelfLifeDays == this.remainingShelfLifeDays &&
          other.spoilageRiskScore == this.spoilageRiskScore &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt);
}

class GoodsBatchesTableCompanion
    extends UpdateCompanion<GoodsBatchesTableData> {
  final Value<String> id;
  final Value<String> chamberId;
  final Value<String> name;
  final Value<String> category;
  final Value<double?> quantityKg;
  final Value<String> stage;
  final Value<String?> harvestDate;
  final Value<String?> storageDate;
  final Value<int?> remainingShelfLifeDays;
  final Value<double?> spoilageRiskScore;
  final Value<bool> isSynced;
  final Value<String> createdAt;
  final Value<int> rowid;
  const GoodsBatchesTableCompanion({
    this.id = const Value.absent(),
    this.chamberId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.quantityKg = const Value.absent(),
    this.stage = const Value.absent(),
    this.harvestDate = const Value.absent(),
    this.storageDate = const Value.absent(),
    this.remainingShelfLifeDays = const Value.absent(),
    this.spoilageRiskScore = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoodsBatchesTableCompanion.insert({
    required String id,
    required String chamberId,
    required String name,
    required String category,
    this.quantityKg = const Value.absent(),
    required String stage,
    this.harvestDate = const Value.absent(),
    this.storageDate = const Value.absent(),
    this.remainingShelfLifeDays = const Value.absent(),
    this.spoilageRiskScore = const Value.absent(),
    this.isSynced = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chamberId = Value(chamberId),
        name = Value(name),
        category = Value(category),
        stage = Value(stage),
        createdAt = Value(createdAt);
  static Insertable<GoodsBatchesTableData> custom({
    Expression<String>? id,
    Expression<String>? chamberId,
    Expression<String>? name,
    Expression<String>? category,
    Expression<double>? quantityKg,
    Expression<String>? stage,
    Expression<String>? harvestDate,
    Expression<String>? storageDate,
    Expression<int>? remainingShelfLifeDays,
    Expression<double>? spoilageRiskScore,
    Expression<bool>? isSynced,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chamberId != null) 'chamber_id': chamberId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (quantityKg != null) 'quantity_kg': quantityKg,
      if (stage != null) 'stage': stage,
      if (harvestDate != null) 'harvest_date': harvestDate,
      if (storageDate != null) 'storage_date': storageDate,
      if (remainingShelfLifeDays != null)
        'remaining_shelf_life_days': remainingShelfLifeDays,
      if (spoilageRiskScore != null) 'spoilage_risk_score': spoilageRiskScore,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoodsBatchesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? chamberId,
      Value<String>? name,
      Value<String>? category,
      Value<double?>? quantityKg,
      Value<String>? stage,
      Value<String?>? harvestDate,
      Value<String?>? storageDate,
      Value<int?>? remainingShelfLifeDays,
      Value<double?>? spoilageRiskScore,
      Value<bool>? isSynced,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return GoodsBatchesTableCompanion(
      id: id ?? this.id,
      chamberId: chamberId ?? this.chamberId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantityKg: quantityKg ?? this.quantityKg,
      stage: stage ?? this.stage,
      harvestDate: harvestDate ?? this.harvestDate,
      storageDate: storageDate ?? this.storageDate,
      remainingShelfLifeDays:
          remainingShelfLifeDays ?? this.remainingShelfLifeDays,
      spoilageRiskScore: spoilageRiskScore ?? this.spoilageRiskScore,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chamberId.present) {
      map['chamber_id'] = Variable<String>(chamberId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (quantityKg.present) {
      map['quantity_kg'] = Variable<double>(quantityKg.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (harvestDate.present) {
      map['harvest_date'] = Variable<String>(harvestDate.value);
    }
    if (storageDate.present) {
      map['storage_date'] = Variable<String>(storageDate.value);
    }
    if (remainingShelfLifeDays.present) {
      map['remaining_shelf_life_days'] =
          Variable<int>(remainingShelfLifeDays.value);
    }
    if (spoilageRiskScore.present) {
      map['spoilage_risk_score'] = Variable<double>(spoilageRiskScore.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoodsBatchesTableCompanion(')
          ..write('id: $id, ')
          ..write('chamberId: $chamberId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('quantityKg: $quantityKg, ')
          ..write('stage: $stage, ')
          ..write('harvestDate: $harvestDate, ')
          ..write('storageDate: $storageDate, ')
          ..write('remainingShelfLifeDays: $remainingShelfLifeDays, ')
          ..write('spoilageRiskScore: $spoilageRiskScore, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineSyncQueueTableTable extends OfflineSyncQueueTable
    with TableInfo<$OfflineSyncQueueTableTable, OfflineSyncQueueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineSyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientTimestampMeta =
      const VerificationMeta('clientTimestamp');
  @override
  late final GeneratedColumn<String> clientTimestamp = GeneratedColumn<String>(
      'client_timestamp', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isProcessedMeta =
      const VerificationMeta('isProcessed');
  @override
  late final GeneratedColumn<bool> isProcessed = GeneratedColumn<bool>(
      'is_processed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_processed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        action,
        payloadJson,
        clientTimestamp,
        retryCount,
        isProcessed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_sync_queue_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<OfflineSyncQueueTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('client_timestamp')) {
      context.handle(
          _clientTimestampMeta,
          clientTimestamp.isAcceptableOrUnknown(
              data['client_timestamp']!, _clientTimestampMeta));
    } else if (isInserting) {
      context.missing(_clientTimestampMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('is_processed')) {
      context.handle(
          _isProcessedMeta,
          isProcessed.isAcceptableOrUnknown(
              data['is_processed']!, _isProcessedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineSyncQueueTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineSyncQueueTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id']),
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      clientTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}client_timestamp'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      isProcessed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_processed'])!,
    );
  }

  @override
  $OfflineSyncQueueTableTable createAlias(String alias) {
    return $OfflineSyncQueueTableTable(attachedDatabase, alias);
  }
}

class OfflineSyncQueueTableData extends DataClass
    implements Insertable<OfflineSyncQueueTableData> {
  final String id;
  final String entityType;
  final String? entityId;
  final String action;
  final String payloadJson;
  final String clientTimestamp;
  final int retryCount;
  final bool isProcessed;
  const OfflineSyncQueueTableData(
      {required this.id,
      required this.entityType,
      this.entityId,
      required this.action,
      required this.payloadJson,
      required this.clientTimestamp,
      required this.retryCount,
      required this.isProcessed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    map['action'] = Variable<String>(action);
    map['payload_json'] = Variable<String>(payloadJson);
    map['client_timestamp'] = Variable<String>(clientTimestamp);
    map['retry_count'] = Variable<int>(retryCount);
    map['is_processed'] = Variable<bool>(isProcessed);
    return map;
  }

  OfflineSyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return OfflineSyncQueueTableCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      action: Value(action),
      payloadJson: Value(payloadJson),
      clientTimestamp: Value(clientTimestamp),
      retryCount: Value(retryCount),
      isProcessed: Value(isProcessed),
    );
  }

  factory OfflineSyncQueueTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineSyncQueueTableData(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      clientTimestamp: serializer.fromJson<String>(json['clientTimestamp']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      isProcessed: serializer.fromJson<bool>(json['isProcessed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String?>(entityId),
      'action': serializer.toJson<String>(action),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'clientTimestamp': serializer.toJson<String>(clientTimestamp),
      'retryCount': serializer.toJson<int>(retryCount),
      'isProcessed': serializer.toJson<bool>(isProcessed),
    };
  }

  OfflineSyncQueueTableData copyWith(
          {String? id,
          String? entityType,
          Value<String?> entityId = const Value.absent(),
          String? action,
          String? payloadJson,
          String? clientTimestamp,
          int? retryCount,
          bool? isProcessed}) =>
      OfflineSyncQueueTableData(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId.present ? entityId.value : this.entityId,
        action: action ?? this.action,
        payloadJson: payloadJson ?? this.payloadJson,
        clientTimestamp: clientTimestamp ?? this.clientTimestamp,
        retryCount: retryCount ?? this.retryCount,
        isProcessed: isProcessed ?? this.isProcessed,
      );
  OfflineSyncQueueTableData copyWithCompanion(
      OfflineSyncQueueTableCompanion data) {
    return OfflineSyncQueueTableData(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      clientTimestamp: data.clientTimestamp.present
          ? data.clientTimestamp.value
          : this.clientTimestamp,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      isProcessed:
          data.isProcessed.present ? data.isProcessed.value : this.isProcessed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineSyncQueueTableData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('clientTimestamp: $clientTimestamp, ')
          ..write('retryCount: $retryCount, ')
          ..write('isProcessed: $isProcessed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, action, payloadJson,
      clientTimestamp, retryCount, isProcessed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineSyncQueueTableData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.payloadJson == this.payloadJson &&
          other.clientTimestamp == this.clientTimestamp &&
          other.retryCount == this.retryCount &&
          other.isProcessed == this.isProcessed);
}

class OfflineSyncQueueTableCompanion
    extends UpdateCompanion<OfflineSyncQueueTableData> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String?> entityId;
  final Value<String> action;
  final Value<String> payloadJson;
  final Value<String> clientTimestamp;
  final Value<int> retryCount;
  final Value<bool> isProcessed;
  final Value<int> rowid;
  const OfflineSyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.clientTimestamp = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.isProcessed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineSyncQueueTableCompanion.insert({
    required String id,
    required String entityType,
    this.entityId = const Value.absent(),
    required String action,
    required String payloadJson,
    required String clientTimestamp,
    this.retryCount = const Value.absent(),
    this.isProcessed = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        action = Value(action),
        payloadJson = Value(payloadJson),
        clientTimestamp = Value(clientTimestamp);
  static Insertable<OfflineSyncQueueTableData> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? payloadJson,
    Expression<String>? clientTimestamp,
    Expression<int>? retryCount,
    Expression<bool>? isProcessed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (clientTimestamp != null) 'client_timestamp': clientTimestamp,
      if (retryCount != null) 'retry_count': retryCount,
      if (isProcessed != null) 'is_processed': isProcessed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineSyncQueueTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String?>? entityId,
      Value<String>? action,
      Value<String>? payloadJson,
      Value<String>? clientTimestamp,
      Value<int>? retryCount,
      Value<bool>? isProcessed,
      Value<int>? rowid}) {
    return OfflineSyncQueueTableCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      payloadJson: payloadJson ?? this.payloadJson,
      clientTimestamp: clientTimestamp ?? this.clientTimestamp,
      retryCount: retryCount ?? this.retryCount,
      isProcessed: isProcessed ?? this.isProcessed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (clientTimestamp.present) {
      map['client_timestamp'] = Variable<String>(clientTimestamp.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (isProcessed.present) {
      map['is_processed'] = Variable<bool>(isProcessed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineSyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('clientTimestamp: $clientTimestamp, ')
          ..write('retryCount: $retryCount, ')
          ..write('isProcessed: $isProcessed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CropProfilesTableTable extends CropProfilesTable
    with TableInfo<$CropProfilesTableTable, CropProfilesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CropProfilesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _profileTypeMeta =
      const VerificationMeta('profileType');
  @override
  late final GeneratedColumn<String> profileType = GeneratedColumn<String>(
      'profile_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tempMinMeta =
      const VerificationMeta('tempMin');
  @override
  late final GeneratedColumn<double> tempMin = GeneratedColumn<double>(
      'temp_min', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _tempMaxMeta =
      const VerificationMeta('tempMax');
  @override
  late final GeneratedColumn<double> tempMax = GeneratedColumn<double>(
      'temp_max', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _humidityMinMeta =
      const VerificationMeta('humidityMin');
  @override
  late final GeneratedColumn<double> humidityMin = GeneratedColumn<double>(
      'humidity_min', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _humidityMaxMeta =
      const VerificationMeta('humidityMax');
  @override
  late final GeneratedColumn<double> humidityMax = GeneratedColumn<double>(
      'humidity_max', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _storageDurationDaysMeta =
      const VerificationMeta('storageDurationDays');
  @override
  late final GeneratedColumn<int> storageDurationDays = GeneratedColumn<int>(
      'storage_duration_days', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _shelfLifeDaysMeta =
      const VerificationMeta('shelfLifeDays');
  @override
  late final GeneratedColumn<int> shelfLifeDays = GeneratedColumn<int>(
      'shelf_life_days', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<String> cachedAt = GeneratedColumn<String>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        category,
        profileType,
        tempMin,
        tempMax,
        humidityMin,
        humidityMax,
        storageDurationDays,
        shelfLifeDays,
        description,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crop_profiles_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<CropProfilesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('profile_type')) {
      context.handle(
          _profileTypeMeta,
          profileType.isAcceptableOrUnknown(
              data['profile_type']!, _profileTypeMeta));
    } else if (isInserting) {
      context.missing(_profileTypeMeta);
    }
    if (data.containsKey('temp_min')) {
      context.handle(_tempMinMeta,
          tempMin.isAcceptableOrUnknown(data['temp_min']!, _tempMinMeta));
    }
    if (data.containsKey('temp_max')) {
      context.handle(_tempMaxMeta,
          tempMax.isAcceptableOrUnknown(data['temp_max']!, _tempMaxMeta));
    }
    if (data.containsKey('humidity_min')) {
      context.handle(
          _humidityMinMeta,
          humidityMin.isAcceptableOrUnknown(
              data['humidity_min']!, _humidityMinMeta));
    }
    if (data.containsKey('humidity_max')) {
      context.handle(
          _humidityMaxMeta,
          humidityMax.isAcceptableOrUnknown(
              data['humidity_max']!, _humidityMaxMeta));
    }
    if (data.containsKey('storage_duration_days')) {
      context.handle(
          _storageDurationDaysMeta,
          storageDurationDays.isAcceptableOrUnknown(
              data['storage_duration_days']!, _storageDurationDaysMeta));
    }
    if (data.containsKey('shelf_life_days')) {
      context.handle(
          _shelfLifeDaysMeta,
          shelfLifeDays.isAcceptableOrUnknown(
              data['shelf_life_days']!, _shelfLifeDaysMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CropProfilesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CropProfilesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      profileType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_type'])!,
      tempMin: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}temp_min']),
      tempMax: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}temp_max']),
      humidityMin: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}humidity_min']),
      humidityMax: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}humidity_max']),
      storageDurationDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}storage_duration_days']),
      shelfLifeDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}shelf_life_days']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CropProfilesTableTable createAlias(String alias) {
    return $CropProfilesTableTable(attachedDatabase, alias);
  }
}

class CropProfilesTableData extends DataClass
    implements Insertable<CropProfilesTableData> {
  final String id;
  final String name;
  final String category;
  final String profileType;
  final double? tempMin;
  final double? tempMax;
  final double? humidityMin;
  final double? humidityMax;
  final int? storageDurationDays;
  final int? shelfLifeDays;
  final String? description;
  final String cachedAt;
  const CropProfilesTableData(
      {required this.id,
      required this.name,
      required this.category,
      required this.profileType,
      this.tempMin,
      this.tempMax,
      this.humidityMin,
      this.humidityMax,
      this.storageDurationDays,
      this.shelfLifeDays,
      this.description,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['profile_type'] = Variable<String>(profileType);
    if (!nullToAbsent || tempMin != null) {
      map['temp_min'] = Variable<double>(tempMin);
    }
    if (!nullToAbsent || tempMax != null) {
      map['temp_max'] = Variable<double>(tempMax);
    }
    if (!nullToAbsent || humidityMin != null) {
      map['humidity_min'] = Variable<double>(humidityMin);
    }
    if (!nullToAbsent || humidityMax != null) {
      map['humidity_max'] = Variable<double>(humidityMax);
    }
    if (!nullToAbsent || storageDurationDays != null) {
      map['storage_duration_days'] = Variable<int>(storageDurationDays);
    }
    if (!nullToAbsent || shelfLifeDays != null) {
      map['shelf_life_days'] = Variable<int>(shelfLifeDays);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['cached_at'] = Variable<String>(cachedAt);
    return map;
  }

  CropProfilesTableCompanion toCompanion(bool nullToAbsent) {
    return CropProfilesTableCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      profileType: Value(profileType),
      tempMin: tempMin == null && nullToAbsent
          ? const Value.absent()
          : Value(tempMin),
      tempMax: tempMax == null && nullToAbsent
          ? const Value.absent()
          : Value(tempMax),
      humidityMin: humidityMin == null && nullToAbsent
          ? const Value.absent()
          : Value(humidityMin),
      humidityMax: humidityMax == null && nullToAbsent
          ? const Value.absent()
          : Value(humidityMax),
      storageDurationDays: storageDurationDays == null && nullToAbsent
          ? const Value.absent()
          : Value(storageDurationDays),
      shelfLifeDays: shelfLifeDays == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfLifeDays),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      cachedAt: Value(cachedAt),
    );
  }

  factory CropProfilesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CropProfilesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      profileType: serializer.fromJson<String>(json['profileType']),
      tempMin: serializer.fromJson<double?>(json['tempMin']),
      tempMax: serializer.fromJson<double?>(json['tempMax']),
      humidityMin: serializer.fromJson<double?>(json['humidityMin']),
      humidityMax: serializer.fromJson<double?>(json['humidityMax']),
      storageDurationDays:
          serializer.fromJson<int?>(json['storageDurationDays']),
      shelfLifeDays: serializer.fromJson<int?>(json['shelfLifeDays']),
      description: serializer.fromJson<String?>(json['description']),
      cachedAt: serializer.fromJson<String>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'profileType': serializer.toJson<String>(profileType),
      'tempMin': serializer.toJson<double?>(tempMin),
      'tempMax': serializer.toJson<double?>(tempMax),
      'humidityMin': serializer.toJson<double?>(humidityMin),
      'humidityMax': serializer.toJson<double?>(humidityMax),
      'storageDurationDays': serializer.toJson<int?>(storageDurationDays),
      'shelfLifeDays': serializer.toJson<int?>(shelfLifeDays),
      'description': serializer.toJson<String?>(description),
      'cachedAt': serializer.toJson<String>(cachedAt),
    };
  }

  CropProfilesTableData copyWith(
          {String? id,
          String? name,
          String? category,
          String? profileType,
          Value<double?> tempMin = const Value.absent(),
          Value<double?> tempMax = const Value.absent(),
          Value<double?> humidityMin = const Value.absent(),
          Value<double?> humidityMax = const Value.absent(),
          Value<int?> storageDurationDays = const Value.absent(),
          Value<int?> shelfLifeDays = const Value.absent(),
          Value<String?> description = const Value.absent(),
          String? cachedAt}) =>
      CropProfilesTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        profileType: profileType ?? this.profileType,
        tempMin: tempMin.present ? tempMin.value : this.tempMin,
        tempMax: tempMax.present ? tempMax.value : this.tempMax,
        humidityMin: humidityMin.present ? humidityMin.value : this.humidityMin,
        humidityMax: humidityMax.present ? humidityMax.value : this.humidityMax,
        storageDurationDays: storageDurationDays.present
            ? storageDurationDays.value
            : this.storageDurationDays,
        shelfLifeDays:
            shelfLifeDays.present ? shelfLifeDays.value : this.shelfLifeDays,
        description: description.present ? description.value : this.description,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CropProfilesTableData copyWithCompanion(CropProfilesTableCompanion data) {
    return CropProfilesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      profileType:
          data.profileType.present ? data.profileType.value : this.profileType,
      tempMin: data.tempMin.present ? data.tempMin.value : this.tempMin,
      tempMax: data.tempMax.present ? data.tempMax.value : this.tempMax,
      humidityMin:
          data.humidityMin.present ? data.humidityMin.value : this.humidityMin,
      humidityMax:
          data.humidityMax.present ? data.humidityMax.value : this.humidityMax,
      storageDurationDays: data.storageDurationDays.present
          ? data.storageDurationDays.value
          : this.storageDurationDays,
      shelfLifeDays: data.shelfLifeDays.present
          ? data.shelfLifeDays.value
          : this.shelfLifeDays,
      description:
          data.description.present ? data.description.value : this.description,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CropProfilesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('profileType: $profileType, ')
          ..write('tempMin: $tempMin, ')
          ..write('tempMax: $tempMax, ')
          ..write('humidityMin: $humidityMin, ')
          ..write('humidityMax: $humidityMax, ')
          ..write('storageDurationDays: $storageDurationDays, ')
          ..write('shelfLifeDays: $shelfLifeDays, ')
          ..write('description: $description, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      category,
      profileType,
      tempMin,
      tempMax,
      humidityMin,
      humidityMax,
      storageDurationDays,
      shelfLifeDays,
      description,
      cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CropProfilesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.profileType == this.profileType &&
          other.tempMin == this.tempMin &&
          other.tempMax == this.tempMax &&
          other.humidityMin == this.humidityMin &&
          other.humidityMax == this.humidityMax &&
          other.storageDurationDays == this.storageDurationDays &&
          other.shelfLifeDays == this.shelfLifeDays &&
          other.description == this.description &&
          other.cachedAt == this.cachedAt);
}

class CropProfilesTableCompanion
    extends UpdateCompanion<CropProfilesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String> profileType;
  final Value<double?> tempMin;
  final Value<double?> tempMax;
  final Value<double?> humidityMin;
  final Value<double?> humidityMax;
  final Value<int?> storageDurationDays;
  final Value<int?> shelfLifeDays;
  final Value<String?> description;
  final Value<String> cachedAt;
  final Value<int> rowid;
  const CropProfilesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.profileType = const Value.absent(),
    this.tempMin = const Value.absent(),
    this.tempMax = const Value.absent(),
    this.humidityMin = const Value.absent(),
    this.humidityMax = const Value.absent(),
    this.storageDurationDays = const Value.absent(),
    this.shelfLifeDays = const Value.absent(),
    this.description = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CropProfilesTableCompanion.insert({
    required String id,
    required String name,
    required String category,
    required String profileType,
    this.tempMin = const Value.absent(),
    this.tempMax = const Value.absent(),
    this.humidityMin = const Value.absent(),
    this.humidityMax = const Value.absent(),
    this.storageDurationDays = const Value.absent(),
    this.shelfLifeDays = const Value.absent(),
    this.description = const Value.absent(),
    required String cachedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        category = Value(category),
        profileType = Value(profileType),
        cachedAt = Value(cachedAt);
  static Insertable<CropProfilesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? profileType,
    Expression<double>? tempMin,
    Expression<double>? tempMax,
    Expression<double>? humidityMin,
    Expression<double>? humidityMax,
    Expression<int>? storageDurationDays,
    Expression<int>? shelfLifeDays,
    Expression<String>? description,
    Expression<String>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (profileType != null) 'profile_type': profileType,
      if (tempMin != null) 'temp_min': tempMin,
      if (tempMax != null) 'temp_max': tempMax,
      if (humidityMin != null) 'humidity_min': humidityMin,
      if (humidityMax != null) 'humidity_max': humidityMax,
      if (storageDurationDays != null)
        'storage_duration_days': storageDurationDays,
      if (shelfLifeDays != null) 'shelf_life_days': shelfLifeDays,
      if (description != null) 'description': description,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CropProfilesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? category,
      Value<String>? profileType,
      Value<double?>? tempMin,
      Value<double?>? tempMax,
      Value<double?>? humidityMin,
      Value<double?>? humidityMax,
      Value<int?>? storageDurationDays,
      Value<int?>? shelfLifeDays,
      Value<String?>? description,
      Value<String>? cachedAt,
      Value<int>? rowid}) {
    return CropProfilesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      profileType: profileType ?? this.profileType,
      tempMin: tempMin ?? this.tempMin,
      tempMax: tempMax ?? this.tempMax,
      humidityMin: humidityMin ?? this.humidityMin,
      humidityMax: humidityMax ?? this.humidityMax,
      storageDurationDays: storageDurationDays ?? this.storageDurationDays,
      shelfLifeDays: shelfLifeDays ?? this.shelfLifeDays,
      description: description ?? this.description,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (profileType.present) {
      map['profile_type'] = Variable<String>(profileType.value);
    }
    if (tempMin.present) {
      map['temp_min'] = Variable<double>(tempMin.value);
    }
    if (tempMax.present) {
      map['temp_max'] = Variable<double>(tempMax.value);
    }
    if (humidityMin.present) {
      map['humidity_min'] = Variable<double>(humidityMin.value);
    }
    if (humidityMax.present) {
      map['humidity_max'] = Variable<double>(humidityMax.value);
    }
    if (storageDurationDays.present) {
      map['storage_duration_days'] = Variable<int>(storageDurationDays.value);
    }
    if (shelfLifeDays.present) {
      map['shelf_life_days'] = Variable<int>(shelfLifeDays.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<String>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CropProfilesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('profileType: $profileType, ')
          ..write('tempMin: $tempMin, ')
          ..write('tempMax: $tempMax, ')
          ..write('humidityMin: $humidityMin, ')
          ..write('humidityMax: $humidityMax, ')
          ..write('storageDurationDays: $storageDurationDays, ')
          ..write('shelfLifeDays: $shelfLifeDays, ')
          ..write('description: $description, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPrefsTableTable extends UserPrefsTable
    with TableInfo<$UserPrefsTableTable, UserPrefsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPrefsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_prefs_table';
  @override
  VerificationContext validateIntegrity(Insertable<UserPrefsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UserPrefsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPrefsTableData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $UserPrefsTableTable createAlias(String alias) {
    return $UserPrefsTableTable(attachedDatabase, alias);
  }
}

class UserPrefsTableData extends DataClass
    implements Insertable<UserPrefsTableData> {
  final String key;
  final String value;
  const UserPrefsTableData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  UserPrefsTableCompanion toCompanion(bool nullToAbsent) {
    return UserPrefsTableCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory UserPrefsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPrefsTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  UserPrefsTableData copyWith({String? key, String? value}) =>
      UserPrefsTableData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  UserPrefsTableData copyWithCompanion(UserPrefsTableCompanion data) {
    return UserPrefsTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPrefsTableData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPrefsTableData &&
          other.key == this.key &&
          other.value == this.value);
}

class UserPrefsTableCompanion extends UpdateCompanion<UserPrefsTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const UserPrefsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPrefsTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<UserPrefsTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPrefsTableCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return UserPrefsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPrefsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ColdSmartDatabase extends GeneratedDatabase {
  _$ColdSmartDatabase(QueryExecutor e) : super(e);
  $ColdSmartDatabaseManager get managers => $ColdSmartDatabaseManager(this);
  late final $DevicesTableTable devicesTable = $DevicesTableTable(this);
  late final $ChamberReadingsTableTable chamberReadingsTable =
      $ChamberReadingsTableTable(this);
  late final $AlertsTableTable alertsTable = $AlertsTableTable(this);
  late final $GoodsBatchesTableTable goodsBatchesTable =
      $GoodsBatchesTableTable(this);
  late final $OfflineSyncQueueTableTable offlineSyncQueueTable =
      $OfflineSyncQueueTableTable(this);
  late final $CropProfilesTableTable cropProfilesTable =
      $CropProfilesTableTable(this);
  late final $UserPrefsTableTable userPrefsTable = $UserPrefsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        devicesTable,
        chamberReadingsTable,
        alertsTable,
        goodsBatchesTable,
        offlineSyncQueueTable,
        cropProfilesTable,
        userPrefsTable
      ];
}

typedef $$DevicesTableTableCreateCompanionBuilder = DevicesTableCompanion
    Function({
  required String id,
  required String deviceId,
  required String name,
  Value<String> status,
  Value<String?> location,
  Value<String?> firmwareVersion,
  Value<double?> healthScore,
  Value<String?> lastSeenAt,
  Value<String> chambersJson,
  Value<bool> isSynced,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$DevicesTableTableUpdateCompanionBuilder = DevicesTableCompanion
    Function({
  Value<String> id,
  Value<String> deviceId,
  Value<String> name,
  Value<String> status,
  Value<String?> location,
  Value<String?> firmwareVersion,
  Value<double?> healthScore,
  Value<String?> lastSeenAt,
  Value<String> chambersJson,
  Value<bool> isSynced,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$DevicesTableTableTableManager extends RootTableManager<
    _$ColdSmartDatabase,
    $DevicesTableTable,
    DevicesTableData,
    $$DevicesTableTableFilterComposer,
    $$DevicesTableTableOrderingComposer,
    $$DevicesTableTableCreateCompanionBuilder,
    $$DevicesTableTableUpdateCompanionBuilder> {
  $$DevicesTableTableTableManager(
      _$ColdSmartDatabase db, $DevicesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DevicesTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DevicesTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> firmwareVersion = const Value.absent(),
            Value<double?> healthScore = const Value.absent(),
            Value<String?> lastSeenAt = const Value.absent(),
            Value<String> chambersJson = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesTableCompanion(
            id: id,
            deviceId: deviceId,
            name: name,
            status: status,
            location: location,
            firmwareVersion: firmwareVersion,
            healthScore: healthScore,
            lastSeenAt: lastSeenAt,
            chambersJson: chambersJson,
            isSynced: isSynced,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String deviceId,
            required String name,
            Value<String> status = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> firmwareVersion = const Value.absent(),
            Value<double?> healthScore = const Value.absent(),
            Value<String?> lastSeenAt = const Value.absent(),
            Value<String> chambersJson = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesTableCompanion.insert(
            id: id,
            deviceId: deviceId,
            name: name,
            status: status,
            location: location,
            firmwareVersion: firmwareVersion,
            healthScore: healthScore,
            lastSeenAt: lastSeenAt,
            chambersJson: chambersJson,
            isSynced: isSynced,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$DevicesTableTableFilterComposer
    extends FilterComposer<_$ColdSmartDatabase, $DevicesTableTable> {
  $$DevicesTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get location => $state.composableBuilder(
      column: $state.table.location,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get firmwareVersion => $state.composableBuilder(
      column: $state.table.firmwareVersion,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get healthScore => $state.composableBuilder(
      column: $state.table.healthScore,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get lastSeenAt => $state.composableBuilder(
      column: $state.table.lastSeenAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get chambersJson => $state.composableBuilder(
      column: $state.table.chambersJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$DevicesTableTableOrderingComposer
    extends OrderingComposer<_$ColdSmartDatabase, $DevicesTableTable> {
  $$DevicesTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get location => $state.composableBuilder(
      column: $state.table.location,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get firmwareVersion => $state.composableBuilder(
      column: $state.table.firmwareVersion,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get healthScore => $state.composableBuilder(
      column: $state.table.healthScore,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get lastSeenAt => $state.composableBuilder(
      column: $state.table.lastSeenAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get chambersJson => $state.composableBuilder(
      column: $state.table.chambersJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ChamberReadingsTableTableCreateCompanionBuilder
    = ChamberReadingsTableCompanion Function({
  Value<int> id,
  required String chamberId,
  required String deviceId,
  required String recordedAt,
  Value<double?> temperature,
  Value<double?> humidity,
  Value<double?> co2,
  Value<double?> o2,
  Value<double?> ethylene,
  Value<double?> carbonMonoxide,
  Value<double?> methane,
  Value<double?> healthScore,
  Value<bool> isSynced,
});
typedef $$ChamberReadingsTableTableUpdateCompanionBuilder
    = ChamberReadingsTableCompanion Function({
  Value<int> id,
  Value<String> chamberId,
  Value<String> deviceId,
  Value<String> recordedAt,
  Value<double?> temperature,
  Value<double?> humidity,
  Value<double?> co2,
  Value<double?> o2,
  Value<double?> ethylene,
  Value<double?> carbonMonoxide,
  Value<double?> methane,
  Value<double?> healthScore,
  Value<bool> isSynced,
});

class $$ChamberReadingsTableTableTableManager extends RootTableManager<
    _$ColdSmartDatabase,
    $ChamberReadingsTableTable,
    ChamberReadingsTableData,
    $$ChamberReadingsTableTableFilterComposer,
    $$ChamberReadingsTableTableOrderingComposer,
    $$ChamberReadingsTableTableCreateCompanionBuilder,
    $$ChamberReadingsTableTableUpdateCompanionBuilder> {
  $$ChamberReadingsTableTableTableManager(
      _$ColdSmartDatabase db, $ChamberReadingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$ChamberReadingsTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$ChamberReadingsTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> chamberId = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String> recordedAt = const Value.absent(),
            Value<double?> temperature = const Value.absent(),
            Value<double?> humidity = const Value.absent(),
            Value<double?> co2 = const Value.absent(),
            Value<double?> o2 = const Value.absent(),
            Value<double?> ethylene = const Value.absent(),
            Value<double?> carbonMonoxide = const Value.absent(),
            Value<double?> methane = const Value.absent(),
            Value<double?> healthScore = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              ChamberReadingsTableCompanion(
            id: id,
            chamberId: chamberId,
            deviceId: deviceId,
            recordedAt: recordedAt,
            temperature: temperature,
            humidity: humidity,
            co2: co2,
            o2: o2,
            ethylene: ethylene,
            carbonMonoxide: carbonMonoxide,
            methane: methane,
            healthScore: healthScore,
            isSynced: isSynced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String chamberId,
            required String deviceId,
            required String recordedAt,
            Value<double?> temperature = const Value.absent(),
            Value<double?> humidity = const Value.absent(),
            Value<double?> co2 = const Value.absent(),
            Value<double?> o2 = const Value.absent(),
            Value<double?> ethylene = const Value.absent(),
            Value<double?> carbonMonoxide = const Value.absent(),
            Value<double?> methane = const Value.absent(),
            Value<double?> healthScore = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              ChamberReadingsTableCompanion.insert(
            id: id,
            chamberId: chamberId,
            deviceId: deviceId,
            recordedAt: recordedAt,
            temperature: temperature,
            humidity: humidity,
            co2: co2,
            o2: o2,
            ethylene: ethylene,
            carbonMonoxide: carbonMonoxide,
            methane: methane,
            healthScore: healthScore,
            isSynced: isSynced,
          ),
        ));
}

class $$ChamberReadingsTableTableFilterComposer
    extends FilterComposer<_$ColdSmartDatabase, $ChamberReadingsTableTable> {
  $$ChamberReadingsTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get chamberId => $state.composableBuilder(
      column: $state.table.chamberId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get recordedAt => $state.composableBuilder(
      column: $state.table.recordedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get temperature => $state.composableBuilder(
      column: $state.table.temperature,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get humidity => $state.composableBuilder(
      column: $state.table.humidity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get co2 => $state.composableBuilder(
      column: $state.table.co2,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get o2 => $state.composableBuilder(
      column: $state.table.o2,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get ethylene => $state.composableBuilder(
      column: $state.table.ethylene,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get carbonMonoxide => $state.composableBuilder(
      column: $state.table.carbonMonoxide,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get methane => $state.composableBuilder(
      column: $state.table.methane,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get healthScore => $state.composableBuilder(
      column: $state.table.healthScore,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ChamberReadingsTableTableOrderingComposer
    extends OrderingComposer<_$ColdSmartDatabase, $ChamberReadingsTableTable> {
  $$ChamberReadingsTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get chamberId => $state.composableBuilder(
      column: $state.table.chamberId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get recordedAt => $state.composableBuilder(
      column: $state.table.recordedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get temperature => $state.composableBuilder(
      column: $state.table.temperature,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get humidity => $state.composableBuilder(
      column: $state.table.humidity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get co2 => $state.composableBuilder(
      column: $state.table.co2,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get o2 => $state.composableBuilder(
      column: $state.table.o2,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get ethylene => $state.composableBuilder(
      column: $state.table.ethylene,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get carbonMonoxide => $state.composableBuilder(
      column: $state.table.carbonMonoxide,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get methane => $state.composableBuilder(
      column: $state.table.methane,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get healthScore => $state.composableBuilder(
      column: $state.table.healthScore,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AlertsTableTableCreateCompanionBuilder = AlertsTableCompanion
    Function({
  required String id,
  required String deviceId,
  Value<String?> chamberId,
  required String severity,
  required String status,
  required String alertType,
  required String title,
  required String cause,
  required String impact,
  required String recommendedAction,
  Value<double?> currentValue,
  required String triggeredAt,
  Value<bool> isRead,
  Value<bool> isSynced,
  Value<int> rowid,
});
typedef $$AlertsTableTableUpdateCompanionBuilder = AlertsTableCompanion
    Function({
  Value<String> id,
  Value<String> deviceId,
  Value<String?> chamberId,
  Value<String> severity,
  Value<String> status,
  Value<String> alertType,
  Value<String> title,
  Value<String> cause,
  Value<String> impact,
  Value<String> recommendedAction,
  Value<double?> currentValue,
  Value<String> triggeredAt,
  Value<bool> isRead,
  Value<bool> isSynced,
  Value<int> rowid,
});

class $$AlertsTableTableTableManager extends RootTableManager<
    _$ColdSmartDatabase,
    $AlertsTableTable,
    AlertsTableData,
    $$AlertsTableTableFilterComposer,
    $$AlertsTableTableOrderingComposer,
    $$AlertsTableTableCreateCompanionBuilder,
    $$AlertsTableTableUpdateCompanionBuilder> {
  $$AlertsTableTableTableManager(
      _$ColdSmartDatabase db, $AlertsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AlertsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AlertsTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> chamberId = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> alertType = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> cause = const Value.absent(),
            Value<String> impact = const Value.absent(),
            Value<String> recommendedAction = const Value.absent(),
            Value<double?> currentValue = const Value.absent(),
            Value<String> triggeredAt = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlertsTableCompanion(
            id: id,
            deviceId: deviceId,
            chamberId: chamberId,
            severity: severity,
            status: status,
            alertType: alertType,
            title: title,
            cause: cause,
            impact: impact,
            recommendedAction: recommendedAction,
            currentValue: currentValue,
            triggeredAt: triggeredAt,
            isRead: isRead,
            isSynced: isSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String deviceId,
            Value<String?> chamberId = const Value.absent(),
            required String severity,
            required String status,
            required String alertType,
            required String title,
            required String cause,
            required String impact,
            required String recommendedAction,
            Value<double?> currentValue = const Value.absent(),
            required String triggeredAt,
            Value<bool> isRead = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlertsTableCompanion.insert(
            id: id,
            deviceId: deviceId,
            chamberId: chamberId,
            severity: severity,
            status: status,
            alertType: alertType,
            title: title,
            cause: cause,
            impact: impact,
            recommendedAction: recommendedAction,
            currentValue: currentValue,
            triggeredAt: triggeredAt,
            isRead: isRead,
            isSynced: isSynced,
            rowid: rowid,
          ),
        ));
}

class $$AlertsTableTableFilterComposer
    extends FilterComposer<_$ColdSmartDatabase, $AlertsTableTable> {
  $$AlertsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get chamberId => $state.composableBuilder(
      column: $state.table.chamberId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get severity => $state.composableBuilder(
      column: $state.table.severity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get alertType => $state.composableBuilder(
      column: $state.table.alertType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get cause => $state.composableBuilder(
      column: $state.table.cause,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get impact => $state.composableBuilder(
      column: $state.table.impact,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get recommendedAction => $state.composableBuilder(
      column: $state.table.recommendedAction,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get currentValue => $state.composableBuilder(
      column: $state.table.currentValue,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get triggeredAt => $state.composableBuilder(
      column: $state.table.triggeredAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isRead => $state.composableBuilder(
      column: $state.table.isRead,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AlertsTableTableOrderingComposer
    extends OrderingComposer<_$ColdSmartDatabase, $AlertsTableTable> {
  $$AlertsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get chamberId => $state.composableBuilder(
      column: $state.table.chamberId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get severity => $state.composableBuilder(
      column: $state.table.severity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get alertType => $state.composableBuilder(
      column: $state.table.alertType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get cause => $state.composableBuilder(
      column: $state.table.cause,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get impact => $state.composableBuilder(
      column: $state.table.impact,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get recommendedAction => $state.composableBuilder(
      column: $state.table.recommendedAction,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get currentValue => $state.composableBuilder(
      column: $state.table.currentValue,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get triggeredAt => $state.composableBuilder(
      column: $state.table.triggeredAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isRead => $state.composableBuilder(
      column: $state.table.isRead,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$GoodsBatchesTableTableCreateCompanionBuilder
    = GoodsBatchesTableCompanion Function({
  required String id,
  required String chamberId,
  required String name,
  required String category,
  Value<double?> quantityKg,
  required String stage,
  Value<String?> harvestDate,
  Value<String?> storageDate,
  Value<int?> remainingShelfLifeDays,
  Value<double?> spoilageRiskScore,
  Value<bool> isSynced,
  required String createdAt,
  Value<int> rowid,
});
typedef $$GoodsBatchesTableTableUpdateCompanionBuilder
    = GoodsBatchesTableCompanion Function({
  Value<String> id,
  Value<String> chamberId,
  Value<String> name,
  Value<String> category,
  Value<double?> quantityKg,
  Value<String> stage,
  Value<String?> harvestDate,
  Value<String?> storageDate,
  Value<int?> remainingShelfLifeDays,
  Value<double?> spoilageRiskScore,
  Value<bool> isSynced,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$GoodsBatchesTableTableTableManager extends RootTableManager<
    _$ColdSmartDatabase,
    $GoodsBatchesTableTable,
    GoodsBatchesTableData,
    $$GoodsBatchesTableTableFilterComposer,
    $$GoodsBatchesTableTableOrderingComposer,
    $$GoodsBatchesTableTableCreateCompanionBuilder,
    $$GoodsBatchesTableTableUpdateCompanionBuilder> {
  $$GoodsBatchesTableTableTableManager(
      _$ColdSmartDatabase db, $GoodsBatchesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$GoodsBatchesTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$GoodsBatchesTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chamberId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double?> quantityKg = const Value.absent(),
            Value<String> stage = const Value.absent(),
            Value<String?> harvestDate = const Value.absent(),
            Value<String?> storageDate = const Value.absent(),
            Value<int?> remainingShelfLifeDays = const Value.absent(),
            Value<double?> spoilageRiskScore = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoodsBatchesTableCompanion(
            id: id,
            chamberId: chamberId,
            name: name,
            category: category,
            quantityKg: quantityKg,
            stage: stage,
            harvestDate: harvestDate,
            storageDate: storageDate,
            remainingShelfLifeDays: remainingShelfLifeDays,
            spoilageRiskScore: spoilageRiskScore,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chamberId,
            required String name,
            required String category,
            Value<double?> quantityKg = const Value.absent(),
            required String stage,
            Value<String?> harvestDate = const Value.absent(),
            Value<String?> storageDate = const Value.absent(),
            Value<int?> remainingShelfLifeDays = const Value.absent(),
            Value<double?> spoilageRiskScore = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GoodsBatchesTableCompanion.insert(
            id: id,
            chamberId: chamberId,
            name: name,
            category: category,
            quantityKg: quantityKg,
            stage: stage,
            harvestDate: harvestDate,
            storageDate: storageDate,
            remainingShelfLifeDays: remainingShelfLifeDays,
            spoilageRiskScore: spoilageRiskScore,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$GoodsBatchesTableTableFilterComposer
    extends FilterComposer<_$ColdSmartDatabase, $GoodsBatchesTableTable> {
  $$GoodsBatchesTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get chamberId => $state.composableBuilder(
      column: $state.table.chamberId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get quantityKg => $state.composableBuilder(
      column: $state.table.quantityKg,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get stage => $state.composableBuilder(
      column: $state.table.stage,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get harvestDate => $state.composableBuilder(
      column: $state.table.harvestDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get storageDate => $state.composableBuilder(
      column: $state.table.storageDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get remainingShelfLifeDays => $state.composableBuilder(
      column: $state.table.remainingShelfLifeDays,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get spoilageRiskScore => $state.composableBuilder(
      column: $state.table.spoilageRiskScore,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$GoodsBatchesTableTableOrderingComposer
    extends OrderingComposer<_$ColdSmartDatabase, $GoodsBatchesTableTable> {
  $$GoodsBatchesTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get chamberId => $state.composableBuilder(
      column: $state.table.chamberId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get quantityKg => $state.composableBuilder(
      column: $state.table.quantityKg,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get stage => $state.composableBuilder(
      column: $state.table.stage,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get harvestDate => $state.composableBuilder(
      column: $state.table.harvestDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get storageDate => $state.composableBuilder(
      column: $state.table.storageDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get remainingShelfLifeDays => $state.composableBuilder(
      column: $state.table.remainingShelfLifeDays,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get spoilageRiskScore => $state.composableBuilder(
      column: $state.table.spoilageRiskScore,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$OfflineSyncQueueTableTableCreateCompanionBuilder
    = OfflineSyncQueueTableCompanion Function({
  required String id,
  required String entityType,
  Value<String?> entityId,
  required String action,
  required String payloadJson,
  required String clientTimestamp,
  Value<int> retryCount,
  Value<bool> isProcessed,
  Value<int> rowid,
});
typedef $$OfflineSyncQueueTableTableUpdateCompanionBuilder
    = OfflineSyncQueueTableCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String?> entityId,
  Value<String> action,
  Value<String> payloadJson,
  Value<String> clientTimestamp,
  Value<int> retryCount,
  Value<bool> isProcessed,
  Value<int> rowid,
});

class $$OfflineSyncQueueTableTableTableManager extends RootTableManager<
    _$ColdSmartDatabase,
    $OfflineSyncQueueTableTable,
    OfflineSyncQueueTableData,
    $$OfflineSyncQueueTableTableFilterComposer,
    $$OfflineSyncQueueTableTableOrderingComposer,
    $$OfflineSyncQueueTableTableCreateCompanionBuilder,
    $$OfflineSyncQueueTableTableUpdateCompanionBuilder> {
  $$OfflineSyncQueueTableTableTableManager(
      _$ColdSmartDatabase db, $OfflineSyncQueueTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$OfflineSyncQueueTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$OfflineSyncQueueTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String?> entityId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String> clientTimestamp = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<bool> isProcessed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineSyncQueueTableCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payloadJson: payloadJson,
            clientTimestamp: clientTimestamp,
            retryCount: retryCount,
            isProcessed: isProcessed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            Value<String?> entityId = const Value.absent(),
            required String action,
            required String payloadJson,
            required String clientTimestamp,
            Value<int> retryCount = const Value.absent(),
            Value<bool> isProcessed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineSyncQueueTableCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payloadJson: payloadJson,
            clientTimestamp: clientTimestamp,
            retryCount: retryCount,
            isProcessed: isProcessed,
            rowid: rowid,
          ),
        ));
}

class $$OfflineSyncQueueTableTableFilterComposer
    extends FilterComposer<_$ColdSmartDatabase, $OfflineSyncQueueTableTable> {
  $$OfflineSyncQueueTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get entityType => $state.composableBuilder(
      column: $state.table.entityType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get entityId => $state.composableBuilder(
      column: $state.table.entityId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get action => $state.composableBuilder(
      column: $state.table.action,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payloadJson => $state.composableBuilder(
      column: $state.table.payloadJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get clientTimestamp => $state.composableBuilder(
      column: $state.table.clientTimestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get retryCount => $state.composableBuilder(
      column: $state.table.retryCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isProcessed => $state.composableBuilder(
      column: $state.table.isProcessed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$OfflineSyncQueueTableTableOrderingComposer
    extends OrderingComposer<_$ColdSmartDatabase, $OfflineSyncQueueTableTable> {
  $$OfflineSyncQueueTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get entityType => $state.composableBuilder(
      column: $state.table.entityType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get entityId => $state.composableBuilder(
      column: $state.table.entityId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get action => $state.composableBuilder(
      column: $state.table.action,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payloadJson => $state.composableBuilder(
      column: $state.table.payloadJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get clientTimestamp => $state.composableBuilder(
      column: $state.table.clientTimestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get retryCount => $state.composableBuilder(
      column: $state.table.retryCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isProcessed => $state.composableBuilder(
      column: $state.table.isProcessed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CropProfilesTableTableCreateCompanionBuilder
    = CropProfilesTableCompanion Function({
  required String id,
  required String name,
  required String category,
  required String profileType,
  Value<double?> tempMin,
  Value<double?> tempMax,
  Value<double?> humidityMin,
  Value<double?> humidityMax,
  Value<int?> storageDurationDays,
  Value<int?> shelfLifeDays,
  Value<String?> description,
  required String cachedAt,
  Value<int> rowid,
});
typedef $$CropProfilesTableTableUpdateCompanionBuilder
    = CropProfilesTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> category,
  Value<String> profileType,
  Value<double?> tempMin,
  Value<double?> tempMax,
  Value<double?> humidityMin,
  Value<double?> humidityMax,
  Value<int?> storageDurationDays,
  Value<int?> shelfLifeDays,
  Value<String?> description,
  Value<String> cachedAt,
  Value<int> rowid,
});

class $$CropProfilesTableTableTableManager extends RootTableManager<
    _$ColdSmartDatabase,
    $CropProfilesTableTable,
    CropProfilesTableData,
    $$CropProfilesTableTableFilterComposer,
    $$CropProfilesTableTableOrderingComposer,
    $$CropProfilesTableTableCreateCompanionBuilder,
    $$CropProfilesTableTableUpdateCompanionBuilder> {
  $$CropProfilesTableTableTableManager(
      _$ColdSmartDatabase db, $CropProfilesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CropProfilesTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$CropProfilesTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> profileType = const Value.absent(),
            Value<double?> tempMin = const Value.absent(),
            Value<double?> tempMax = const Value.absent(),
            Value<double?> humidityMin = const Value.absent(),
            Value<double?> humidityMax = const Value.absent(),
            Value<int?> storageDurationDays = const Value.absent(),
            Value<int?> shelfLifeDays = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CropProfilesTableCompanion(
            id: id,
            name: name,
            category: category,
            profileType: profileType,
            tempMin: tempMin,
            tempMax: tempMax,
            humidityMin: humidityMin,
            humidityMax: humidityMax,
            storageDurationDays: storageDurationDays,
            shelfLifeDays: shelfLifeDays,
            description: description,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String category,
            required String profileType,
            Value<double?> tempMin = const Value.absent(),
            Value<double?> tempMax = const Value.absent(),
            Value<double?> humidityMin = const Value.absent(),
            Value<double?> humidityMax = const Value.absent(),
            Value<int?> storageDurationDays = const Value.absent(),
            Value<int?> shelfLifeDays = const Value.absent(),
            Value<String?> description = const Value.absent(),
            required String cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CropProfilesTableCompanion.insert(
            id: id,
            name: name,
            category: category,
            profileType: profileType,
            tempMin: tempMin,
            tempMax: tempMax,
            humidityMin: humidityMin,
            humidityMax: humidityMax,
            storageDurationDays: storageDurationDays,
            shelfLifeDays: shelfLifeDays,
            description: description,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
        ));
}

class $$CropProfilesTableTableFilterComposer
    extends FilterComposer<_$ColdSmartDatabase, $CropProfilesTableTable> {
  $$CropProfilesTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileType => $state.composableBuilder(
      column: $state.table.profileType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get tempMin => $state.composableBuilder(
      column: $state.table.tempMin,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get tempMax => $state.composableBuilder(
      column: $state.table.tempMax,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get humidityMin => $state.composableBuilder(
      column: $state.table.humidityMin,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get humidityMax => $state.composableBuilder(
      column: $state.table.humidityMax,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get storageDurationDays => $state.composableBuilder(
      column: $state.table.storageDurationDays,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get shelfLifeDays => $state.composableBuilder(
      column: $state.table.shelfLifeDays,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get cachedAt => $state.composableBuilder(
      column: $state.table.cachedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CropProfilesTableTableOrderingComposer
    extends OrderingComposer<_$ColdSmartDatabase, $CropProfilesTableTable> {
  $$CropProfilesTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileType => $state.composableBuilder(
      column: $state.table.profileType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get tempMin => $state.composableBuilder(
      column: $state.table.tempMin,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get tempMax => $state.composableBuilder(
      column: $state.table.tempMax,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get humidityMin => $state.composableBuilder(
      column: $state.table.humidityMin,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get humidityMax => $state.composableBuilder(
      column: $state.table.humidityMax,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get storageDurationDays => $state.composableBuilder(
      column: $state.table.storageDurationDays,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get shelfLifeDays => $state.composableBuilder(
      column: $state.table.shelfLifeDays,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get cachedAt => $state.composableBuilder(
      column: $state.table.cachedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$UserPrefsTableTableCreateCompanionBuilder = UserPrefsTableCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$UserPrefsTableTableUpdateCompanionBuilder = UserPrefsTableCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$UserPrefsTableTableTableManager extends RootTableManager<
    _$ColdSmartDatabase,
    $UserPrefsTableTable,
    UserPrefsTableData,
    $$UserPrefsTableTableFilterComposer,
    $$UserPrefsTableTableOrderingComposer,
    $$UserPrefsTableTableCreateCompanionBuilder,
    $$UserPrefsTableTableUpdateCompanionBuilder> {
  $$UserPrefsTableTableTableManager(
      _$ColdSmartDatabase db, $UserPrefsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UserPrefsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UserPrefsTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserPrefsTableCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserPrefsTableCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
        ));
}

class $$UserPrefsTableTableFilterComposer
    extends FilterComposer<_$ColdSmartDatabase, $UserPrefsTableTable> {
  $$UserPrefsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$UserPrefsTableTableOrderingComposer
    extends OrderingComposer<_$ColdSmartDatabase, $UserPrefsTableTable> {
  $$UserPrefsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $ColdSmartDatabaseManager {
  final _$ColdSmartDatabase _db;
  $ColdSmartDatabaseManager(this._db);
  $$DevicesTableTableTableManager get devicesTable =>
      $$DevicesTableTableTableManager(_db, _db.devicesTable);
  $$ChamberReadingsTableTableTableManager get chamberReadingsTable =>
      $$ChamberReadingsTableTableTableManager(_db, _db.chamberReadingsTable);
  $$AlertsTableTableTableManager get alertsTable =>
      $$AlertsTableTableTableManager(_db, _db.alertsTable);
  $$GoodsBatchesTableTableTableManager get goodsBatchesTable =>
      $$GoodsBatchesTableTableTableManager(_db, _db.goodsBatchesTable);
  $$OfflineSyncQueueTableTableTableManager get offlineSyncQueueTable =>
      $$OfflineSyncQueueTableTableTableManager(_db, _db.offlineSyncQueueTable);
  $$CropProfilesTableTableTableManager get cropProfilesTable =>
      $$CropProfilesTableTableTableManager(_db, _db.cropProfilesTable);
  $$UserPrefsTableTableTableManager get userPrefsTable =>
      $$UserPrefsTableTableTableManager(_db, _db.userPrefsTable);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$coldSmartDbHash() => r'e167bbf31dfb7e3e8fa8a66d338e6f214dcfa2c1';

/// See also [coldSmartDb].
@ProviderFor(coldSmartDb)
final coldSmartDbProvider = AutoDisposeProvider<ColdSmartDatabase>.internal(
  coldSmartDb,
  name: r'coldSmartDbProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$coldSmartDbHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ColdSmartDbRef = AutoDisposeProviderRef<ColdSmartDatabase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
