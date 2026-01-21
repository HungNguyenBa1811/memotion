import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/base_api_service.dart';
import '../../../core/network/api_constants.dart';
import '../models/medication_scan_dto.dart';

/// API Service for medication scanning functionality
class MedicationScanService extends BaseApiService {
  MedicationScanService({super.dio});

  /// Scan medication image and get medication information
  /// POST /api/medication-library/scan-image
  ///
  /// Upload an image file to identify medication details
  /// Returns [MedicationScanResponse] with medication info or error
  Future<MedicationScanResponse> scanMedicationImage(File imageFile) async {
    try {
      // Create FormData for multipart upload
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

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

      // Parse response
      return MedicationScanResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException {
      // Let BaseApiService error handling take care of this
      rethrow;
    }
  }
}
