import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/local_db/drift_database.dart';
import '../../auth/domain/auth_provider.dart';

part 'dashboard_provider.g.dart';

class DashboardData {
  final String userName;
  final DateTime lastUpdated;
  final int activeAlertCount;
  final int totalDevices;
  final int healthyDevices;
  final int warningDevices;
  final int criticalDevices;
  final int offlineDevices;
  final List<AlertsTableData> activeAlerts;
  final List<DevicesTableData> devices;

  DashboardData({
    required this.userName,
    required this.lastUpdated,
    required this.activeAlertCount,
    required this.totalDevices,
    required this.healthyDevices,
    required this.warningDevices,
    required this.criticalDevices,
    required this.offlineDevices,
    required this.activeAlerts,
    required this.devices,
  });
}

@riverpod
Future<DashboardData> dashboard(DashboardRef ref) async {
  final db = ref.watch(coldSmartDbProvider);
  final auth = ref.watch(authStateProvider);
  final user = auth.valueOrNull;

  final devices = await db.getAllDevices();
  
  // Stream or watch can be used, but since this is a FutureProvider, we fetch them asynchronously.
  // We also query active alerts.
  final activeAlerts = await db.watchActiveAlerts().first;
  final activeAlertCount = await db.countUnreadAlerts();

  int healthy = 0;
  int warning = 0;
  int critical = 0;
  int offline = 0;

  for (final device in devices) {
    switch (device.status.toLowerCase()) {
      case 'online':
        healthy++;
        break;
      case 'warning':
        warning++;
        break;
      case 'critical':
        critical++;
        break;
      case 'offline':
      default:
        offline++;
        break;
    }
  }

  return DashboardData(
    userName: user?.name ?? 'Farmer Ram',
    lastUpdated: DateTime.now(),
    activeAlertCount: activeAlertCount,
    totalDevices: devices.length,
    healthyDevices: healthy,
    warningDevices: warning,
    criticalDevices: critical,
    offlineDevices: offline,
    activeAlerts: activeAlerts,
    devices: devices,
  );
}
