import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.fontSize,
  });

  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveUtils.textScaleFactor(context);
    return SizedBox(
      width: width ?? double.infinity,
      height: 64 * scale,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 24 * scale,
                height: 24 * scale,
                child: const CircularProgressIndicator(
                  color: AppColors.textOnPrimary,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: AppTextStyles.buttonLarge.copyWith(
                  fontSize: (fontSize ?? 16) * scale * 1.15,
                ),
              ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.fontSize,
  });

  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveUtils.textScaleFactor(context);
    return SizedBox(
      width: width ?? double.infinity,
      height: 64 * scale,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.buttonMedium.copyWith(
            fontSize: (fontSize ?? 16) * scale * 1.15,
          ),
        ),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ts = ResponsiveUtils.textScaleFactor(context);
    final textScale = ts * ts;
    return SizedBox(
      width: double.infinity,
      height: 56 * ts,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(text, style: AppTextStyles.bodyMedium.copyWith(fontSize: 14 * textScale * 1.15)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.inputBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6 * ts)),
        ),
      ),
    );
  }
}
