import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/voice_audio_playing_provider.dart';
import '../screens/voice_command_sheet.dart';
import '../../../shared/widgets/voice_record_button.dart';

/// A global, role-based FloatingActionButton for 'Ask AI'.
/// Automatically handles visibility (Patients only) and
/// disabled state (during audio playback).
class VoiceCommandFAB extends ConsumerWidget {
  const VoiceCommandFAB({
    super.key,
    this.buttonSize = VoiceRecordButtonSize.medium,
    this.customDiameter,
  }) : assert(
         buttonSize != VoiceRecordButtonSize.custom || customDiameter != null,
         'customDiameter must be provided when buttonSize is custom',
       );

  final VoiceRecordButtonSize buttonSize;
  final double? customDiameter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Visibility: Only show for Patients
    final isPatient = ref.watch(authProvider.select((s) => s.isPatient));
    if (!isPatient) {
      return const SizedBox.shrink();
    }

    // Enabled state: Disable during voice audio playback
    final isAudioPlaying = ref.watch(voiceAudioPlayingProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom:
            ResponsiveUtils.navBarHeight(context) +
            (ResponsiveUtils.isTabletOrLarger(context)
                ? 32
                : ResponsiveUtils.sectionGap(context)),
      ),
      child: VoiceRecordButton(
        size: buttonSize,
        customDiameter: customDiameter,
        isEnabled: !isAudioPlaying,
        onPressed: () => _onAskAiPressed(context),
        label: null, // Icon only as requested
      ),
    );
  }

  Future<void> _onAskAiPressed(BuildContext context) async {
    final permissionStatus = await Permission.microphone.request();

    if (permissionStatus.isGranted) {
      if (!context.mounted) return;
      _showVoiceCommandSheet(context);
      return;
    }

    if (!context.mounted) return;

    if (permissionStatus.isPermanentlyDenied || permissionStatus.isRestricted) {
      _showMicrophonePermissionDialog(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please allow microphone access to use Ask AI.'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _showVoiceCommandSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VoiceCommandSheet(),
    );
  }

  void _showMicrophonePermissionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enable microphone access'),
          content: const Text(
            'Allow microphone access in Settings so Ask AI can hear your request.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}
