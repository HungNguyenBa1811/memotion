import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

// Fake data for demo purposes
class FakeAuthService {
  static final User fakeUser = User(
    id: '1',
    email: 'demo@memotion.app',
    nickname: 'MemotionUser',
    avatarUrl: null,
    createdAt: DateTime.now(),
  );

  Future<User?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Fake validation
    if (email.isNotEmpty && password.length >= 6) {
      return fakeUser.copyWith(email: email);
    }
    return null;
  }

  Future<User?> register(String nickname, String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Fake validation
    if (email.isNotEmpty && password.length >= 6 && nickname.isNotEmpty) {
      return User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        nickname: nickname,
        createdAt: DateTime.now(),
      );
    }
    return null;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

// Auth State
enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.error});

  AuthState copyWith({AuthStatus? status, User? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final FakeAuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Email hoặc mật khẩu không đúng',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Đã có lỗi xảy ra',
      );
      return false;
    }
  }

  Future<bool> register(String nickname, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      final user = await _authService.register(nickname, email, password);
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Không thể tạo tài khoản',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Đã có lỗi xảy ra',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final authServiceProvider = Provider<FakeAuthService>((ref) {
  return FakeAuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
