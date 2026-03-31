import '../models/voice_command_response.dart';

enum VoiceCommandStatus { idle, recording, processing, success, error }

class VoiceCommandState {
  const VoiceCommandState({
    this.status = VoiceCommandStatus.idle,
    this.response,
    this.errorMessage,
    this.waveformData = const [],
    this.recordedFilePath,
  });

  final VoiceCommandStatus status;
  final VoiceCommandResponse? response;
  final String? errorMessage;
  final List<double> waveformData;
  final String? recordedFilePath;

  VoiceCommandState copyWith({
    VoiceCommandStatus? status,
    VoiceCommandResponse? response,
    String? errorMessage,
    List<double>? waveformData,
    String? recordedFilePath,
    bool clearResponse = false,
    bool clearErrorMessage = false,
    bool clearRecordedFilePath = false,
  }) {
    return VoiceCommandState(
      status: status ?? this.status,
      response: clearResponse ? null : (response ?? this.response),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      waveformData: waveformData ?? this.waveformData,
      recordedFilePath: clearRecordedFilePath
          ? null
          : (recordedFilePath ?? this.recordedFilePath),
    );
  }
}
