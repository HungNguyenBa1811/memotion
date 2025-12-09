import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headline styles
  static TextStyle get headline1 => GoogleFonts.lexendDeca(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static TextStyle get headline2 => GoogleFonts.lexendDeca(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get headline3 => GoogleFonts.lexendDeca(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body styles
  static TextStyle get bodyLarge => GoogleFonts.lexendDeca(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.lexendDeca(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.lexendDeca(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Button styles
  static TextStyle get buttonLarge => GoogleFonts.lexendDeca(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  static TextStyle get buttonMedium => GoogleFonts.lexendDeca(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  // Caption styles
  static TextStyle get caption => GoogleFonts.lexendDeca(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Input styles
  static TextStyle get inputText => GoogleFonts.lexendDeca(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get inputHint => GoogleFonts.lexendDeca(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.inputHint,
  );

  // Link styles
  static TextStyle get link => GoogleFonts.lexendDeca(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );
}
