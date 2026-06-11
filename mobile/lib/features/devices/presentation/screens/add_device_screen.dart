import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/local_db/drift_database.dart';
import '../../../../core/services/sync_engine.dart';

class AddDeviceScreen extends ConsumerStatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  ConsumerState<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends ConsumerState<AddDeviceScreen> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isScanningBluetooth = false;
  bool _isPairing = false;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _startBluetoothScan() async {
    setState(() {
      _isScanningBluetooth = true;
    });
    // Simulate finding a device
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isScanningBluetooth = false;
        _idController.text = 'CS-GW-099';
        _nameController.text = 'Smart Node 99';
        _locationController.text = 'South Wing';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device found via Bluetooth! Details pre-filled.')),
      );
    }
  }

  void _pairDevice() async {
    if (_idController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out Device ID and Name.')),
      );
      return;
    }

    setState(() {
      _isPairing = true;
    });

    try {
      final db = ref.read(coldSmartDbProvider);
      final uuid = 'device-uuid-${DateTime.now().millisecondsSinceEpoch}';

      // Insert device in local DB
      await db.upsertDevice(DevicesTableCompanion.insert(
        id: uuid,
        deviceId: _idController.text,
        name: _nameController.text,
        status: const drift.Value('online'),
        location: drift.Value(_locationController.text.isEmpty ? null : _locationController.text),
        firmwareVersion: const drift.Value('v1.2.5'),
        healthScore: const drift.Value(100.0),
        lastSeenAt: drift.Value(DateTime.now().toIso8601String()),
        chambersJson: const drift.Value('[]'),
        isSynced: const drift.Value(false),
        updatedAt: DateTime.now().toIso8601String(),
      ));

      // Queue in Sync Engine
      await ref.read(syncEngineProvider.notifier).queueOfflineAction(
        entityType: 'device',
        entityId: uuid,
        action: 'create',
        payload: {
          'device_id': _idController.text,
          'name': _nameController.text,
          'location': _locationController.text,
        },
      );

      if (mounted) {
        setState(() {
          _isPairing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device paired successfully! MQTT credentials sent.')),
        );
        context.go('/devices');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPairing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pair device: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pair New Device'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bluetooth Scan Option
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.bluetooth_searching, size: 48, color: Colors.blue),
                    const SizedBox(height: 12),
                    Text(
                      'Pair nearby device via Bluetooth',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Make sure your ColdSmart sensor node is powered on and within range.',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: _isScanningBluetooth
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.search),
                      label: Text(_isScanningBluetooth ? 'Searching...' : 'Scan for Devices'),
                      onPressed: _isScanningBluetooth ? null : _startBluetoothScan,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Divider or OR text
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR ENTER MANUALLY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),

            // Manual Form Fields
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Hardware Device ID',
                hintText: 'e.g. CS-GW-001',
                prefixIcon: Icon(Icons.tag),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Device Name',
                hintText: 'e.g. Warehouse 1 Gateway',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (Optional)',
                hintText: 'e.g. Block A Shelf 4',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: _isPairing ? null : _pairDevice,
              child: _isPairing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Register & Obtain MQTT Key', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
