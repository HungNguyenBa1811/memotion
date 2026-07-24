import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:record/record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memotion/features/voice_command/providers/voice_command_notifier.dart';
import 'package:memotion/features/voice_command/providers/voice_command_state.dart';
import 'package:memotion/features/voice_command/data/voice_command_repository.dart';
import 'package:memotion/features/voice_command/models/voice_command_response.dart';
import 'package:memotion/features/voice_command/providers/voice_command_provider.dart';

class MockAudioRecorder extends Mock implements AudioRecorder {}

class MockVoiceCommandRepository extends Mock
    implements VoiceCommandRepository {}

class FakeRecordConfig extends Fake implements RecordConfig {}

class FakeAmplitude extends Fake implements Amplitude {}

void main() {
  late MockAudioRecorder mockAudioRecorder;
  late MockVoiceCommandRepository mockRepository;
  late StreamController<Amplitude> amplitudeController;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakeRecordConfig());
    registerFallbackValue(FakeAmplitude());
    registerFallbackValue(const Duration(seconds: 1));
  });

  setUp(() {
    mockAudioRecorder = MockAudioRecorder();
    mockRepository = MockVoiceCommandRepository();
    amplitudeController = StreamController<Amplitude>.broadcast();

    // Default stubs
    when(
      () => mockAudioRecorder.onAmplitudeChanged(any()),
    ).thenAnswer((_) => amplitudeController.stream);
    when(
      () => mockAudioRecorder.stop(),
    ).thenAnswer((_) async => 'path/to/recorded.m4a');
    when(() => mockAudioRecorder.dispose()).thenAnswer((_) async => {});

    container = ProviderContainer(
      overrides: [
        voiceCommandRepositoryProvider.overrideWithValue(mockRepository),
        voiceCommandProvider.overrideWith((ref) {
          return VoiceCommandNotifier(
            ref.read(voiceCommandRepositoryProvider),
            audioRecorder: mockAudioRecorder,
          );
        }),
      ],
    );

    // Keep autoDispose provider alive during tests
    container.listen(voiceCommandProvider, (_, __) {});
  });

  tearDown(() {
    amplitudeController.close();
    container.dispose();
  });

  group('VoiceCommandNotifier', () {
    test('initial state should be idle with default waveform', () {
      final state = container.read(voiceCommandProvider);
      expect(state.status, VoiceCommandStatus.idle);
      expect(state.waveformData.length, 36);
      expect(state.recordedFilePath, isNull);
    });

    group('startRecording', () {
      test('should update status to error if permission is denied', () async {
        // Arrange
        when(
          () => mockAudioRecorder.hasPermission(),
        ).thenAnswer((_) async => false);

        // Act
        await container.read(voiceCommandProvider.notifier).startRecording();

        // Assert
        final state = container.read(voiceCommandProvider);
        expect(state.status, VoiceCommandStatus.error);
        expect(
          state.errorMessage,
          'Microphone access is off. Please allow access and try again.',
        );
        verify(() => mockAudioRecorder.hasPermission()).called(1);
        verifyNever(
          () => mockAudioRecorder.start(any(), path: any(named: 'path')),
        );
      });

      test('should update status to recording on success', () async {
        // Arrange
        when(
          () => mockAudioRecorder.hasPermission(),
        ).thenAnswer((_) async => true);
        when(
          () => mockAudioRecorder.start(
            any<RecordConfig>(),
            path: any<String>(named: 'path'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await container.read(voiceCommandProvider.notifier).startRecording();

        // Assert
        final state = container.read(voiceCommandProvider);
        expect(state.status, VoiceCommandStatus.recording);
        expect(state.recordedFilePath, isNotNull);
        verify(() => mockAudioRecorder.hasPermission()).called(1);
        verify(
          () => mockAudioRecorder.start(
            any<RecordConfig>(),
            path: any<String>(named: 'path'),
          ),
        ).called(1);
      });
    });

    test('amplitude changes should update waveformData', () async {
      // Arrange
      when(
        () => mockAudioRecorder.hasPermission(),
      ).thenAnswer((_) async => true);
      when(
        () => mockAudioRecorder.start(
          any<RecordConfig>(),
          path: any<String>(named: 'path'),
        ),
      ).thenAnswer((_) async => {});

      final notifier = container.read(voiceCommandProvider.notifier);
      await notifier.startRecording();

      final initialState = container.read(voiceCommandProvider);
      final initialWaveform = List<double>.from(initialState.waveformData);

      // Act
      amplitudeController.add(Amplitude(current: -10, max: 0));

      // Allow the listener to process the event
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      final updatedState = container.read(voiceCommandProvider);
      final updatedWaveform = updatedState.waveformData;
      expect(
        updatedWaveform.last,
        closeTo(0.83, 0.01),
      ); // (-10 + 60) / 60 = 0.833
      expect(updatedWaveform.first, initialWaveform[1]); // Ensure it shifted
    });

    group('stopAndProcess', () {
      const tFilePath = 'path/to/recorded.m4a';
      const tResponse = VoiceCommandResponse(
        code: 200,
        message: 'Processed',
        key: 'LIGHT_ON',
      );

      test('should transition to success on successful processing', () async {
        // Arrange
        when(
          () => mockAudioRecorder.hasPermission(),
        ).thenAnswer((_) async => true);
        when(
          () => mockAudioRecorder.start(
            any<RecordConfig>(),
            path: any<String>(named: 'path'),
          ),
        ).thenAnswer((_) async => {});
        when(() => mockAudioRecorder.stop()).thenAnswer((_) async => tFilePath);
        when(
          () => mockRepository.processVoice(any<String>()),
        ).thenAnswer((_) async => tResponse);

        final notifier = container.read(voiceCommandProvider.notifier);
        await notifier.startRecording();

        // Act
        await notifier.stopAndProcess();

        // Assert
        final state = container.read(voiceCommandProvider);
        expect(state.status, VoiceCommandStatus.success);
        expect(state.response, equals(tResponse));
        verify(() => mockAudioRecorder.stop()).called(1);
        verify(() => mockRepository.processVoice(tFilePath)).called(1);
      });

      test('should transition to error if processing fails', () async {
        // Arrange
        when(
          () => mockAudioRecorder.hasPermission(),
        ).thenAnswer((_) async => true);
        when(
          () => mockAudioRecorder.start(
            any<RecordConfig>(),
            path: any<String>(named: 'path'),
          ),
        ).thenAnswer((_) async => {});
        when(() => mockAudioRecorder.stop()).thenAnswer((_) async => tFilePath);
        when(
          () => mockRepository.processVoice(any<String>()),
        ).thenThrow(const VoiceCommandRepositoryException('Failed'));

        final notifier = container.read(voiceCommandProvider.notifier);
        await notifier.startRecording();

        // Act
        await notifier.stopAndProcess();

        // Assert
        final state = container.read(voiceCommandProvider);
        expect(state.status, VoiceCommandStatus.error);
        expect(
          state.errorMessage,
          'We could not complete that request. Please check your connection and try again.',
        );
      });
    });
  });
}
