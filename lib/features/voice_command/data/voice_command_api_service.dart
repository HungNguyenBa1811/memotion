import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/base_api_service.dart';
import '../models/voice_command_response.dart';

class VoiceCommandApiService extends BaseApiService {
  VoiceCommandApiService({super.dio});

  Future<VoiceCommandResponse> processVoiceCommand(String filePath) async {
    final audioFile = File(filePath);
    if (!audioFile.existsSync()) {
      throw const BadRequestException(message: 'Audio file does not exist.');
    }

    final fileName = audioFile.uri.pathSegments.last;
    final formData = FormData.fromMap({
      'voice_audio': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    try {
      final response = await dio.post(
        ApiConstants.voiceCommandProcess,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      return VoiceCommandResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ApiExceptionHandler.handle(error);
    }
  }
}
