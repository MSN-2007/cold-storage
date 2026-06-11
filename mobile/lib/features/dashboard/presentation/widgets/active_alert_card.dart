import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/local_db/drift_database.dart';

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
