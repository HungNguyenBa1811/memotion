import 'package:dio/dio.dart';

import 'api_client.dart';
import 'api_exceptions.dart';

/// Base API Service
///
/// Abstract class cho tất cả API services kế thừa
/// Cung cấp các helper methods chung cho việc gọi API
abstract class BaseApiService {
  final Dio dio;

  BaseApiService({Dio? dio}) : dio = dio ?? ApiClient.instance.dio;

  /// GET request với error handling
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return parser(response.data);
    } on DioException catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }

  /// POST request với error handling
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return parser(response.data);
    } on DioException catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }

  /// PUT request với error handling
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return parser(response.data);
    } on DioException catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }

  /// PATCH request với error handling
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return parser(response.data);
    } on DioException catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }

  /// DELETE request với error handling
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return parser(response.data);
    } on DioException catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }
}
