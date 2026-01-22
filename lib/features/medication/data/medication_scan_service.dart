import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/base_api_service.dart';
import '../../../core/network/api_constants.dart';
import '../models/medication_scan_dto.dart';

/// API Service for medication scanning functionality
class MedicationScanService extends BaseApiService {
  static const String _tag = 'MedicationScanService';

  MedicationScanService({super.dio});

  /// Scan medication image and get medication information
  /// POST /api/medication-library/scan-image
  ///
  /// Upload an image file to identify medication details
  /// Returns [MedicationScanResponse] with medication info or error
  Future<MedicationScanResponse> scanMedicationImage(File imageFile) async {
    final stopwatch = Stopwatch()..start();
    final fileName = imageFile.path.split('/').last;
    final fileSize = await imageFile.length();

    developer.log(
      'Starting medication scan request',
      name: _tag,
      error: {
        'endpoint': ApiConstants.scanMedicationImage,
        'fileName': fileName,
        'fileSize': '${(fileSize / 1024).toStringAsFixed(2)} KB',
      },
    );

    try {
      // Create FormData for multipart upload
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      developer.log(
        'Sending POST request with multipart/form-data',
        name: _tag,
      );

      // Make POST request with multipart/form-data
      final response = await dio.post(
        ApiConstants.scanMedicationImage,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      stopwatch.stop();

      developer.log(
        'Scan API response received',
        name: _tag,
        error: {
          'statusCode': response.statusCode,
          'duration': '${stopwatch.elapsedMilliseconds}ms',
          'responseData': response.data,
        },
      );

      // Parse response
      final result = MedicationScanResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (result.data?.medication != null) {
        developer.log(
          'Medication identified successfully',
          name: _tag,
          error: {
            'medicationName': result.data!.medication!.name,
            'dosage': result.data!.medication!.dosage,
            'medicationId': result.data!.medication!.medicationId,
          },
        );
      } else {
        developer.log(
          'No medication identified in response',
          name: _tag,
          error: {
            'message': result.data?.message,
            'agentError': result.data?.agentError,
          },
        );
      }

      return result;
    } on DioException catch (e) {
      stopwatch.stop();

      developer.log(
        'Scan API request failed',
        name: _tag,
        level: 1000, // Severe level
        error: {
          'errorType': e.type.toString(),
          'message': e.message,
          'statusCode': e.response?.statusCode,
          'duration': '${stopwatch.elapsedMilliseconds}ms',
          'responseData': e.response?.data,
        },
      );

      // Let BaseApiService error handling take care of this
      rethrow;
    } catch (e, stackTrace) {
      stopwatch.stop();

      developer.log(
        'Unexpected error during scan',
        name: _tag,
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}
