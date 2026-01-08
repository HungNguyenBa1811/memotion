import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/token_storage.dart';

/// Callback type cho việc xử lý unauthorized (401)
typedef OnUnauthorizedCallback = Future<void> Function();

/// Auth Interceptor - Tự động gắn token và xử lý 401
///
/// Features:
/// - Tự động thêm Authorization header từ secure storage
/// - Xử lý 401 Unauthorized: xóa token và trigger logout
/// - Có thể mở rộng để refresh token
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final OnUnauthorizedCallback? _onUnauthorized;

  /// Global callback khi gặp 401 - sẽ được set từ AuthNotifier
  static OnUnauthorizedCallback? globalOnUnauthorized;

  AuthInterceptor({
    TokenStorage? tokenStorage,
    OnUnauthorizedCallback? onUnauthorized,
  })  : _tokenStorage = tokenStorage ?? TokenStorage.instance,
        _onUnauthorized = onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header cho public endpoints (login, register)
    if (_isPublicEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    // Lấy token từ secure storage và gắn vào header
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint('🔑 AuthInterceptor: Token attached to request');
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      debugPrint(
        '┌─────────────────────────────────────────────────────────────',
      );
      debugPrint('│ 🔒 AuthInterceptor: 401 Unauthorized detected');
      debugPrint('│ Endpoint: ${err.requestOptions.uri}');
      debugPrint('│ Clearing tokens and triggering logout...');
      debugPrint(
        '└─────────────────────────────────────────────────────────────',
      );

      // Xóa token hết hạn
      await _tokenStorage.clearAll();

      // Trigger logout callback
      final callback = _onUnauthorized ?? globalOnUnauthorized;
      if (callback != null) {
        await callback();
      }
    }

    handler.next(err);
  }

  /// Kiểm tra xem endpoint có phải public không (không cần token)
  bool _isPublicEndpoint(String path) {
    const publicPaths = [
      '/api/auth/login',
      '/api/auth/register',
      '/api/auth/forgot-password',
      '/api/auth/reset-password',
    ];

    return publicPaths.any((p) => path.contains(p));
  }
}
