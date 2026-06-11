/// ColdSmart Flutter Main Entry Point
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/local_db/drift_database.dart';

import 'core/services/mqtt_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce portrait + landscape support
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: CSColors.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: ColdSmartApp(),
    ),
  );
}


class ColdSmartApp extends ConsumerWidget {
  const ColdSmartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ColdSmart',
      debugShowCheckedModeBanner: false,
      theme: CSTheme.light,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          // Prevent font scaling to preserve layout
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
