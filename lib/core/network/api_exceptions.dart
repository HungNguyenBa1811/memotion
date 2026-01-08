import 'package:dio/dio.dart';

/// Base API Exception
sealed class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (statusCode: $statusCode)';
}

/// Network Exception - No internet, timeout, etc.
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Network error occurred. Please check your connection.',
    super.statusCode,
    super.data,
  });
}

/// Server Exception - 5xx errors
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Server error occurred. Please try again later.',
    super.statusCode,
    super.data,
  });
}

/// Unauthorized Exception - 401
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Unauthorized. Please login again.',
    super.statusCode = 401,
    super.data,
  });
}

/// Forbidden Exception - 403
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Access denied.',
    super.statusCode = 403,
    super.data,
  });
}

/// Not Found Exception - 404
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Resource not found.',
    super.statusCode = 404,
    super.data,
  });
}

/// Validation Exception - 422
class ValidationException extends ApiException {
  final List<ValidationError> errors;

  const ValidationException({
    super.message = 'Validation error occurred.',
    super.statusCode = 422,
    super.data,
    this.errors = const [],
  });

  @override
  String toString() {
    if (errors.isNotEmpty) {
      return errors.map((e) => e.message).join(', ');
    }
    return message;
  }
}

/// Validation Error Detail
class ValidationError {
  final List<dynamic> location;
  final String message;
  final String type;

  const ValidationError({
    required this.location,
    required this.message,
    required this.type,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      location: json['loc'] as List<dynamic>? ?? [],
      message: json['msg'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}

/// Bad Request Exception - 400
class BadRequestException extends ApiException {
  const BadRequestException({
    super.message = 'Bad request.',
    super.statusCode = 400,
    super.data,
  });
}

/// Unknown Exception
class UnknownApiException extends ApiException {
  const UnknownApiException({
    super.message = 'An unknown error occurred.',
    super.statusCode,
    super.data,
  });
}

/// Exception Handler - Maps DioException to ApiException
class ApiExceptionHandler {
  static ApiException handle(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timeout. Please try again.',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection. Please check your network.',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return const NetworkException(message: 'Request was cancelled.');

      default:
        return UnknownApiException(
          message: error.message ?? 'An unknown error occurred.',
          data: error.response?.data,
        );
    }
  }

  static ApiException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    if (statusCode == null) {
      return const UnknownApiException(message: 'Unknown error occurred.');
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: _extractMessage(data) ?? 'Bad request.',
          statusCode: statusCode,
          data: data,
        );

      case 401:
        return UnauthorizedException(
          message: _extractMessage(data) ?? 'Unauthorized.',
          data: data,
        );

      case 403:
        return ForbiddenException(
          message: _extractMessage(data) ?? 'Access denied.',
          data: data,
        );

      case 404:
        return NotFoundException(
          message: _extractMessage(data) ?? 'Resource not found.',
          data: data,
        );

      case 422:
        return _handleValidationError(data);

      case final code when code >= 500:
        return ServerException(
          message: _extractMessage(data) ?? 'Server error occurred.',
          statusCode: statusCode,
          data: data,
        );

      default:
        return UnknownApiException(
          message: _extractMessage(data) ?? 'An error occurred.',
          statusCode: statusCode,
          data: data,
        );
    }
  }

  static ValidationException _handleValidationError(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('detail')) {
      final detail = data['detail'];
      if (detail is List) {
        final errors = detail
            .map((e) => ValidationError.fromJson(e as Map<String, dynamic>))
            .toList();
        return ValidationException(
          message: errors.isNotEmpty
              ? errors.first.message
              : 'Validation error occurred.',
          errors: errors,
          data: data,
        );
      }
    }
    return ValidationException(data: data);
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['detail'] as String?;
    }
    return null;
  }
}
