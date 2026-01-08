import 'package:json_annotation/json_annotation.dart';

part 'base_response.g.dart';

/// Generic base response wrapper for all API responses
///
/// The API wraps all successful data in this structure:
/// ```json
/// {
///   "code": "200",
///   "message": "",
///   "data": <T>
/// }
/// ```
@JsonSerializable(genericArgumentFactories: true)
class BaseResponse<T> {
  final String code;
  final String message;
  final T? data;

  const BaseResponse({required this.code, required this.message, this.data});

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$BaseResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$BaseResponseToJson(this, toJsonT);

  /// Check if response is successful
  bool get isSuccess => code == '200' || code == '201';
}
