import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:convert';
import '../../../../core/local_db/drift_database.dart';
import '../../../../core/services/sync_engine.dart';
import '../../../../core/services/mqtt_service.dart';

import '../../../auth/domain/auth_provider.dart';

class ChamberDetailScreen extends ConsumerStatefulWidget {
  final String deviceId;
  final String chamberId;

  const ChamberDetailScreen({
    super.key,
    required this.deviceId,
    required this.chamberId,
  });

  @override
  ConsumerState<ChamberDetailScreen> createState() => _ChamberDetailScreenState();
}

class _ChamberDetailScreenState extends ConsumerState<ChamberDetailScreen> {
  double _targetTemp = 1.0;
  double _targetHumidity = 90.0;
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(coldSmartDbProvider);

    return StreamBuilder<List<DevicesTableData>>(
      stream: db.watchAllDevices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chamber Details')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final devices = snapshot.data ?? [];
        final device = devices.firstWhere(
          (d) => d.id == widget.deviceId || d.deviceId == widget.deviceId,
          orElse: () => devices.first,
        );

        List<dynamic> chambers = [];
        try {
          chambers = jsonDecode(device.chambersJson) as List<dynamic>;
        } catch (_) {}

        final chamberData = chambers.firstWhere(
          (c) => c['id'] == widget.chamberId,
          orElse: () => {
            'id': widget.chamberId,
            'name': 'Chamber Room',
            'number': 1,
            'crop': 'Unknown Produce',
            'temp': 2.0,
            'target_temp': 2.0,
            'humidity': 90.0,
            'co2': 600,
            'o2': 20.9,
            'ethylene': 0.0,
            'health_score': 100.0,
          },
        ) as Map<String, dynamic>;

        if (!_isInitialized) {
          _targetTemp = (chamberData['target_temp'] as num?)?.toDouble() ?? 2.0;
          _targetHumidity = (chamberData['target_humidity'] as num?)?.toDouble() ?? 90.0;
          _isInitialized = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(chamberData['name'] as String),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Climate Status Cards Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildSensorGauge(
                        context,
                        'Temperature',
                        '${(chamberData['temp'] as num?)?.toStringAsFixed(1) ?? "0.0"} °C',
                        'Target: ${_targetTemp.toStringAsFixed(1)} °C',
                        Colors.blue,
                        Icons.thermostat,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSensorGauge(
                        context,
                        'Humidity',
                        '${(chamberData['humidity'] as num?)?.toStringAsFixed(0) ?? "0"} %',
                        'Target: ${_targetHumidity.toStringAsFixed(0)} %',
                        Colors.cyan,
                        Icons.water_drop,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSensorGauge(
                        context,
                        'CO₂ Levels',
                        '${chamberData['co2'] ?? "450"} ppm',
                        'Max limit: 1200 ppm',
                        Colors.orange,
                        Icons.co2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSensorGauge(
                        context,
                        'O₂ Levels',
                        '${chamberData['o2'] ?? "20.9"} %',
                        'Target: 2.0 %',
                        Colors.purple,
                        Icons.air,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Active Crop Intelligence Profile
                Text('Active Crop Profile', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          radius: 28,
                          child: Icon(Icons.apple, size: 36, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chamberData['crop'] as String,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text('Respiration Mode: Low • Q10 Spoilage: 2.1x'),
                              Text(
                                'Optimized for long-term CA storage (120+ days)',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Batch Details
                Text('Active Inventory Batch', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                FutureBuilder<List<GoodsBatchesTableData>>(
                  future: db.getGoodsForChamber(widget.chamberId),
                  builder: (context, goodsSnapshot) {
                    if (goodsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final goods = goodsSnapshot.data ?? [];
                    if (goods.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'No inventory batches currently in this chamber.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      );
                    }
                    final batch = goods.first;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInventoryRow(context, 'Batch Name', batch.name),
                            _buildInventoryRow(context, 'Weight In Storage', '${batch.quantityKg?.toStringAsFixed(0) ?? "0"} kg'),
                            _buildInventoryRow(context, 'Remaining Shelf Life', '${batch.remainingShelfLifeDays ?? "N/A"} Days'),
                            _buildInventoryRow(
                              context,
                              'Spoilage Risk',
                              '${batch.spoilageRiskScore?.toStringAsFixed(1) ?? "10.0"}% (Very Low)',
                              valueColor: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Temperature Adjust Panel (Farmer-First Simplicity)
                Text('Update Chamber Climate', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Target Temperature', style: theme.textTheme.titleSmall),
                            Text('${_targetTemp.toStringAsFixed(1)} °C', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Slider(
                          value: _targetTemp,
                          min: -2.0,
                          max: 15.0,
                          divisions: 170,
                          label: '${_targetTemp.toStringAsFixed(1)}°C',
                          onChanged: (val) {
                            setState(() {
                              _targetTemp = val;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Target Humidity', style: theme.textTheme.titleSmall),
                            Text('${_targetHumidity.toStringAsFixed(0)} %', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Slider(
                          value: _targetHumidity,
                          min: 50.0,
                          max: 100.0,
                          divisions: 50,
                          label: '${_targetHumidity.toStringAsFixed(0)}%',
                          onChanged: (val) {
                            setState(() {
                              _targetHumidity = val;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                          onPressed: _isSaving ? null : _saveClimate,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Sync Climate Targets (MQTT)', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveClimate() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final db = ref.read(coldSmartDbProvider);
      final devices = await db.getAllDevices();
      final device = devices.firstWhere(
        (d) => d.id == widget.deviceId || d.deviceId == widget.deviceId,
        orElse: () => devices.first,
      );

      List<dynamic> chambers = jsonDecode(device.chambersJson) as List<dynamic>;
      for (var ch in chambers) {
        if (ch['id'] == widget.chamberId) {
          ch['target_temp'] = _targetTemp;
          ch['target_humidity'] = _targetHumidity;
        }
      }

      final updatedChambersJson = jsonEncode(chambers);

      await db.upsertDevice(DevicesTableCompanion(
        id: drift.Value(device.id),
        deviceId: drift.Value(device.deviceId),
        name: drift.Value(device.name),
        status: drift.Value(device.status),
        location: drift.Value(device.location),
        firmwareVersion: drift.Value(device.firmwareVersion),
        healthScore: drift.Value(device.healthScore),
        lastSeenAt: drift.Value(device.lastSeenAt),
        chambersJson: drift.Value(updatedChambersJson),
        isSynced: const drift.Value(false),
        updatedAt: drift.Value(DateTime.now().toIso8601String()),
      ));

      // Publish MQTT Command
      final auth = ref.read(authStateProvider);
      final companyId = auth.valueOrNull?.companyId ?? 'company-uuid-67890';
      final topic = 'cs/$companyId/device/${device.deviceId}/commands';
      final payload = {
        'action': 'set_targets',
        'chamber_id': widget.chamberId,
        'target_temperature': _targetTemp,
        'target_humidity': _targetHumidity,
      };

      await ref.read(mqttServiceProvider.notifier).publish(topic, payload);

      // Queue Offline Action
      await ref.read(syncEngineProvider.notifier).queueOfflineAction(
        entityType: 'chamber_target',
        entityId: widget.chamberId,
        action: 'update',
        payload: payload,
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Climate updated to ${_targetTemp.toStringAsFixed(1)}°C / ${_targetHumidity.toStringAsFixed(0)}% and synced to hardware via MQTT.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update climate: $e')),
        );
      }
    }
  }

  Widget _buildSensorGauge(
    BuildContext context,
    String label,
    String value,
    String target,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(target, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryRow(BuildContext context, String label, String value, {Color? valueColor}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
