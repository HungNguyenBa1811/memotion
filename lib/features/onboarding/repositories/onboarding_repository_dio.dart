import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class OnboardingRepositoryDio {
  final Dio _dio;

  OnboardingRepositoryDio({Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://your.api.base'));

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      debugPrint('[API] GET /api/users/me - sending request');
      final resp = await _dio.get('/api/users/me');
      debugPrint('[API] GET /api/users/me - status: ${resp.statusCode}');
      debugPrint('[API] GET /api/users/me - response: ${resp.data}');
      if (resp.statusCode == 200) {
        final data = resp.data is Map && resp.data['data'] != null
            ? resp.data['data'] as Map<String, dynamic>
            : (resp.data is Map ? resp.data as Map<String, dynamic> : null);
        return data;
      }
      return null;
    } on DioError catch (e) {
      debugPrint('[API] GET /api/users/me - error: ${e.message}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> createPatient({
    required Map<String, dynamic> body,
  }) async {
    try {
      debugPrint(
        '[API] POST /api/users/patients/create-by-caretaker - body: $body',
      );
      final resp = await _dio.post(
        '/api/users/patients/create-by-caretaker',
        data: body,
      );
      debugPrint(
        '[API] POST /api/users/patients/create-by-caretaker - status: ${resp.statusCode}',
      );
      debugPrint(
        '[API] POST /api/users/patients/create-by-caretaker - response: ${resp.data}',
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data is Map && resp.data['data'] != null
            ? resp.data['data'] as Map<String, dynamic>
            : (resp.data is Map ? resp.data as Map<String, dynamic> : null);
        return data;
      }
      return null;
    } on DioError catch (e) {
      debugPrint(
        '[API] POST /api/users/patients/create-by-caretaker - error: ${e.message}',
      );
      rethrow;
    }
  }

  Future<bool> postGeneralProfile({required Map<String, dynamic> body}) async {
    try {
      debugPrint('[API] POST /api/patient-profiles/general - body: $body');
      final resp = await _dio.post('/api/patient-profiles/general', data: body);
      debugPrint(
        '[API] POST /api/patient-profiles/general - status: ${resp.statusCode}',
      );
      debugPrint(
        '[API] POST /api/patient-profiles/general - response: ${resp.data}',
      );
      return resp.statusCode == 200 || resp.statusCode == 201;
    } on DioError catch (e) {
      debugPrint(
        '[API] POST /api/patient-profiles/general - error: ${e.message}',
      );
      rethrow;
    }
  }

  Future<bool> postPhysicalTherapy({required Map<String, dynamic> body}) async {
    try {
      debugPrint(
        '[API] POST /api/patient-profiles/physical-therapy - body: $body',
      );
      final resp = await _dio.post(
        '/api/patient-profiles/physical-therapy',
        data: body,
      );
      debugPrint(
        '[API] POST /api/patient-profiles/physical-therapy - status: ${resp.statusCode}',
      );
      debugPrint(
        '[API] POST /api/patient-profiles/physical-therapy - response: ${resp.data}',
      );
      return resp.statusCode == 200 || resp.statusCode == 201;
    } on DioError catch (e) {
      debugPrint(
        '[API] POST /api/patient-profiles/physical-therapy - error: ${e.message}',
      );
      rethrow;
    }
  }
}
