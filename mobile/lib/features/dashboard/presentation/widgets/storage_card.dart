import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/local_db/drift_database.dart';

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
