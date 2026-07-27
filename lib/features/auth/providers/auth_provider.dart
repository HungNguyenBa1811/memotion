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
  final String? role;

  /// Backend báo đây là lần đăng nhập đầu tiên -> phải chạy onboarding wizard.
  final bool isFirstLogin;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.accessToken,
    this.error,
    this.role,
    this.isFirstLogin = false,
  });

  /// Check if user is a patient (skip onboarding)
  bool get isPatient => role?.toUpperCase() == 'PATIENT';

  /// Cần ép về onboarding wizard hay không.
  /// Patient không chạy onboarding — wizard này dành cho caretaker khai hộ.
  bool get needsOnboarding =>
      status == AuthStatus.authenticated && isFirstLogin && !isPatient;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? accessToken,
    String? error,
    String? role,
    bool? isFirstLogin,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      error: error,
      role: role ?? this.role,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
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
      debugPrint('🔐 AuthNotifier: Fetching user details from /api/users/me');

      // Set loading state
      state = state.copyWith(status: AuthStatus.loading, accessToken: token);

      final userDetailResult = await _authRepository.getUserDetails();

      switch (userDetailResult) {
        case Success(:final data):
          debugPrint('🔐 AuthNotifier: Session restored successfully');
          debugPrint('🔐 AuthNotifier: role = ${data.role}');
          debugPrint('🔐 AuthNotifier: is_first_login = ${data.isFirstLogin}');

          final user = User(
            id: data.userId,
            email: data.email,
            nickname: data.fullName,
            createdAt: DateTime.now(),
          );

          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            accessToken: token,
            role: data.role,
            isFirstLogin: data.isFirstLogin ?? false,
          );

        case Failure(:final exception):
          debugPrint(
            '🔐 AuthNotifier: Failed to restore session: ${exception.message}',
          );
          debugPrint(
            '🔐 AuthNotifier: Token might be expired, clearing storage',
          );
          // Token invalid hoặc expired, clear storage
          await _tokenStorage.clearAll();
          state = state.copyWith(status: AuthStatus.unauthenticated);
      }
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
      error: 'Your session has ended. Please sign in again.',
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
    final accessToken = data.accessToken;
    await _tokenStorage.saveAccessToken(accessToken);
    await _tokenStorage.saveTokenType(data.tokenType);

    // Gọi API /api/users/me để lấy role
    debugPrint('🔐 AuthNotifier: Fetching user details to get role...');
    final userDetailResult = await _authRepository.getUserDetails();

    String? role;
    User user;
    // /api/users/me là nguồn chính; login response chỉ là fallback.
    bool isFirstLogin = data.isFirstLogin ?? false;

    switch (userDetailResult) {
      case Success(:final data):
        debugPrint('🔐 AuthNotifier: Got user details - role: ${data.role}');
        debugPrint(
          '🔐 AuthNotifier: is_first_login: ${data.isFirstLogin}',
        );
        role = data.role;
        isFirstLogin = data.isFirstLogin ?? isFirstLogin;
        user = User(
          id: data.userId,
          email: data.email,
          nickname: data.fullName,
          createdAt: DateTime.now(),
        );
      case Failure(:final exception):
        debugPrint(
          '🔐 AuthNotifier: Failed to get user details: ${exception.message}',
        );
        // Fallback to basic user info
        user = User(
          id: '',
          email: email,
          nickname: email.split('@').first,
          createdAt: DateTime.now(),
        );
    }

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      accessToken: accessToken,
      role: role,
      isFirstLogin: isFirstLogin,
    );
    return true;
  }

  /// Đánh dấu đã xong onboarding để router thôi ép về wizard.
  /// Chỉ ảnh hưởng state phía client — backend vẫn là nguồn sự thật ở lần login sau.
  void markOnboardingComplete() {
    if (!state.isFirstLogin) return;
    debugPrint('🔐 AuthNotifier: Onboarding completed, clearing isFirstLogin');
    state = state.copyWith(isFirstLogin: false);
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

    // Sau khi đăng ký thành công, API không trả về access token theo spec,
    // người dùng cần đăng nhập bằng credentials vừa tạo. Không thiết lập
    // trạng thái `authenticated` để tránh router redirect tới onboarding.
    state = state.copyWith(status: AuthStatus.unauthenticated, user: user);
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
