import 'package:flutter/foundation.dart';

import 'api_exceptions.dart';

/// Result wrapper for repository operations
///
/// Dùng sealed class để type-safe error handling
sealed class Result<T> {
  const Result();

  /// Execute a function and wrap result in Result
  static Future<Result<T>> guard<T>(Future<T> Function() fn) async {
    try {
      final data = await fn();
      return Success(data);
    } on ApiException catch (e) {
      debugPrint(
        '┌─────────────────────────────────────────────────────────────',
      );
      debugPrint('│ 🛡️ RESULT.GUARD: Caught ApiException');
      debugPrint('│ Type: ${e.runtimeType}');
      debugPrint('│ Message: ${e.message}');
      debugPrint('│ Status: ${e.statusCode}');
      debugPrint(
        '└─────────────────────────────────────────────────────────────',
      );
      return Failure(e);
    } catch (e, stackTrace) {
      debugPrint(
        '┌─────────────────────────────────────────────────────────────',
      );
      debugPrint('│ ⚠️ RESULT.GUARD: Caught unknown exception');
      debugPrint('│ Type: ${e.runtimeType}');
      debugPrint('│ Error: $e');
      debugPrint('│ Stack: $stackTrace');
      debugPrint(
        '└─────────────────────────────────────────────────────────────',
      );
      return Failure(UnknownApiException(message: e.toString()));
    }
  }

  /// Map success value
  Result<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success(:final data) => Success(mapper(data)),
      Failure(:final exception) => Failure(exception),
    };
  }

  /// Get data or null
  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    Failure() => null,
  };

  /// Check if success
  bool get isSuccess => this is Success<T>;

  /// Check if failure
  bool get isFailure => this is Failure<T>;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final ApiException exception;
  const Failure(this.exception);

  String get message => exception.message;
}
