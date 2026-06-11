/// ColdSmart Login Screen
/// Farmer-first: Phone/OTP primary, Email/Password secondary
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CSColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),

              // ── Logo ──────────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: CSColors.primaryGradient,
                      borderRadius: CSRadius.all(12),
                    ),
                    child: const Icon(Icons.ac_unit, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ColdSmart', style: CSTextStyles.displaySmall),
                      Text(
                        'Cold Storage Operating System',
                        style: CSTextStyles.bodySmall.copyWith(color: CSColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 48),

              Text('Welcome Back', style: CSTextStyles.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Sign in to manage your cold storage',
                style: CSTextStyles.bodyMedium,
              ),

              const SizedBox(height: 32),

              // ── Tab Bar ───────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: CSColors.surfaceDark,
                  borderRadius: CSRadius.cardBorder,
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: CSColors.accent,
                    borderRadius: CSRadius.cardBorder,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: CSTextStyles.labelLarge,
                  unselectedLabelStyle: CSTextStyles.labelLarge,
                  labelColor: Colors.white,
                  unselectedLabelColor: CSColors.textSecondary,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: '📱  Phone / OTP'),
                    Tab(text: '✉️  Email'),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _PhoneOTPTab(
                      controller: _phoneController,
                      isLoading: _isLoading,
                      onRequestOTP: _requestOTP,
                    ),
                    _EmailPasswordTab(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      isLoading: _isLoading,
                      onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                      onLogin: _emailLogin,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Divider ───────────────────────────────────────────────────
              Row(children: [
                const Expanded(child: Divider(color: CSColors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR', style: CSTextStyles.labelSmall),
                ),
                const Expanded(child: Divider(color: CSColors.border)),
              ]),

              const SizedBox(height: 24),

              // ── Demo mode hint ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CSColors.accent.withOpacity(0.08),
                  border: Border.all(color: CSColors.accent.withOpacity(0.3)),
                  borderRadius: CSRadius.cardBorder,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: CSColors.accent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'New user? Contact your cold storage operator to get your account.',
                        style: CSTextStyles.bodySmall.copyWith(color: CSColors.accent),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnack('Please enter your phone number');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).loginWithPhone(phone, 'dummy_password');
      if (mounted) {
        context.push('/otp?target=${Uri.encodeComponent(phone)}&purpose=login');
      }
    } catch (e) {
      if (mounted) _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _emailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).loginWithEmail(email, password);
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: CSColors.critical),
    );
  }
}


// ─── Phone / OTP Tab ──────────────────────────────────────────────────────────

class _PhoneOTPTab extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onRequestOTP;

  const _PhoneOTPTab({
    required this.controller,
    required this.isLoading,
    required this.onRequestOTP,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone Number', style: CSTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: CSTextStyles.bodyLarge,
          decoration: const InputDecoration(
            hintText: '+91 9876543210',
            prefixIcon: Icon(Icons.phone_outlined, color: CSColors.textSecondary),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onRequestOTP,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Send OTP'),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'A 6-digit OTP will be sent to your phone',
            style: CSTextStyles.bodySmall.copyWith(color: CSColors.textTertiary),
          ),
        ),
      ],
    );
  }
}


// ─── Email / Password Tab ─────────────────────────────────────────────────────

class _EmailPasswordTab extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  const _EmailPasswordTab({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email', style: CSTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: CSTextStyles.bodyLarge,
          decoration: const InputDecoration(
            hintText: 'you@example.com',
            prefixIcon: Icon(Icons.email_outlined, color: CSColors.textSecondary),
          ),
        ),
        const SizedBox(height: 16),
        Text('Password', style: CSTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: passwordController,
          obscureText: obscurePassword,
          style: CSTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outlined, color: CSColors.textSecondary),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: CSColors.textSecondary,
              ),
              onPressed: onTogglePassword,
            ),
          ),
          onFieldSubmitted: (_) => onLogin(),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onLogin,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Sign In'),
          ),
        ),
      ],
    );
  }
}
