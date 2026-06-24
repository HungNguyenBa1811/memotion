import '../../../core/network/api_exceptions.dart';
import '../models/voice_command_response.dart';
import 'voice_command_api_service.dart';

class VoiceCommandRepository {
  VoiceCommandRepository(this._apiService);

  final VoiceCommandApiService _apiService;

  Future<VoiceCommandResponse> processVoice(String audioPath) async {
    try {
      return await _apiService.processVoiceCommand(audioPath);
    } on ApiException catch (error) {
      throw VoiceCommandRepositoryException(error.message);
    } catch (error) {
      throw VoiceCommandRepositoryException(
        'Failed to process voice command: $error',
      );
    }
  }
}

class VoiceCommandRepositoryException implements Exception {
  const VoiceCommandRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
