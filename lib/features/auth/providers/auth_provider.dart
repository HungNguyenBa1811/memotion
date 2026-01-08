import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network.dart';
import '../data/data.dart';
import '../data/providers/auth_providers.dart';
import '../models/user_model.dart';

// Auth State
enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? accessToken;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.accessToken,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? accessToken,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      error: error,
    );
  }
}

// Auth Notifier - Uses real AuthRepository
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    return switch (result) {
      Success(:final data) => _handleLoginSuccess(data, email),
      Failure(:final exception) => _handleError(exception),
    };
  }

  /// Register new user
  /// Note: API requires phone, using email as phone for now
  Future<bool> register(String nickname, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authRepository.register(
      fullName: nickname,
      email: email,
      password: password,
      phone: '', // API requires phone, can be empty or implement phone input
      role: UserRole.patient,
    );

    return switch (result) {
      Success(:final data) => _handleRegisterSuccess(data),
      Failure(:final exception) => _handleError(exception),
    };
  }

  bool _handleLoginSuccess(LoginResponseDto data, String email) {
    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ 🎉 AUTH PROVIDER: Login state updated');
    debugPrint('│ Email: $email');
    debugPrint('│ Token saved: ${data.accessToken.substring(0, 20)}...');
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );

    // Create user from login response
    final user = User(
      id: '', // Login response doesn't include user ID
      email: email,
      nickname: email.split('@').first, // Use email prefix as nickname
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      accessToken: data.accessToken,
    );
    return true;
  }

  bool _handleRegisterSuccess(RegisterResponseDto data) {
    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ 🎉 AUTH PROVIDER: Registration state updated');
    debugPrint('│ User ID: ${data.userId}');
    debugPrint('│ Email: ${data.email}');
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );

    // Create user from register response
    final user = User(
      id: data.userId,
      email: data.email,
      nickname: data.fullName,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(status: AuthStatus.authenticated, user: user);
    return true;
  }

  bool _handleError(ApiException exception) {
    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ ❌ AUTH PROVIDER: Error occurred');
    debugPrint('│ Type: ${exception.runtimeType}');
    debugPrint('│ Message: ${exception.message}');
    debugPrint('│ Status code: ${exception.statusCode}');
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );

    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      error: exception.message,
    );
    return false;
  }

  /// Logout - clear token and state
  Future<void> logout() async {
    ApiClient.instance.clearAuthToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider - Uses AuthRepository
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
