import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

abstract interface class SosEffects {
  Future<void> playCaregiverAlarm();
  Future<void> stop();
  Future<void> dispose();
}

class DeviceSosEffects implements SosEffects {
  AudioPlayer? _player;
  Timer? _hapticTimer;
  bool _pluginVibrationStarted = false;

  @override
  Future<void> playCaregiverAlarm() async {
    await _playAlarm();
    if (await _startPluginVibration()) return;
    _startHapticFallback();
  }

  Future<bool> _startPluginVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator != true) return false;

      _pluginVibrationStarted = true;
      final hasCustomSupport =
          await Vibration.hasCustomVibrationsSupport() == true;
      if (hasCustomSupport) {
        await Vibration.vibrate(pattern: const [0, 600, 250, 600, 250, 900]);
      } else {
        await Vibration.vibrate(duration: 1200);
      }
      return true;
    } catch (error) {
      _pluginVibrationStarted = false;
      debugPrint('[SOS] Could not start device vibration: $error');
      return false;
    }
  }

  void _startHapticFallback() {
    _hapticTimer?.cancel();
    var vibrationCount = 0;
    unawaited(_vibrate());
    _hapticTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      vibrationCount++;
      if (vibrationCount >= 4) {
        timer.cancel();
        return;
      }
      unawaited(_vibrate());
    });
  }

  Future<void> _playAlarm() async {
    await stop();
    try {
      final player = AudioPlayer();
      _player = player;
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(AssetSource('alarm.mp3'));
    } catch (error) {
      debugPrint('[SOS] Could not play alert audio: $error');
    }
  }

  Future<void> _vibrate() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (error) {
      debugPrint('[SOS] Could not trigger haptic feedback: $error');
    }
  }

  @override
  Future<void> stop() async {
    _hapticTimer?.cancel();
    _hapticTimer = null;
    if (_pluginVibrationStarted) {
      try {
        await Vibration.cancel();
      } catch (error) {
        debugPrint('[SOS] Could not cancel device vibration: $error');
      }
      _pluginVibrationStarted = false;
    }
    final player = _player;
    _player = null;
    if (player == null) return;
    try {
      await player.stop();
      await player.dispose();
    } catch (error) {
      debugPrint('[SOS] Could not stop alert audio: $error');
    }
  }

  @override
  Future<void> dispose() => stop();
}
