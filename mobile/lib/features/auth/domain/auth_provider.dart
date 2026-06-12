import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

class UserSession {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String companyId;
  final String appMode;
  final String? profileImageUrl;

  UserSession({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.companyId,
    required this.appMode,
    this.profileImageUrl,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'viewer',
      companyId: json['company_id'] as String,
      appMode: json['app_mode'] as String? ?? 'simple',
      profileImageUrl: json['profile_image_url'] as String?,
    );
  }
}

@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  AsyncValue<UserSession?> build() {
    // Return mock initial user session for offline demo / pairing first
    // In production, this reads from secure storage
    return const AsyncValue.data(null);
  }

  Future<void> loginWithPhone(String phone, String password) async {
    state = const AsyncValue.loading();
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      final user = UserSession(
        id: 'user-uuid-12345',
        name: 'Ram Singh (Farmer)',
        email: 'ram.singh@coldsmart.in',
        phone: phone,
        role: 'owner',
        companyId: 'company-uuid-67890',
        appMode: 'simple',
      );
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(seconds: 1));
      final user = UserSession(
        id: 'user-uuid-12345',
        name: 'Operator Harpreet',
        email: email,
        phone: '+919876543210',
        role: 'manager',
        companyId: 'company-uuid-67890',
        appMode: 'expert',
      );
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> verifyOtp(String phoneOrEmail, String otpCode) async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(seconds: 1));
      final user = UserSession(
        id: 'user-uuid-12345',
        name: 'Ram Singh (Farmer)',
        email: 'ram.singh@coldsmart.in',
        phone: phoneOrEmail.contains('@') ? '+919876543210' : phoneOrEmail,
        role: 'owner',
        companyId: 'company-uuid-67890',
        appMode: 'simple',
      );
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleAppMode() async {
    final currentUser = state.valueOrNull;
    if (currentUser != null) {
      final updated = UserSession(
        id: currentUser.id,
        name: currentUser.name,
        email: currentUser.email,
        phone: currentUser.phone,
        role: currentUser.role,
        companyId: currentUser.companyId,
        appMode: currentUser.appMode == 'simple' ? 'expert' : 'simple',
        profileImageUrl: currentUser.profileImageUrl,
      );
      state = AsyncValue.data(updated);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.data(null);
  }
}
