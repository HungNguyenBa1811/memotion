import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headline styles
  static TextStyle get headline1 => GoogleFonts.lexend(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static TextStyle get headline2 => GoogleFonts.lexend(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get headline3 => GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body styles
  static TextStyle get bodyLarge => GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.lexend(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.lexend(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Button styles
  static TextStyle get buttonLarge => GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  static TextStyle get buttonMedium => GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  // Caption styles
  static TextStyle get caption => GoogleFonts.lexend(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Input styles
  static TextStyle get inputText => GoogleFonts.lexend(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get inputHint => GoogleFonts.lexend(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.inputHint,
  );

  // Link styles
  static TextStyle get link => GoogleFonts.lexend(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  // Figma design tokens - Homepage text styles
  // style_MAQJSS: Lexend, 18pt, weight 700, center — card titles
  static TextStyle get cardTitle => GoogleFonts.lexend(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryBlack,
  );

  // style_ZVHPF7: Lexend, 20pt, weight 700 — section heading
  static TextStyle get sectionHeading => GoogleFonts.lexend(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryBlack,
  );

  // style_LVCGSZ: Lexend, 17pt, weight 700 — numeric stat
  static TextStyle get numericStat => GoogleFonts.lexend(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryBlack,
  );

  // style_2PE3HI: Lexend, 24pt, weight 700 — large stat
  static TextStyle get largeStat => GoogleFonts.lexend(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryBlack,
  );

  // style_A0AN4H: Lexend, 12pt, weight 300 — body/description
  static TextStyle get lightDescription => GoogleFonts.lexend(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
  );
}
