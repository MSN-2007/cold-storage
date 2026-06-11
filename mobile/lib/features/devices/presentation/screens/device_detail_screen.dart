import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../../core/local_db/drift_database.dart';


class DeviceDetailScreen extends ConsumerWidget {
  final String deviceId;

  const DeviceDetailScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            appBar: AppBar(title: const Text('Device Details')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final devices = snapshot.data ?? [];
        final device = devices.firstWhere(
          (d) => d.id == deviceId || d.deviceId == deviceId,
          orElse: () => devices.first,
        );

        List<dynamic> chambers = [];
        try {
          chambers = jsonDecode(device.chambersJson) as List<dynamic>;
        } catch (_) {}

        final statusColor = (device.status == 'online' ? Colors.green : Colors.red);

        return Scaffold(
          appBar: AppBar(
            title: Text(device.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () => context.go('/settings'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health Score & Status Panel
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 72,
                                height: 72,
                                child: CircularProgressIndicator(
                                  value: ((device.healthScore ?? 100.0)) / 100,
                                  strokeWidth: 8,
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                '${(device.healthScore ?? 100.0).round()}%',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Device Status: ${device.status.toUpperCase()}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'SSID: ColdStorage-SafeNET (-65 dBm)',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  'IP: 192.168.1.144',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Device Details Card
                  Text('Hardware Info', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          _buildDetailRow(context, 'Hardware Type', 'ESP32-S3-DevKitC-1'),
                          _buildDetailRow(context, 'MAC Address', 'AA:BB:CC:DD:EE:01'),
                          _buildDetailRow(context, 'Firmware Version', device.firmwareVersion ?? 'v1.2.4'),
                          _buildDetailRow(context, 'Hardware Unique ID', device.deviceId),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chambers Associated
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Associated Chambers', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Chamber'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  chambers.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No chambers linked to this device.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: chambers.length,
                          itemBuilder: (context, index) {
                            final ch = chambers[index] as Map<String, dynamic>;
                            final chamberId = ch['id'] as String;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                onTap: () => context.go('/devices/${device.id}/chamber/$chamberId'),
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  child: Text('${ch['number']}'),
                                ),
                                title: Text(ch['name'] as String),
                                subtitle: Text('Crop: ${ch['crop']}'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${ch['temp']}°C',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Target: ${ch['target_temp']}°C',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 24),

                  // Technician Controls Section
                  Text('Technician Console', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.health_and_safety_outlined),
                          label: const Text('Diagnostics'),
                          onPressed: () => context.go('/technician/diagnostics/${device.id}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.system_update_alt),
                          label: const Text('Firmware (OTA)'),
                          onPressed: () => context.go('/technician/ota/${device.id}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
