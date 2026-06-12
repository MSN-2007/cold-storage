import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/local_db/drift_database.dart';
import '../../../../core/services/sync_engine.dart';
import '../../../../core/services/mqtt_service.dart';
import '../../../auth/domain/auth_provider.dart';

class AlertDetailScreen extends ConsumerStatefulWidget {
  final String alertId;

  const AlertDetailScreen({super.key, required this.alertId});

  @override
  ConsumerState<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends ConsumerState<AlertDetailScreen> {
  bool _isAcknowledging = false;
  bool _isResolving = false;
  bool _isInitialized = false;
  String _currentStatus = 'active';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(coldSmartDbProvider);

    return StreamBuilder<List<AlertsTableData>>(
      stream: db.watchAllAlerts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Alert Context')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final alerts = snapshot.data ?? [];
        final alert = alerts.firstWhere(
          (a) => a.id == widget.alertId,
          orElse: () => alerts.first,
        );

        if (!_isInitialized) {
          _currentStatus = alert.status;
          _isInitialized = true;
        }

        Color severityColor = Colors.grey;
        IconData severityIcon = Icons.info_outline;

        switch (alert.severity.toLowerCase()) {
          case 'critical':
            severityColor = Colors.orange;
            severityIcon = Icons.warning_amber;
            break;
          case 'emergency':
            severityColor = Colors.red;
            severityIcon = Icons.error_outline;
            break;
          case 'warning':
            severityColor = Colors.amber;
            severityIcon = Icons.adjust;
            break;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Alert Context'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Severity Status Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: severityColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(severityIcon, color: severityColor, size: 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: severityColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Status: ${_currentStatus.toUpperCase()} • Time: Triggered Recently'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Telemetry Reading Context
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('CURRENT READING', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              '${alert.currentValue ?? "N/A"}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 40,
                          child: VerticalDivider(),
                        ),
                        Column(
                          children: [
                            const Text('CRITICAL THRESHOLD', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              alert.alertType == 'temperature' ? '1.0 °C' : '90.0 %',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Diagnostic & Cause details
                _buildContextSection(
                  context,
                  'Root Cause Analysis',
                  alert.cause,
                  Icons.search_off_outlined,
                ),
                const SizedBox(height: 16),
                _buildContextSection(
                  context,
                  'Preservation Impact (Q10)',
                  alert.impact,
                  Icons.trending_down,
                ),
                const SizedBox(height: 16),
                _buildContextSection(
                  context,
                  'Recommended Troubleshooting Steps',
                  alert.recommendedAction,
                  Icons.fact_check_outlined,
                ),
                const SizedBox(height: 32),

                // Actions Buttons
                if (_currentStatus == 'active') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isAcknowledging ? null : () => _acknowledgeAlert(alert),
                          child: _isAcknowledging
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Acknowledge'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                          onPressed: _isResolving ? null : () => _resolveAlert(alert),
                          child: _isResolving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Mark Resolved', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ] else if (_currentStatus == 'acknowledged') ...[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    onPressed: _isResolving ? null : () => _resolveAlert(alert),
                    child: _isResolving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Mark Resolved', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('This alert is resolved.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _acknowledgeAlert(AlertsTableData alert) async {
    setState(() {
      _isAcknowledging = true;
    });

    try {
      final db = ref.read(coldSmartDbProvider);
      
      // Update local db
      await db.upsertAlert(AlertsTableCompanion(
        id: drift.Value(alert.id),
        deviceId: drift.Value(alert.deviceId),
        chamberId: drift.Value(alert.chamberId),
        severity: drift.Value(alert.severity),
        status: const drift.Value('acknowledged'),
        alertType: drift.Value(alert.alertType),
        title: drift.Value(alert.title),
        cause: drift.Value(alert.cause),
        impact: drift.Value(alert.impact),
        recommendedAction: drift.Value(alert.recommendedAction),
        currentValue: drift.Value(alert.currentValue),
        triggeredAt: drift.Value(alert.triggeredAt),
        isRead: const drift.Value(true),
        isSynced: const drift.Value(false),
      ));

      // MQTT notification
      final auth = ref.read(authStateProvider);
      final companyId = auth.valueOrNull?.companyId ?? 'company-uuid-67890';
      await ref.read(mqttServiceProvider.notifier).publish(
        'cs/$companyId/device/${alert.deviceId}/alerts/ack',
        {
          'alert_id': alert.id,
          'status': 'acknowledged',
          'acknowledged_at': DateTime.now().toIso8601String(),
        },
      );

      // Queue Sync Engine
      await ref.read(syncEngineProvider.notifier).queueOfflineAction(
        entityType: 'alert',
        entityId: alert.id,
        action: 'update',
        payload: {'status': 'acknowledged'},
      );

      if (mounted) {
        setState(() {
          _isAcknowledging = false;
          _currentStatus = 'acknowledged';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert acknowledged. Team notified.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAcknowledging = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to acknowledge alert: $e')),
        );
      }
    }
  }

  void _resolveAlert(AlertsTableData alert) async {
    setState(() {
      _isResolving = true;
    });

    try {
      final db = ref.read(coldSmartDbProvider);
      
      // Update local db
      await db.upsertAlert(AlertsTableCompanion(
        id: drift.Value(alert.id),
        deviceId: drift.Value(alert.deviceId),
        chamberId: drift.Value(alert.chamberId),
        severity: drift.Value(alert.severity),
        status: const drift.Value('resolved'),
        alertType: drift.Value(alert.alertType),
        title: drift.Value(alert.title),
        cause: drift.Value(alert.cause),
        impact: drift.Value(alert.impact),
        recommendedAction: drift.Value(alert.recommendedAction),
        currentValue: drift.Value(alert.currentValue),
        triggeredAt: drift.Value(alert.triggeredAt),
        isRead: const drift.Value(true),
        isSynced: const drift.Value(false),
      ));

      // MQTT notification
      final auth = ref.read(authStateProvider);
      final companyId = auth.valueOrNull?.companyId ?? 'company-uuid-67890';
      await ref.read(mqttServiceProvider.notifier).publish(
        'cs/$companyId/device/${alert.deviceId}/alerts/resolve',
        {
          'alert_id': alert.id,
          'status': 'resolved',
          'resolved_at': DateTime.now().toIso8601String(),
        },
      );

      // Queue Sync Engine
      await ref.read(syncEngineProvider.notifier).queueOfflineAction(
        entityType: 'alert',
        entityId: alert.id,
        action: 'update',
        payload: {'status': 'resolved'},
      );

      if (mounted) {
        setState(() {
          _isResolving = false;
          _currentStatus = 'resolved';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert marked resolved. Clearing rule parameters.')),
        );
        context.go('/alerts');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResolving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resolve alert: $e')),
        );
      }
    }
  }

  Widget _buildContextSection(BuildContext context, String title, String body, IconData icon) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
