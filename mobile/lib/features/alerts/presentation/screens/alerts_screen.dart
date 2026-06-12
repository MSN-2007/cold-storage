import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/local_db/drift_database.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(coldSmartDbProvider);

    return StreamBuilder<List<AlertsTableData>>(
      stream: db.watchAllAlerts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Alert Center')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Alert Center')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final allAlerts = snapshot.data ?? [];
        final activeAlerts = allAlerts.where((a) => a.status == 'active').toList();
        final ackAlerts = allAlerts.where((a) => a.status == 'acknowledged').toList();
        final resolvedAlerts = allAlerts.where((a) => a.status == 'resolved').toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Alert Center'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Active (${activeAlerts.length})'),
                Tab(text: 'Acknowledged (${ackAlerts.length})'),
                Tab(text: 'Resolved (${resolvedAlerts.length})'),
              ],
            ),
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
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAlertList(context, activeAlerts),
                _buildAlertList(context, ackAlerts),
                _buildAlertList(context, resolvedAlerts),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertList(BuildContext context, List<AlertsTableData> items) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'All clear! No alerts in this tab.',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final alert = items[index];
        final severity = alert.severity;

        Color severityColor = Colors.grey;
        IconData severityIcon = Icons.info_outline;

        if (severity == 'critical') {
          severityColor = Colors.orange;
          severityIcon = Icons.warning_amber;
        } else if (severity == 'emergency') {
          severityColor = Colors.red;
          severityIcon = Icons.error_outline;
        } else if (severity == 'warning') {
          severityColor = Colors.amber;
          severityIcon = Icons.adjust;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: severityColor.withValues(alpha: 0.3), width: 1),
          ),
          child: ListTile(
            onTap: () => context.go('/alerts/${alert.id}'),
            leading: CircleAvatar(
              backgroundColor: severityColor.withValues(alpha: 0.1),
              child: Icon(severityIcon, color: severityColor),
            ),
            title: Text(
              alert.title,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Device: ${alert.deviceId} • Chamber: ${alert.chamberId ?? "N/A"}'),
                Text(
                  'Reading: ${alert.currentValue ?? "N/A"} • ${alert.triggeredAt.split('T').last.substring(0, 5)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}
