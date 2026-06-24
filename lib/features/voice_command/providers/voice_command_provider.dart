import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/voice_command_api_service.dart';
import '../data/voice_command_repository.dart';
import 'voice_command_notifier.dart';
import 'voice_command_state.dart';

final voiceCommandApiServiceProvider = Provider.autoDispose<VoiceCommandApiService>((ref) {
  return VoiceCommandApiService();
});

final voiceCommandRepositoryProvider = Provider.autoDispose<VoiceCommandRepository>((ref) {
  return VoiceCommandRepository(ref.watch(voiceCommandApiServiceProvider));
});

final voiceCommandProvider =
    StateNotifierProvider.autoDispose<VoiceCommandNotifier, VoiceCommandState>((ref) {
      return VoiceCommandNotifier(ref.read(voiceCommandRepositoryProvider));
    });
