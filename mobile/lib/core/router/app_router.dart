/// ColdSmart App Router
/// Go Router configuration with auth guards and deep linking
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/devices/presentation/screens/device_list_screen.dart';
import '../../features/devices/presentation/screens/device_detail_screen.dart';
import '../../features/devices/presentation/screens/add_device_screen.dart';
import '../../features/chambers/presentation/screens/chamber_detail_screen.dart';
import '../../features/goods/presentation/screens/goods_screen.dart';
import '../../features/goods/presentation/screens/add_goods_screen.dart';
import '../../features/alerts/presentation/screens/alerts_screen.dart';
import '../../features/alerts/presentation/screens/alert_detail_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/technician/presentation/screens/technician_screen.dart';
import '../../features/technician/presentation/screens/diagnostics_screen.dart';
import '../../features/technician/presentation/screens/ota_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/audit/presentation/screens/audit_screen.dart';
import '../../features/crop_profiles/presentation/screens/crop_profiles_screen.dart';
import '../shell/main_shell.dart';
import '../../features/auth/domain/auth_provider.dart';

part 'app_router.g.dart';

// ─── Route Names ─────────────────────────────────────────────────────────────

class Routes {
  static const splash = '/';
  static const login = '/login';
  static const otp = '/otp';

  // Shell routes
  static const dashboard = '/dashboard';
  static const devices = '/devices';
  static const deviceDetail = '/devices/:deviceId';
  static const addDevice = '/devices/add';
  static const chamberDetail = '/devices/:deviceId/chamber/:chamberId';
  static const goods = '/goods';
  static const addGoods = '/goods/add';
  static const alerts = '/alerts';
  static const alertDetail = '/alerts/:alertId';
  static const reports = '/reports';
  static const technician = '/technician';
  static const diagnostics = '/technician/diagnostics/:deviceId';
  static const ota = '/technician/ota/:deviceId';
  static const settings = '/settings';
  static const audit = '/audit';
  static const cropProfiles = '/crop-profiles';
}


// ─── Router Provider ─────────────────────────────────────────────────────────

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.otp ||
          state.matchedLocation == Routes.splash;

      if (!isLoggedIn && !isAuthRoute) {
        return Routes.login;
      }
      if (isLoggedIn && isAuthRoute && state.matchedLocation != Routes.splash) {
        return Routes.dashboard;
      }
      return null;
    },
    routes: [
      // ── Splash ──────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const SplashScreen(),
      ),

      // ── Auth ────────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.otp,
        builder: (context, state) => OtpScreen(
          target: state.uri.queryParameters['target'] ?? '',
          purpose: state.uri.queryParameters['purpose'] ?? 'login',
        ),
      ),

      // ── Main Shell (bottom nav) ──────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: Routes.dashboard,
            pageBuilder: (context, state) => _slide(const DashboardScreen()),
          ),
          GoRoute(
            path: Routes.devices,
            pageBuilder: (context, state) => _slide(const DeviceListScreen()),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, __) => const AddDeviceScreen(),
              ),
              GoRoute(
                path: ':deviceId',
                builder: (_, state) => DeviceDetailScreen(
                  deviceId: state.pathParameters['deviceId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'chamber/:chamberId',
                    builder: (_, state) => ChamberDetailScreen(
                      deviceId: state.pathParameters['deviceId']!,
                      chamberId: state.pathParameters['chamberId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: Routes.goods,
            pageBuilder: (context, state) => _slide(const GoodsScreen()),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, state) => AddGoodsScreen(
                  chamberId: state.uri.queryParameters['chamberId'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.alerts,
            pageBuilder: (context, state) => _slide(const AlertsScreen()),
            routes: [
              GoRoute(
                path: ':alertId',
                builder: (_, state) => AlertDetailScreen(
                  alertId: state.pathParameters['alertId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.reports,
            pageBuilder: (context, state) => _slide(const ReportsScreen()),
          ),
          GoRoute(
            path: Routes.technician,
            pageBuilder: (context, state) => _slide(const TechnicianScreen()),
            routes: [
              GoRoute(
                path: 'diagnostics/:deviceId',
                builder: (_, state) => DiagnosticsScreen(
                  deviceId: state.pathParameters['deviceId']!,
                ),
              ),
              GoRoute(
                path: 'ota/:deviceId',
                builder: (_, state) => OtaScreen(
                  deviceId: state.pathParameters['deviceId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.settings,
            pageBuilder: (context, state) => _slide(const SettingsScreen()),
          ),
          GoRoute(
            path: Routes.audit,
            pageBuilder: (context, state) => _slide(const AuditScreen()),
          ),
          GoRoute(
            path: Routes.cropProfiles,
            pageBuilder: (context, state) => _slide(const CropProfilesScreen()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}

CustomTransitionPage<void> _slide(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondary, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}
