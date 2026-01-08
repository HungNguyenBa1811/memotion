import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network.dart';
import '../../../core/storage/token_storage.dart';
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

// Auth Notifier - Uses real AuthRepository with Secure Storage
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;

  AuthNotifier(this._authRepository, {TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage.instance,
        super(const AuthState()) {
    // Setup global 401 handler
    _setupUnauthorizedHandler();
    // Check for existing token on init
    _initializeFromStorage();
  }

  /// Setup callback khi gặp 401 Unauthorized từ bất kỳ API nào
  void _setupUnauthorizedHandler() {
    AuthInterceptor.globalOnUnauthorized = () async {
      debugPrint('🔒 AuthNotifier: Received 401 from interceptor, logging out');
      await _handleUnauthorized();
    };
  }

  /// Khởi tạo auth state từ stored token
  Future<void> _initializeFromStorage() async {
    final hasToken = await _tokenStorage.hasToken();
    if (hasToken) {
      final token = await _tokenStorage.getAccessToken();
      debugPrint('🔐 AuthNotifier: Found stored token, restoring session');
      state = state.copyWith(
        status: AuthStatus.authenticated,
        accessToken: token,
      );
    } else {
      debugPrint('🔐 AuthNotifier: No stored token found');
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// Xử lý khi bị 401 Unauthorized
  Future<void> _handleUnauthorized() async {
    await _tokenStorage.clearAll();
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      error: 'Session expired. Please login again.',
    );
  }

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
  Future<bool> register(String nickname, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authRepository.register(
      fullName: nickname,
      email: email,
      password: password,
      phone: '',
      role: UserRole.patient,
    );

    return switch (result) {
      Success(:final data) => _handleRegisterSuccess(data),
      Failure(:final exception) => _handleError(exception),
    };
  }

  Future<bool> _handleLoginSuccess(LoginResponseDto data, String email) async {
    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ 🎉 AUTH PROVIDER: Login successful');
    debugPrint('│ Email: $email');
    debugPrint('│ Token: ${data.accessToken.substring(0, 20)}...');
    debugPrint('│ Saving token to secure storage...');
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );

    // Lưu token vào secure storage
    await _tokenStorage.saveAccessToken(data.accessToken);
    await _tokenStorage.saveTokenType(data.tokenType);

    // Create user from login response
    final user = User(
      id: '',
      email: email,
      nickname: email.split('@').first,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      accessToken: data.accessToken,
    );
    return true;
  }

  Future<bool> _handleRegisterSuccess(RegisterResponseDto data) async {
    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ 🎉 AUTH PROVIDER: Registration successful');
    debugPrint('│ User ID: ${data.userId}');
    debugPrint('│ Email: ${data.email}');
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );

    // Note: Register response không có access_token theo spec
    // User cần login sau khi register
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

  /// Logout - clear token from storage and reset state
  Future<void> logout() async {
    debugPrint('🔐 AuthNotifier: Logging out, clearing tokens');
    await _tokenStorage.clearAll();
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

