import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logging Interceptor for debugging API calls
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ 🚀 REQUEST: ${options.method} ${options.uri}');
    debugPrint('│ Headers: ${options.headers}');
    if (options.data != null) {
      _printData('│ Body', options.data);
    }
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint(
      '│ ✅ RESPONSE [${response.statusCode}]: ${response.requestOptions.uri}',
    );
    _printData('│ Data', response.data);
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint(
      '│ ❌ ERROR [${err.response?.statusCode}]: ${err.requestOptions.uri}',
    );
    debugPrint('│ Type: ${err.type}');
    debugPrint('│ Message: ${err.message}');
    if (err.response?.data != null) {
      _printData('│ Response', err.response?.data);
    }
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );
    handler.next(err);
  }

  /// Pretty print JSON data
  void _printData(String prefix, dynamic data) {
    try {
      if (data is Map || data is List) {
        const encoder = JsonEncoder.withIndent('  ');
        final prettyJson = encoder.convert(data);
        for (final line in prettyJson.split('\n')) {
          debugPrint('$prefix: $line');
        }
      } else {
        debugPrint('$prefix: $data');
      }
    } catch (e) {
      debugPrint('$prefix: $data');
    }
  }
}

/// Error Interceptor for handling common errors
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle token expiration
    if (err.response?.statusCode == 401) {
      debugPrint('🔒 Token expired or unauthorized');
    }
    handler.next(err);
  }
}
