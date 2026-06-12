import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TechnicianScreen extends StatelessWidget {
  const TechnicianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock recent logs
    final recentDiagnostics = [
      {
        'device': 'Chamber 1-4 Gateway (CS-GW-001)',
        'status': 'passed',
        'date': '2026-06-09 18:24',
      },
      {
        'device': 'Potato Storage Unit 5 (CS-ND-082)',
        'status': 'warning',
        'date': '2026-06-09 14:02',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Technician Console'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Summary
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.build, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Calibration Compliance: 98%', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('All core sensors calibrated in the last 60 days.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Navigation Links
            Text('Quick Diagnostics & Calibration', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.flash_on, color: Colors.amber),
                    title: const Text('Run Diagnostics'),
                    subtitle: const Text('Test sensors, relays, relays, fans and battery backup.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/technician/diagnostics/device-uuid-1'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
                    title: const Text('Firmware Deployments (OTA)'),
                    subtitle: const Text('Upload binary to MinIO & push upgrades to ESP32 nodes.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/technician/ota/device-uuid-1'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent results
            Text('Recent Diagnostics Runs', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentDiagnostics.length,
              itemBuilder: (context, index) {
                final run = recentDiagnostics[index];
                final status = run['status'] as String;
                final statusColor = status == 'passed' ? Colors.green : Colors.orange;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      status == 'passed' ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                      color: statusColor,
                    ),
                    title: Text(run['device'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Ran: ${run['date']}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
