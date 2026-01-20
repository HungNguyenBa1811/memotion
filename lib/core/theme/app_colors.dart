import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF00695C);
  static const Color primaryLight = Color(0xFF439889);
  // Secondary color from design (#4DB6AC)
  static const Color secondary = Color(0xFF4DB6AC);
  // Accent teal used across UI
  static const Color tealAccent = Color(0xFF00BFA5);
  static const Color primaryDark = Color(0xFF003D33);

  // Figma design tokens - Homepage colors
  static const Color accent = Color(0xFF5F33E1); // Color/Primary from Figma
  static const Color lightGreen = Color(0xFFF1F8E9); // Background
  static const Color cardBackground = Color(0xFFFFFFFF); // Surface/Cards
  static const Color primaryBlack = Color(0xFF000000); // Primary black/typography
  static const Color tealGreen = Color(0xFF4DB6AC); // Green-ish accent
  static const Color lightGreenAccent = Color(0xFFA0FFD5); // Green/200
  static const Color sosButton = Color(0xFFD77658); // SOS CTA background

  // Background colors
  static const Color background = Color(0xFFF1F8E9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFAFAF5);

  // Text colors
  static const Color textPrimary = Color(0xFF221F1F);
  static const Color textSecondary = Color(0x99221F1F); // 60% opacity
  static const Color textOnPrimary = Color(0xFFFAFAF5);

  // Input colors
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputHint = Color(0xFF9E9E9E);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);

  // Other colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  static const Color cardShadow = Color(0x40000000); // rgba(0,0,0,0.25)
}
