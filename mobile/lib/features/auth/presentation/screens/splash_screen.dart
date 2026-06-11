/// ColdSmart Splash Screen
/// Checks auth state, routes accordingly
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/local_db/drift_database.dart';
import '../../domain/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scaleAnim = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();

    // After animation, check auth and route
    Future.delayed(const Duration(milliseconds: 2000), _checkAuthAndRoute);
  }

  Future<void> _checkAuthAndRoute() async {
    if (!mounted) return;
    try {
      final db = ref.read(coldSmartDbProvider);
      await db.seedData();
    } catch (e) {
      debugPrint('Error seeding database: $e');
    }
    
    if (!mounted) return;
    final authState = ref.read(authStateProvider);
    if (authState.valueOrNull != null) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CSColors.backgroundDark,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo ────────────────────────────────────────────────────
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: CSColors.primaryGradient,
                    borderRadius: CSRadius.all(24),
                    boxShadow: [
                      BoxShadow(
                        color: CSColors.accent.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.ac_unit, color: Colors.white, size: 52),
                ),
                const SizedBox(height: 24),
                Text(
                  'ColdSmart',
                  style: CSTextStyles.displayLarge.copyWith(
                    fontSize: 36,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [CSColors.textPrimary, CSColors.accent],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Intelligent Cold Storage Operating System',
                  style: CSTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CSColors.accent.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
