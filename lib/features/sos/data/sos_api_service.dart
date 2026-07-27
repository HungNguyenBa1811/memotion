import 'dart:async';

import 'package:dio/dio.dart';

import '../../../core/network/network.dart';
import '../models/sos_alert.dart';

class SosApiService extends BaseApiService {
  SosApiService({super.dio});

  Future<SosTriggerResult> trigger({
    String triggerSource = 'HIDDEN_BUTTON',
    String? message,
    int countdownSeconds = 10,
  }) async {
    final response = await _request(
      'POST',
      ApiConstants.sosTrigger,
      data: {
        'trigger_source': triggerSource,
        if (message != null) 'message': message,
        'countdown_seconds': countdownSeconds.clamp(0, 60),
      },
    );
    final data = _responseData(response);
    return SosTriggerResult(
      alert: SosAlert.fromJson(_asMap(data['alert'])),
      alreadyExists: data['already_exists'] == true,
    );
  }

  Future<SosActiveResult> getActive() async {
    final response = await _request('GET', ApiConstants.sosActive);
    final data = _responseData(response);
    final rawAlert = data['alert'];
    return SosActiveResult(
      needsSupport: data['needs_support'] == true,
      alert: rawAlert is Map
          ? SosAlert.fromJson(Map<String, dynamic>.from(rawAlert))
          : null,
      serverTime: DateTime.tryParse(data['server_time']?.toString() ?? ''),
    );
  }

  Future<SosAlert> cancel(String sosId) =>
      _postAction(ApiConstants.sosCancel(sosId));

  Future<SosAlert> acknowledge(String sosId) =>
      _postAction(ApiConstants.sosAcknowledge(sosId));

  Future<SosAlert> resolve(String sosId) =>
      _postAction(ApiConstants.sosResolve(sosId));

  Future<List<SosAlert>> getHistory({int limit = 50}) async {
    final response = await _request(
      'GET',
      ApiConstants.sosHistory,
      queryParameters: {'limit': limit.clamp(1, 200)},
    );
    final data = response['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => SosAlert.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<SosAlert> _postAction(String path) async {
    final response = await _request('POST', path);
    return SosAlert.fromJson(_asMap(response['data']));
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    const timeout = Duration(seconds: 5);
    final cancelToken = CancelToken();
    var didTimeout = false;
    final timeoutTimer = Timer(timeout, () {
      didTimeout = true;
      cancelToken.cancel('SOS request timed out');
    });

    try {
      final response = await dio.request<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: Options(
          method: method,
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );
      return _asMap(response.data);
    } on DioException catch (error) {
      if (didTimeout) {
        throw const NetworkException(
          message: 'The SOS service did not respond. Retrying automatically.',
        );
      }
      throw ApiExceptionHandler.handle(error);
    } finally {
      timeoutTimer.cancel();
    }
  }

  static Map<String, dynamic> _responseData(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const UnknownApiException(
      message: 'The SOS service returned an unexpected response.',
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const UnknownApiException(
      message: 'The SOS service returned an unexpected response.',
    );
  }
}
