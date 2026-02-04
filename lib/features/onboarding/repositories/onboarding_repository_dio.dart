import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_client.dart';

class OnboardingRepositoryDio {
  final Dio _dio;

  OnboardingRepositoryDio({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio {
    // Ensure baseUrl is set consistently with ApiConstants if ApiClient wasn't configured
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

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
      // If status is 500, skip this API (treat as success)
      if (e.response?.statusCode == 500) {
        debugPrint(
          '[API] POST /api/users/patients/create-by-caretaker - 500 received, skipping',
        );
        return <String, dynamic>{'skipped': true};
      }
      debugPrint(
        '[API] POST /api/users/patients/create-by-caretaker - error: ${e.message}',
      );
      rethrow;
    }
  }

  Future<bool> postGeneralProfile({required Map<String, dynamic> body}) async {
    try {
      debugPrint(
        '[API] POST ${ApiConstants.patientProfileGeneral} - body: $body',
      );
      final resp = await _dio.post(
        ApiConstants.patientProfileGeneral,
        data: body,
      );
      debugPrint(
        '[API] POST ${ApiConstants.patientProfileGeneral} - status: ${resp.statusCode}',
      );
      debugPrint(
        '[API] POST ${ApiConstants.patientProfileGeneral} - response: ${resp.data}',
      );
      return resp.statusCode == 200 || resp.statusCode == 201;
    } on DioError catch (e) {
      // If status is 400, skip this API (treat as success)
      if (e.response?.statusCode == 400) {
        debugPrint(
          '[API] POST ${ApiConstants.patientProfileGeneral} - 400 received, skipping',
        );
        return true;
      }
      debugPrint(
        '[API] POST ${ApiConstants.patientProfileGeneral} - error: ${e.message}',
      );
      rethrow;
    }
  }

  Future<bool> postPhysicalTherapy({required Map<String, dynamic> body}) async {
    try {
      debugPrint(
        '[API] POST ${ApiConstants.patientProfilePhysicalTherapy} - body: $body',
      );
      final resp = await _dio.post(
        ApiConstants.patientProfilePhysicalTherapy,
        data: body,
      );
      debugPrint(
        '[API] POST ${ApiConstants.patientProfilePhysicalTherapy} - status: ${resp.statusCode}',
      );
      debugPrint(
        '[API] POST ${ApiConstants.patientProfilePhysicalTherapy} - response: ${resp.data}',
      );
      return resp.statusCode == 200 || resp.statusCode == 201;
    } on DioError catch (e) {
      // If status is 400, skip this API (treat as success)
      if (e.response?.statusCode == 400) {
        debugPrint(
          '[API] POST ${ApiConstants.patientProfilePhysicalTherapy} - 400 received, skipping',
        );
        return true;
      }
      debugPrint(
        '[API] POST ${ApiConstants.patientProfilePhysicalTherapy} - error: ${e.message}',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> scanMedicalRecord({
    required List<File> files,
  }) async {
    try {
      final formData = FormData();
      for (final file in files) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ));
      }
      debugPrint(
        '[API] POST ${ApiConstants.scanMedicalRecord} - files: ${files.length}',
      );
      final resp = await _dio.post(
        ApiConstants.scanMedicalRecord,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      debugPrint(
        '[API] POST ${ApiConstants.scanMedicalRecord} - status: ${resp.statusCode}',
      );
      debugPrint(
        '[API] POST ${ApiConstants.scanMedicalRecord} - response: ${resp.data}',
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
        '[API] POST ${ApiConstants.scanMedicalRecord} - error: ${e.message}',
      );
      rethrow;
    }
  }

  /// Generate AI-powered care plan for patient
  /// POST /api/care-plans/generate
  /// Authorization: CARETAKER role required
  Future<Map<String, dynamic>?> generateCarePlan({
    int planDurationDays = 7,
    bool regenerate = false,
  }) async {
    try {
      final body = {
        'plan_duration_days': planDurationDays,
        'regenerate': regenerate,
      };
      debugPrint('[API] POST ${ApiConstants.generateCarePlan} - body: $body');
      final resp = await _dio.post(ApiConstants.generateCarePlan, data: body);
      debugPrint(
        '[API] POST ${ApiConstants.generateCarePlan} - status: ${resp.statusCode}',
      );
      debugPrint(
        '[API] POST ${ApiConstants.generateCarePlan} - response: ${resp.data}',
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data is Map && resp.data['data'] != null
            ? resp.data['data'] as Map<String, dynamic>
            : (resp.data is Map ? resp.data as Map<String, dynamic> : null);
        return data;
      }
      return null;
    } on DioError catch (e) {
      // If status is 400, skip this API (treat as success with empty data)
      if (e.response?.statusCode == 400) {
        debugPrint(
          '[API] POST ${ApiConstants.generateCarePlan} - 400 received, skipping',
        );
        return <String, dynamic>{'skipped': true};
      }
      debugPrint(
        '[API] POST ${ApiConstants.generateCarePlan} - error: ${e.message}',
      );
      rethrow;
    }
  }
}
