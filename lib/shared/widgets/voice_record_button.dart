import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum VoiceRecordButtonSize { small, medium, large, custom }

/// Reusable circular voice-record button.
///
/// Usage:
/// ```dart
/// // Preset sizes
/// VoiceRecordButton(onPressed: _record)
/// VoiceRecordButton.small(onPressed: _record)
/// VoiceRecordButton.large(onPressed: _record)
///
/// // Custom size
/// VoiceRecordButton(size: VoiceRecordButtonSize.custom, customDiameter: 80, onPressed: _record)
/// ```
class VoiceRecordButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoiceRecordButtonSize size;

  /// Only used when [size] == [VoiceRecordButtonSize.custom].
  final double? customDiameter;

  final Color? color;
  final Color? iconColor;

  /// Pass [null] to hide the label.
  final String? label;

  const VoiceRecordButton({
    super.key,
    this.onPressed,
    this.size = VoiceRecordButtonSize.medium,
    this.customDiameter,
    this.color,
    this.iconColor,
    this.label = 'Voice Record',
  });

  const VoiceRecordButton.small({
    super.key,
    this.onPressed,
    this.color,
    this.iconColor,
    this.label = 'Ghi âm',
  })  : size = VoiceRecordButtonSize.small,
        customDiameter = null;

  const VoiceRecordButton.large({
    super.key,
    this.onPressed,
    this.color,
    this.iconColor,
    this.label = 'Ghi âm',
  })  : size = VoiceRecordButtonSize.large,
        customDiameter = null;

  double get _diameter {
    switch (size) {
      case VoiceRecordButtonSize.small:
        return 56;
      case VoiceRecordButtonSize.medium:
        return 80;
      case VoiceRecordButtonSize.large:
        return 110;
      case VoiceRecordButtonSize.custom:
        assert(customDiameter != null,
            'customDiameter must be provided when size is custom');
        return customDiameter ?? 80;
    }
  }

  @override
  Widget build(BuildContext context) {
    final diameter = _diameter;
    final bg = color ?? AppColors.primary;
    final fg = iconColor ?? Colors.white;

    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bg.withOpacity(0.35),
                  offset: const Offset(0, 6),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Icon(
              Icons.mic,
              color: fg,
              size: diameter * 0.42,
            ),
          ),
          if (label != null) ...[
            SizedBox(height: diameter * 0.08),
            Text(
              label!,
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: diameter * 0.14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
