import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:memotion/features/voice_command/data/voice_command_api_service.dart';
import 'package:memotion/features/voice_command/data/voice_command_repository.dart';
import 'package:memotion/features/voice_command/models/voice_command_response.dart';
import 'package:memotion/core/network/api_exceptions.dart';

class MockVoiceCommandApiService extends Mock implements VoiceCommandApiService {}

void main() {
  late VoiceCommandRepository repository;
  late MockVoiceCommandApiService mockApiService;

  setUp(() {
    mockApiService = MockVoiceCommandApiService();
    repository = VoiceCommandRepository(mockApiService);
  });

  group('VoiceCommandRepository', () {
    const tAudioPath = 'path/to/audio.m4a';
    const tResponse = VoiceCommandResponse(
      code: 200,
      message: 'Success',
      key: 'HOME',
      transcript: 'go home',
    );

    test('should return VoiceCommandResponse when API call is successful', () async {
      // Arrange
      when(() => mockApiService.processVoiceCommand(any()))
          .thenAnswer((_) async => tResponse);

      // Act
      final result = await repository.processVoice(tAudioPath);

      // Assert
      expect(result, equals(tResponse));
      verify(() => mockApiService.processVoiceCommand(tAudioPath)).called(1);
    });

    test('should throw VoiceCommandRepositoryException when API call fails with ApiException', () async {
      // Arrange
      const errorMessage = 'Network error';
      when(() => mockApiService.processVoiceCommand(any()))
          .thenThrow(const UnknownApiException(message: errorMessage));

      // Act & Assert
      expect(
        () => repository.processVoice(tAudioPath),
        throwsA(isA<VoiceCommandRepositoryException>().having(
          (e) => e.message,
          'message',
          errorMessage,
        )),
      );
    });

    test('should throw VoiceCommandRepositoryException when an unknown error occurs', () async {
      // Arrange
      when(() => mockApiService.processVoiceCommand(any()))
          .thenThrow(Exception('Unknown error'));

      // Act & Assert
      expect(
        () => repository.processVoice(tAudioPath),
        throwsA(isA<VoiceCommandRepositoryException>().having(
          (e) => e.message,
          'message',
          contains('Failed to process voice command'),
        )),
      );
    });
  });
}
