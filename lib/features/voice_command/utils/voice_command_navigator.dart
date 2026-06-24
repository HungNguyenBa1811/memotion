import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../workout/providers/workout_provider.dart';
import '../models/voice_command_key.dart';
import '../providers/voice_audio_playing_provider.dart';

class VoiceCommandNavigator {
  VoiceCommandNavigator._();

  static Future<void> navigate(
    GoRouter router,
    VoiceCommandKey key,
    WidgetRef ref, {
    ScaffoldMessengerState? messenger,
  }) async {
    switch (key) {
      case VoiceCommandKey.home:
        router.go(AppRoutes.home);
        return;
      case VoiceCommandKey.medication:
      case VoiceCommandKey.medicationDetail:
        router.go(AppRoutes.medication);
        return;
      case VoiceCommandKey.physical:
        router.go(AppRoutes.workout);
        return;
      case VoiceCommandKey.nutrition:
        router.go(AppRoutes.nutrition);
        return;
      case VoiceCommandKey.startPhysical:
        await _navigateToFirstWorkout(router, ref, messenger: messenger);
        return;
      case VoiceCommandKey.unknown:
        _showUnknownCommand(messenger);
        return;
    }
  }

  static Future<void> playResponseAudio(
    String? responseAudio,
    WidgetRef ref,
  ) async {
    // Forward to the persistent audio player provider
    await ref
        .read(voiceAudioPlayingProvider.notifier)
        .playResponse(responseAudio);
  }

  // Moved to voice_audio_playing_provider.dart

  static Future<void> _navigateToFirstWorkout(
    GoRouter router,
    WidgetRef ref, {
    ScaffoldMessengerState? messenger,
  }) async {
    final notifier = ref.read(workoutListProvider.notifier);

    var workouts = ref.read(workoutListProvider).workouts;
    if (workouts.isEmpty) {
      await notifier.loadWorkoutsForDate(DateTime.now());
      if (!ref.context.mounted) return;
      workouts = ref.read(workoutListProvider).workouts;
    }

    if (workouts.isEmpty) {
      _showUnknownCommand(messenger, message: 'No workout found to start.');
      return;
    }

    final targetWorkout = workouts.firstWhere(
      (workout) => !workout.isCompleted,
      orElse: () => workouts.first,
    );

    router.push(
      AppRoutes.workoutDetail,
      extra: {'workoutId': targetWorkout.id},
    );
  }

  static void _showUnknownCommand(
    ScaffoldMessengerState? messenger, {
    String message =
        'Could not understand the voice command. Please try again.',
  }) {
    if (messenger == null) {
      return;
    }

    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.warning),
    );
  }
}
