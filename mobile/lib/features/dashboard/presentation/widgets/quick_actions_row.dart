import 'package:flutter/material.dart';
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
