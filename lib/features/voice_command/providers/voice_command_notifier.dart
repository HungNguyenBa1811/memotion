import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';

import '../data/voice_command_repository.dart';
import 'voice_command_state.dart';

class VoiceCommandNotifier extends StateNotifier<VoiceCommandState> {
  VoiceCommandNotifier(this._repository, {AudioRecorder? audioRecorder})
    : _audioRecorder = audioRecorder ?? AudioRecorder(),
      super(
        VoiceCommandState(
          waveformData: List<double>.filled(_waveformSampleSize, 0.08),
        ),
      );

  static const int _waveformSampleSize = 36;

  final VoiceCommandRepository _repository;
  final AudioRecorder _audioRecorder;

  StreamSubscription<Amplitude>? _amplitudeSubscription;

  Future<void> startRecording() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!mounted) {
        return;
      }

      if (!hasPermission) {
        state = state.copyWith(
          status: VoiceCommandStatus.error,
          errorMessage:
              'Microphone access is off. Please allow access and try again.',
          clearResponse: true,
          clearRecordedFilePath: true,
          waveformData: _buildInitialWaveform(),
        );
        return;
      }

      await _amplitudeSubscription?.cancel();

      final outputPath = _createTempRecordingPath();
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: outputPath,
      );

      if (!mounted) {
        return;
      }

      _amplitudeSubscription = _audioRecorder
          .onAmplitudeChanged(const Duration(milliseconds: 80))
          .asBroadcastStream()
          .listen(_onAmplitudeChanged);

      state = state.copyWith(
        status: VoiceCommandStatus.recording,
        clearResponse: true,
        clearErrorMessage: true,
        waveformData: _buildInitialWaveform(),
        recordedFilePath: outputPath,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      state = state.copyWith(
        status: VoiceCommandStatus.error,
        errorMessage:
            'We could not start listening. Please check microphone access and try again.',
        clearResponse: true,
        clearRecordedFilePath: true,
      );
    }
  }

  Future<String?> stopRecording() async {
    if (state.status != VoiceCommandStatus.recording) {
      return state.recordedFilePath;
    }

    try {
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;

      final filePath = await _audioRecorder.stop();
      if (!mounted) {
        return null;
      }

      if (filePath == null || filePath.isEmpty) {
        state = state.copyWith(
          status: VoiceCommandStatus.error,
          errorMessage: 'We did not hear a request. Please try again.',
          clearRecordedFilePath: true,
          waveformData: _buildInitialWaveform(),
        );
        return null;
      }

      state = state.copyWith(
        waveformData: _buildInitialWaveform(),
        recordedFilePath: filePath,
      );
      return filePath;
    } catch (error) {
      if (!mounted) {
        return null;
      }

      state = state.copyWith(
        status: VoiceCommandStatus.error,
        errorMessage: 'We could not finish the recording. Please try again.',
        clearRecordedFilePath: true,
      );
      return null;
    }
  }

  Future<void> stopAndProcess() async {
    final filePath = await stopRecording();
    if (filePath == null || filePath.isEmpty) {
      return;
    }

    await processCommand(filePath);
  }

  Future<void> processCommand(String filePath) async {
    state = state.copyWith(
      status: VoiceCommandStatus.processing,
      clearErrorMessage: true,
    );

    try {
      final response = await _repository.processVoice(filePath);
      if (!mounted) {
        return;
      }

      state = state.copyWith(
        status: VoiceCommandStatus.success,
        response: response,
        clearErrorMessage: true,
        clearRecordedFilePath: true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      state = state.copyWith(
        status: VoiceCommandStatus.error,
        errorMessage:
            'We could not complete that request. Please check your connection and try again.',
        clearRecordedFilePath: true,
      );
    } finally {
      await _cleanupFile(filePath);
    }
  }

  Future<void> reset() async {
    try {
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;

      if (state.status == VoiceCommandStatus.recording) {
        await _audioRecorder.stop();
      }
    } catch (_) {
      // Ignore reset cleanup errors.
    }

    state = VoiceCommandState(waveformData: _buildInitialWaveform());
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;

    if (state.status == VoiceCommandStatus.recording) {
      unawaited(_audioRecorder.stop());
    }
    unawaited(_audioRecorder.dispose());

    super.dispose();
  }

  void _onAmplitudeChanged(Amplitude amplitude) {
    if (!mounted || state.status != VoiceCommandStatus.recording) {
      return;
    }

    final normalizedAmplitude = _normalizeAmplitude(amplitude.current);
    final updatedWaveform = List<double>.from(state.waveformData);

    if (updatedWaveform.length >= _waveformSampleSize) {
      updatedWaveform.removeAt(0);
    }
    updatedWaveform.add(normalizedAmplitude);

    state = state.copyWith(waveformData: updatedWaveform);
  }

  List<double> _buildInitialWaveform() {
    return List<double>.filled(_waveformSampleSize, 0.08);
  }

  String _createTempRecordingPath() {
    final fileName = 'voice_cmd_${DateTime.now().millisecondsSinceEpoch}.m4a';
    return '${Directory.systemTemp.path}${Platform.pathSeparator}$fileName';
  }

  double _normalizeAmplitude(double amplitude) {
    final normalized = ((amplitude + 60) / 60).clamp(0.0, 1.0);
    return normalized.toDouble();
  }

  Future<void> _cleanupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore temp file cleanup errors.
    }
  }
}
