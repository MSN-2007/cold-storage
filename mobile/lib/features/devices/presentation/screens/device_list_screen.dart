import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../../core/local_db/drift_database.dart';

class DeviceListScreen extends ConsumerWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(coldSmartDbProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Devices & Gateways'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Pair Device via QR',
            onPressed: () => context.go('/devices/add'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Pair Device'),
        onPressed: () => context.go('/devices/add'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerLowest,
            ],
          ),
        ),
        child: StreamBuilder<List<DevicesTableData>>(
          stream: db.watchAllDevices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load devices: ${snapshot.error}',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              );
            }
            final devices = snapshot.data ?? [];
            if (devices.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sensors_off, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'No devices paired yet.',
                      style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final dev = devices[index];
                final status = dev.status;
                
                Color statusColor;
                IconData statusIcon;
                switch (status.toLowerCase()) {
                  case 'online':
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle_outline;
                    break;
                  case 'warning':
                    statusColor = Colors.orange;
                    statusIcon = Icons.warning_amber_rounded;
                    break;
                  default:
                    statusColor = Colors.grey;
                    statusIcon = Icons.error_outline_rounded;
                }

                List<dynamic> chambers = [];
                try {
                  chambers = jsonDecode(dev.chambersJson) as List<dynamic>;
                } catch (_) {}

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: statusColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.go('/devices/${dev.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dev.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'ID: ${dev.deviceId} • FW: ${dev.firmwareVersion ?? "N/A"}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(statusIcon, color: statusColor, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      status.toUpperCase(),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.door_sliding_outlined,
                                      size: 20, color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${chambers.length} Chambers',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.wifi,
                                      size: 20,
                                      color: status == 'offline'
                                          ? Colors.grey
                                          : theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    status == 'offline' ? 'N/A' : '-65 dBm',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: status == 'offline' ? Colors.grey : null,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.favorite_border,
                                      size: 20, color: statusColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    status == 'offline'
                                        ? 'N/A'
                                        : '${dev.healthScore?.round() ?? 100}% Health',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (dev.location != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  dev.location!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
