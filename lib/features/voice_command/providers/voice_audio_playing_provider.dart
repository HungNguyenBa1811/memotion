import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/theme/app_colors.dart';

/// Provider to track whether a voice response audio is currently playing.
/// Surpasses screen transitions and survives sheet dismissal.
final voiceAudioPlayingProvider = NotifierProvider<VoiceAudioPlayerNotifier, bool>(() {
  return VoiceAudioPlayerNotifier();
});

class VoiceAudioPlayerNotifier extends Notifier<bool> {
  AudioPlayer? _player;
  StreamSubscription<void>? _completeSub;
  StreamSubscription<PlayerState>? _stateSub;
  Timer? _watchdogTimer;
  File? _tempFile;

  @override
  bool build() {
    ref.onDispose(() => _cleanup());
    return false;
  }

  Future<void> playResponse(String? responseAudio) async {
    final payload = responseAudio?.trim();
    if (payload == null || payload.isEmpty) {
      return;
    }

    await _cleanup();

    state = true;
    
    // Failsafe watchdog: Always release buttons after 30 seconds max
    _watchdogTimer = Timer(const Duration(seconds: 30), () {
      debugPrint('[VoiceAudioPlayer] Watchdog triggered. Forcing release.');
      _onPlaybackComplete();
    });

    final player = AudioPlayer();
    _player = player;
    await player.setReleaseMode(ReleaseMode.stop);

    _completeSub = player.onPlayerComplete.listen((_) {
      debugPrint('[VoiceAudioPlayer] Playback completed naturally.');
      _onPlaybackComplete();
    });

    _stateSub = player.onPlayerStateChanged.listen((s) {
      debugPrint('[VoiceAudioPlayer] State changed: $s');
      if (s == PlayerState.completed || s == PlayerState.stopped) {
        _onPlaybackComplete();
      }
    });

    try {
      final remoteUrl = _resolveAudioUrl(payload);
      if (remoteUrl != null) {
        final remoteBytes = await _downloadAudioBytes(remoteUrl);
        final extension = _resolveAudioFileExtension(remoteUrl, remoteBytes);
        final file = await _writeTempAudioFile(remoteBytes, extension);
        await player.play(DeviceFileSource(file.path));
        return;
      }

      final audioBytes = _decodeAudioPayload(payload);
      final extension = _resolveAudioFileExtension(payload, audioBytes);
      final file = await _writeTempAudioFile(audioBytes, extension);
      await player.play(DeviceFileSource(file.path));
    } catch (error) {
      debugPrint('[VoiceAudioPlayer] Playback error: $error');
      _onPlaybackComplete();
    }
  }

  void _onPlaybackComplete() {
    if (state == false) return; // Already released
    
    state = false;
    _cleanup();
  }

  Future<void> _cleanup() async {
    _watchdogTimer?.cancel();
    _watchdogTimer = null;

    await _completeSub?.cancel();
    await _stateSub?.cancel();
    _completeSub = null;
    _stateSub = null;

    final p = _player;
    _player = null;
    if (p != null) {
      await p.stop();
      await p.dispose();
    }

    final f = _tempFile;
    _tempFile = null;
    if (f != null && await f.exists()) {
      try {
        await f.delete();
      } catch (_) {}
    }
  }

  // --- Utility methods moved from Navigator ---

  static Uint8List _decodeAudioPayload(String payload) {
    final encodedBody = payload.contains(',') ? payload.split(',').last : payload;
    final compact = encodedBody.replaceAll(RegExp(r'\s+'), '').replaceAll('"', '');
    if (compact.isEmpty) throw const FormatException('Empty payload.');

    try {
      return base64Decode(compact);
    } on FormatException {
      final normalized = base64Url.normalize(compact);
      return base64Url.decode(normalized);
    }
  }

  static String? _resolveAudioUrl(String payload) {
    final candidate = payload.replaceAll('"', '');
    if (candidate.startsWith('http://') || candidate.startsWith('https://')) return candidate;
    if (candidate.startsWith('/')) return '${ApiConstants.baseUrl}$candidate';
    
    final looksLikePath = RegExp(r'^[A-Za-z0-9._~/%\-?=&]+$').hasMatch(candidate) &&
                          !candidate.contains(';base64,') &&
                          candidate.contains('/');
    return looksLikePath ? '${ApiConstants.baseUrl}/$candidate' : null;
  }

  static String _resolveAudioFileExtension(String payload, Uint8List bytes) {
    final sourcePath = Uri.tryParse(payload)?.path.toLowerCase() ?? payload.toLowerCase();
    if (sourcePath.endsWith('.mp3')) return 'mp3';
    if (sourcePath.endsWith('.wav')) return 'wav';
    if (sourcePath.endsWith('.m4a') || sourcePath.endsWith('.mp4')) return 'm4a';
    
    // Fallback detection (simplified for Notifier)
    if (bytes.length >= 4 && bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) return 'wav';
    return 'mp3';
  }

  Future<Uint8List> _downloadAudioBytes(String remoteUrl) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(remoteUrl));
      final token = await TokenStorage.instance.getAccessToken();
      if (token != null) request.headers.add('Authorization', 'Bearer $token');
      
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) throw HttpException('HTTP ${response.statusCode}');
      
      final bytesBuilder = BytesBuilder(copy: false);
      await for (final chunk in response) {
        bytesBuilder.add(chunk);
      }
      return bytesBuilder.takeBytes();
    } finally {
      client.close(force: true);
    }
  }

  Future<File> _writeTempAudioFile(Uint8List bytes, String extension) async {
    final filePath = '${Directory.systemTemp.path}${Platform.pathSeparator}'
        'voice_tts_${DateTime.now().microsecondsSinceEpoch}.$extension';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    _tempFile = file;
    return file;
  }
}
