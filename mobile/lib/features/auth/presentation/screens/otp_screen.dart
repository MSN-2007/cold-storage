/// ColdSmart OTP Verification Screen
/// 6-digit pinput with auto-submit, countdown timer, resend
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String target;
  final String purpose;

  const OtpScreen({super.key, required this.target, required this.purpose});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _resendCountdown = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _resendCountdown = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 0) {
        timer.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    final isPhone = widget.target.contains(RegExp(r'^\+?[0-9]'));
    final display = isPhone ? widget.target : widget.target;

    return Scaffold(
      backgroundColor: CSColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: CSColors.backgroundDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: CSColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(''),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Header ────────────────────────────────────────────────────
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: CSColors.primaryGradient,
                  borderRadius: CSRadius.all(16),
                ),
                child: const Icon(Icons.sms_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 24),
              Text('Enter Verification Code', style: CSTextStyles.displaySmall),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: CSTextStyles.bodyMedium,
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to '),
                    TextSpan(
                      text: display,
                      style: CSTextStyles.bodyMedium.copyWith(
                        color: CSColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── OTP Input ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (i) => _OtpBox(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    onChanged: (value) {
                      if (value.isNotEmpty && i < 5) {
                        _focusNodes[i + 1].requestFocus();
                      } else if (value.isEmpty && i > 0) {
                        _focusNodes[i - 1].requestFocus();
                      }
                      // Auto-submit when all filled
                      if (_otp.length == 6) {
                        _verifyOTP();
                      }
                    },
                    onBackspace: () {
                      if (_controllers[i].text.isEmpty && i > 0) {
                        _focusNodes[i - 1].requestFocus();
                        _controllers[i - 1].clear();
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // ── Verify Button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isLoading || _otp.length < 6) ? null : _verifyOTP,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Verify Code'),
                ),
              ),

              const SizedBox(height: 32),

              // ── Resend ────────────────────────────────────────────────────
              Center(
                child: _resendCountdown > 0
                    ? RichText(
                        text: TextSpan(
                          style: CSTextStyles.bodyMedium,
                          children: [
                            const TextSpan(text: 'Resend code in '),
                            TextSpan(
                              text: '${_resendCountdown}s',
                              style: CSTextStyles.bodyMedium.copyWith(
                                color: CSColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : TextButton(
                        onPressed: _resendOTP,
                        child: Text(
                          'Resend Code',
                          style: CSTextStyles.labelLarge.copyWith(color: CSColors.accent),
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // ── Wrong number hint ─────────────────────────────────────────
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Wrong number? Go back',
                    style: CSTextStyles.bodySmall.copyWith(color: CSColors.textTertiary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOTP() async {
    if (_otp.length != 6) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).verifyOtp(widget.target, _otp);
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: CSColors.critical),
        );
        // Clear OTP on failure
        for (final c in _controllers) c.clear();
        _focusNodes[0].requestFocus();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    await ref.read(authStateProvider.notifier).loginWithPhone(widget.target, 'dummy_password');
    _startCountdown();
  }
}


// ─── OTP Input Box ────────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 58,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: CSTextStyles.numericLarge,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: CSColors.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: CSRadius.all(12),
            borderSide: const BorderSide(color: CSColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: CSRadius.all(12),
            borderSide: const BorderSide(color: CSColors.accent, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
