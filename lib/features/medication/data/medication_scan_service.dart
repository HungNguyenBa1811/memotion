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

    print('🚀✨ OMG WE ARE SCANNING A PILL!!! 💊💊💊');
    print('📸 File name: $fileName');
    print('📦 File size: ${(fileSize / 1024).toStringAsFixed(2)} KB uwu~');
    print('🎯 Endpoint: ${ApiConstants.scanMedicationImage}');

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

      print('📤 Sending request... pls work pls work 🙏🙏🙏');

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

      print('🎉🎉🎉 YAAAS WE GOT A RESPONSE!!! 🎉🎉🎉');
      print('⏱️ Took ${stopwatch.elapsedMilliseconds}ms (slay queen 💅)');
      print('📊 Status code: ${response.statusCode}');
      print('📝 Response data: ${response.data}');

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
        print('💊✨ OMG WE FOUND THE PILL!!! ITS GIVING MEDICINE 💅💅💅');
        print('🏷️ Name: ${result.data!.medication!.name}');
        print('💉 Dosage: ${result.data!.medication!.dosage}');
        print('🆔 ID: ${result.data!.medication!.medicationId}');
        print('📸 Image: ${result.data!.medication!.imagePath}');
        print('🔥🔥🔥 NO CAP THIS IS BUSSIN FR FR 🔥🔥🔥');

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
        print('😭😭😭 BRUH... NO MEDICATION FOUND 💀💀💀');
        print('📝 Message: ${result.data?.message}');
        print('❌ Agent error: ${result.data?.agentError}');
        print('😔 its giving... nothing (sad hours)');

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

      print('💀💀💀 SHEESH DIO ERROR!!! NOT THE API FAILING 😭😭😭');
      print('🚨 Error type: ${e.type}');
      print('📝 Message: ${e.message}');
      print('🔢 Status: ${e.response?.statusCode}');
      print('⏱️ Failed after ${stopwatch.elapsedMilliseconds}ms (oof)');
      print('📦 Response: ${e.response?.data}');
      print('💔 this is NOT giving what it was supposed to give bestie 💔');

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

      print('☠️☠️☠️ BRO WHAT EVEN IS THIS ERROR 😵‍💫😵‍💫😵‍💫');
      print('🤯 Error: $e');
      print('📜 Stack trace be like: $stackTrace');
      print('💀 im literally dead rn this is so not slay 💀');

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
