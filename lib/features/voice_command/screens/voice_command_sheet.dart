import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/voice_command_key.dart';
import '../models/voice_command_response.dart';
import '../providers/voice_command_notifier.dart';
import '../providers/voice_command_provider.dart';
import '../providers/voice_command_state.dart';
import '../utils/voice_command_navigator.dart';
import '../widgets/audio_waveform.dart';

class VoiceCommandSheet extends ConsumerStatefulWidget {
  const VoiceCommandSheet({super.key});

  @override
  ConsumerState<VoiceCommandSheet> createState() => _VoiceCommandSheetState();
}

class _VoiceCommandSheetState extends ConsumerState<VoiceCommandSheet> {
  bool _isHandlingSuccess = false;
  VoiceCommandStatus _lastStatus = VoiceCommandStatus.idle;
  late final VoiceCommandNotifier _voiceCommandNotifier;

  @override
  void initState() {
    super.initState();
    _voiceCommandNotifier = ref.read(voiceCommandProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_voiceCommandNotifier.startRecording());
    });
  }

  @override
  void dispose() {
    // Check if we were in the middle of something using local knowledge
    // before the provider is fully disposed.
    // However, to be safe, we capture the messenger earlier if possible.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<VoiceCommandState>(voiceCommandProvider, (previous, next) {
      _lastStatus = next.status;
      if (next.status == VoiceCommandStatus.success && next.response != null) {
        if (_isHandlingSuccess) {
          return;
        }

        unawaited(_handleSuccess(next.response!));
        return;
      }

      if (next.status != VoiceCommandStatus.success) {
        _isHandlingSuccess = false;
      }
    });

    final state = ref.watch(voiceCommandProvider);
    final notifier = _voiceCommandNotifier;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop &&
            (_lastStatus == VoiceCommandStatus.recording ||
                _lastStatus == VoiceCommandStatus.processing)) {
          final messenger = ScaffoldMessenger.maybeOf(context);
          if (messenger != null) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Đã hủy lệnh thoại'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 124),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: switch (state.status) {
              VoiceCommandStatus.recording => _buildRecordingState(
                state,
                notifier,
              ),
              VoiceCommandStatus.processing => _buildProcessingState(),
              VoiceCommandStatus.success => _buildSuccessState(state),
              VoiceCommandStatus.error => _buildErrorState(state, notifier),
              VoiceCommandStatus.idle => _buildIdleState(notifier),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIdleState(VoiceCommandNotifier notifier) {
    return SizedBox(
      key: const ValueKey('voice_idle'),
      height: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mic, size: 52, color: AppColors.primary),
          const SizedBox(height: 12),
          Text('Sẵn sàng lắng nghe', style: AppTextStyles.headline2),
          const SizedBox(height: 8),
          Text(
            'Nhấn bắt đầu để ghi âm lệnh thoại.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => unawaited(notifier.startRecording()),
            icon: const Icon(Icons.fiber_manual_record),
            label: const Text('Bắt đầu'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingState(
    VoiceCommandState state,
    VoiceCommandNotifier notifier,
  ) {
    return SizedBox(
      key: const ValueKey('voice_recording'),
      height: 340,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 46,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          Text('Đang nghe...', style: AppTextStyles.headline2),
          const SizedBox(height: 6),
          Text(
            'Hãy nói yêu cầu của bạn',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: AudioWaveform(
                  samples: state.waveformData,
                  maxHeight: 90,
                  minHeight: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(64, 64),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => unawaited(notifier.stopAndProcess()),
            child: const Icon(Icons.stop_rounded, size: 34),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingState() {
    return SizedBox(
      key: const ValueKey('voice_processing'),
      height: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 18),
          Text('Đang xử lý...', style: AppTextStyles.headline2),
          const SizedBox(height: 8),
          Text(
            'Đang chuyển giọng nói thành lệnh điều hướng',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(VoiceCommandState state) {
    return SizedBox(
      key: const ValueKey('voice_success'),
      height: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 56,
            color: AppColors.success,
          ),
          const SizedBox(height: 14),
          Text('Đã hiểu lệnh', style: AppTextStyles.headline2),
          const SizedBox(height: 8),
          Text(
            state.response?.transcript ?? '',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    VoiceCommandState state,
    VoiceCommandNotifier notifier,
  ) {
    return SizedBox(
      key: const ValueKey('voice_error'),
      height: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_rounded, size: 52, color: AppColors.error),
          const SizedBox(height: 14),
          Text('Không thể xử lý lệnh', style: AppTextStyles.headline2),
          const SizedBox(height: 8),
          Text(
            state.errorMessage ?? 'Đã xảy ra lỗi không xác định.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => unawaited(notifier.startRecording()),
                  child: const Text('Thử lại'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleSuccess(VoiceCommandResponse response) async {
    _isHandlingSuccess = true;

    unawaited(
      VoiceCommandNavigator.playResponseAudio(response.audio, ref).catchError((
        error,
        stackTrace,
      ) {
        debugPrint('[VoiceCommand] TTS playback failed: $error');
      }),
    );

    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }

    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await VoiceCommandNavigator.navigate(
      router,
      VoiceCommandKey.fromString(response.key),
      ref,
      messenger: messenger,
    );

    if (mounted && navigator.canPop()) {
      navigator.pop();
    }

    await _voiceCommandNotifier.reset();
  }
}
