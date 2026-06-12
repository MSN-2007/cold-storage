import 'package:flutter/material.dart';
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
          _buildCard(context, total, 'Total Storages', 'All your cold storages', CSColors.accent, CSColors.accentLight.withValues(alpha: 0.2), Icons.inventory_2_outlined),
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
