import os

widgets = {
    "fleet_status_card.dart": """import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FleetStatusRow extends StatelessWidget {
  final int total;
  final int healthy;
  final int warning;
  final int critical;
  final int offline;

  const FleetStatusRow({
    super.key,
    required this.total,
    required this.healthy,
    required this.warning,
    required this.critical,
    required this.offline,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth > 800;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _buildCard(context, total, 'Total Storages', 'All your cold storages', CSColors.accent, CSColors.accentLight.withOpacity(0.2), Icons.inventory_2_outlined),
          _buildCard(context, healthy, 'Healthy', 'Working fine', CSColors.success, CSColors.successLight, Icons.check_circle_outline),
          _buildCard(context, warning, 'Warning', 'Needs attention', CSColors.warning, CSColors.warningLight, Icons.warning_amber_rounded),
          _buildCard(context, critical, 'Critical', 'Immediate action', CSColors.critical, CSColors.criticalLight, Icons.water_drop_outlined),
          _buildCard(context, offline, 'Offline', 'Not connected', CSColors.offline, CSColors.offlineLight, Icons.wifi_off),
        ],
      );
    });
  }

  Widget _buildCard(BuildContext context, int count, String title, String subtitle, Color color, Color bgColor, IconData icon) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CSColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CSShadows.cardLight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count', style: CSTextStyles.displayMedium),
                const SizedBox(height: 4),
                Text(title, style: CSTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text(subtitle, style: CSTextStyles.labelSmall.copyWith(color: CSColors.textTertiaryLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
""",
    
    "active_alert_card.dart": """import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/domain/models/alert.dart';

class ActiveAlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback onTap;

  const ActiveAlertCard({super.key, required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = CSColors.forSeverity(alert.severity);
    final bgColor = _getBgColor(alert.severity);
    final icon = _getIcon(alert.alertType);
    final isCritical = alert.severity.toLowerCase() == 'critical';

    return Container(
      width: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Storage B > Chamber 2', style: CSTextStyles.labelMedium.copyWith(color: CSColors.textPrimaryLight)),
              const Spacer(),
              Text('5 min ago', style: CSTextStyles.labelSmall),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert.message.split(' ').take(2).join(' '), style: CSTextStyles.titleLarge),
                    const SizedBox(height: 4),
                    Text('Current: 55%  Required: 85-95%', style: CSTextStyles.bodySmall),
                    if (isCritical) ...[
                      const SizedBox(height: 4),
                      Text('Estimated shelf life loss: 2 days', style: CSTextStyles.labelMedium.copyWith(color: color)),
                    ] else ...[
                      const SizedBox(height: 4),
                      Text('Estimated inventory at risk: ₹50,000', style: CSTextStyles.labelMedium.copyWith(color: color)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color.withOpacity(0.5)),
              foregroundColor: color,
              backgroundColor: CSColors.surfaceLight,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  Color _getBgColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'emergency': return CSColors.emergencyLight;
      case 'critical': return CSColors.criticalLight;
      case 'warning': return CSColors.warningLight;
      default: return CSColors.infoLight;
    }
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'temperature': return Icons.thermostat;
      case 'humidity': return Icons.water_drop;
      case 'co2': return Icons.cloud;
      case 'ethylene': return Icons.science;
      case 'door': return Icons.door_front_door;
      default: return Icons.warning_amber_rounded;
    }
  }
}
""",

    "storage_card.dart": """import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/domain/models/device.dart';

class StorageCard extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;

  const StorageCard({super.key, required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = CSColors.forDeviceStatus(device.status);
    final overallHealth = _getMockHealth(device.name);

    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CSColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CSShadows.cardLight,
        border: Border.all(color: CSColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(device.name, style: CSTextStyles.titleLarge),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Text(device.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              Icon(Icons.domain, color: CSColors.textDisabledLight, size: 28),
            ],
          ),
          const SizedBox(height: 8),
          Text('Active • 2 Chambers', style: CSTextStyles.bodySmall),
          Text('Tomato, Potato', style: CSTextStyles.bodySmall),
          const SizedBox(height: 20),
          Text('Overall Health', style: CSTextStyles.labelSmall),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('$overallHealth%', style: CSTextStyles.headlineLarge.copyWith(color: statusColor)),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: overallHealth / 100,
                    backgroundColor: statusColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetricMini(icon: Icons.thermostat, value: '4.2°C', label: 'Temp', color: CSColors.success),
              _MetricMini(icon: Icons.water_drop, value: '88%', label: 'Humidity', color: CSColors.accent),
              _MetricMini(icon: Icons.cloud, value: '620', label: 'CO2 ppm', color: CSColors.success),
              _MetricMini(icon: Icons.science, value: '0.7', label: 'Ethylene', color: CSColors.success),
            ],
          ),
          const Spacer(),
          Center(
            child: TextButton(
              onPressed: onTap,
              child: Text('View Details →', style: TextStyle(color: CSColors.accent, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  int _getMockHealth(String name) {
    if (name.contains('A')) return 95;
    if (name.contains('B')) return 72;
    if (name.contains('C')) return 45;
    return 89;
  }
}

class _MetricMini extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricMini({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: CSTextStyles.labelLarge),
        Text(label, style: CSTextStyles.labelSmall),
      ],
    );
  }
}
""",

    "quick_actions_row.dart": """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _ActionCard(icon: Icons.add_circle, title: 'Add Goods', subtitle: 'Add new inventory', color: CSColors.success, onTap: () => context.go('/goods/add')),
        _ActionCard(icon: Icons.settings, title: 'Recommended Settings', subtitle: 'Apply best settings', color: CSColors.accent, onTap: () => context.go('/settings')),
        _ActionCard(icon: Icons.support_agent, title: 'Technician Support', subtitle: 'Request assistance', color: CSColors.emergency, onTap: () => context.go('/technician')),
        _ActionCard(icon: Icons.description, title: 'Reports', subtitle: 'View & export', color: CSColors.warning, onTap: () => context.go('/reports')),
        _ActionCard(icon: Icons.monitor_heart, title: 'Diagnostics', subtitle: 'Check system health', color: CSColors.info, onTap: () => context.go('/technician')),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CSColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CSColors.borderLight.withOpacity(0.5)),
          boxShadow: CSShadows.cardLight,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: CSTextStyles.titleMedium),
                  Text(subtitle, style: CSTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
"""
}

base_path = r"c:\work\cold_v1.0.1\mobile\lib\features\dashboard\presentation\widgets"
for filename, content in widgets.items():
    with open(os.path.join(base_path, filename), "w", encoding="utf-8") as f:
        f.write(content)

print("Updated 4 widgets.")
