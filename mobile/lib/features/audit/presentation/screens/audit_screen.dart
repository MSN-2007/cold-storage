import 'package:flutter/material.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock logs
    final logs = [
      {
        'action': 'PARAM_CHANGE',
        'user': 'Ram Singh (Owner)',
        'description': 'Target temperature updated to 1.0°C (was 1.5°C) for Chamber 1.',
        'time': '10 mins ago',
        'ip': '192.168.1.42',
      },
      {
        'action': 'REPORT_GENERATED',
        'user': 'Operator Harpreet (Manager)',
        'description': 'compliance report generated: May 2026 Compliance (PDF format).',
        'time': '1 hour ago',
        'ip': '192.168.1.103',
      },
      {
        'action': 'DEVICE_PAIRED',
        'user': 'Ram Singh (Owner)',
        'description': 'device pair request CS-GW-001 registered successfully.',
        'time': '1 day ago',
        'ip': '192.168.1.42',
      },
      {
        'action': 'CALIBRATION',
        'user': 'Technician Amit (Tech)',
        'description': 'NDIR CO₂ sensor calibrated with -25 ppm coefficient offset.',
        'time': '3 days ago',
        'ip': '10.0.2.16',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
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
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final item = logs[index];
            final action = item['action'] as String;

            Color actionColor = Colors.grey;
            IconData actionIcon = Icons.info_outline;

            if (action == 'PARAM_CHANGE') {
              actionColor = Colors.amber;
              actionIcon = Icons.settings_input_component;
            } else if (action == 'REPORT_GENERATED') {
              actionColor = Colors.blue;
              actionIcon = Icons.picture_as_pdf;
            } else if (action == 'DEVICE_PAIRED') {
              actionColor = Colors.green;
              actionIcon = Icons.link;
            } else if (action == 'CALIBRATION') {
              actionColor = Colors.purple;
              actionIcon = Icons.tune;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: actionColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(actionIcon, size: 14, color: actionColor),
                              const SizedBox(width: 4),
                              Text(
                                action,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: actionColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          item['time'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item['description'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'By: ${item['user']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'IP: ${item['ip']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
