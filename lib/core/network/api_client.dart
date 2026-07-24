import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'api_interceptors.dart';
import 'auth_interceptor.dart';

/// Singleton API Client using Dio
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 5),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Thứ tự interceptors quan trọng:
    // 1. AuthInterceptor - Gắn token vào request, xử lý 401
    // 2. LoggingInterceptor - Log request/response
    // 3. ErrorInterceptor - Xử lý các lỗi khác
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  /// Set Authorization token (deprecated - sử dụng TokenStorage thay thế)
  @Deprecated('Use TokenStorage.instance.saveAccessToken() instead')
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear Authorization token (deprecated - sử dụng TokenStorage thay thế)
  @Deprecated('Use TokenStorage.instance.clearAll() instead')
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
