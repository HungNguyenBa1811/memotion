import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive_utils.dart';

enum VoiceRecordButtonSize { small, medium, large, custom }

enum VoiceRecordButtonType { primary, secondary }

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
  final VoiceRecordButtonType type;

  /// Only used when [size] == [VoiceRecordButtonSize.custom].
  final double? customDiameter;

  final Color? color;
  final Color? iconColor;

  /// Pass [null] to hide the label.
  final String? label;

  final bool isEnabled;

  const VoiceRecordButton({
    super.key,
    this.onPressed,
    this.size = VoiceRecordButtonSize.medium,
    this.type = VoiceRecordButtonType.primary,
    this.customDiameter,
    this.color,
    this.iconColor,
    this.label = 'Voice Record',
    this.isEnabled = true,
  });

  const VoiceRecordButton.small({
    super.key,
    this.onPressed,
    this.type = VoiceRecordButtonType.primary,
    this.color,
    this.iconColor,
    this.label = 'Record',
    this.isEnabled = true,
  }) : size = VoiceRecordButtonSize.small,
       customDiameter = null;

  const VoiceRecordButton.large({
    super.key,
    this.onPressed,
    this.type = VoiceRecordButtonType.primary,
    this.color,
    this.iconColor,
    this.label = 'Record',
    this.isEnabled = true,
  }) : size = VoiceRecordButtonSize.large,
       customDiameter = null;

  double _getDiameter(BuildContext context) {
    final isLarge = ResponsiveUtils.isLargeTablet(context);
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final scale = isLarge
        ? 1.8
        : isTablet
        ? 1.6
        : 1.0;

    switch (size) {
      case VoiceRecordButtonSize.small:
        return 56 * scale;
      case VoiceRecordButtonSize.medium:
        return 80 * scale;
      case VoiceRecordButtonSize.large:
        return 110 * scale;
      case VoiceRecordButtonSize.custom:
        assert(
          customDiameter != null,
          'customDiameter must be provided when size is custom',
        );
        return customDiameter ?? 80; // Caller handles responsive sizing
    }
  }

  @override
  Widget build(BuildContext context) {
    final diameter = _getDiameter(context);
    final defaultColor = type == VoiceRecordButtonType.secondary
        ? AppColors.primary
        : Colors.red;
    final bg = isEnabled ? (color ?? defaultColor) : Colors.grey.shade400;
    final fg = iconColor ?? Colors.white;
    final textScale = ResponsiveUtils.textScaleFactor(context);

    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.6,
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
              child: Icon(Icons.mic, color: fg, size: diameter * 0.42),
            ),
            if (label != null) ...[
              SizedBox(height: diameter * 0.08),
              Text(
                label!,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: (diameter * 0.14) * textScale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
