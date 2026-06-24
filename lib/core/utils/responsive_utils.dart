import 'package:flutter/material.dart';

/// Breakpoints follow Material Design guidelines:
///   phone:       width < 600
///   tablet:      600 ≤ width < 900
///   largeTablet: width ≥ 900
abstract final class ResponsiveUtils {
  static const double _tabletBreakpoint = 600;
  static const double _largeTabletBreakpoint = 900;

  // ─── Breakpoint queries ───────────────────────────────────────────────────

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isPhone(BuildContext context) =>
      screenWidth(context) < _tabletBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = screenWidth(context);
    return w >= _tabletBreakpoint && w < _largeTabletBreakpoint;
  }

  static bool isLargeTablet(BuildContext context) =>
      screenWidth(context) >= _largeTabletBreakpoint;

  static bool isTabletOrLarger(BuildContext context) =>
      screenWidth(context) >= _tabletBreakpoint;

  // ─── Spacing ──────────────────────────────────────────────────────────────

  /// Horizontal edge padding: 16 / 32 / 48
  static double horizontalPadding(BuildContext context) {
    if (isLargeTablet(context)) return 48;
    if (isTablet(context)) return 32;
    return 16;
  }

  /// Vertical edge padding: 16 / 24 / 32
  static double verticalPadding(BuildContext context) {
    if (isLargeTablet(context)) return 32;
    if (isTablet(context)) return 24;
    return 16;
  }

  /// Standard card/section gap: 12 / 16 / 20
  static double sectionGap(BuildContext context) {
    if (isLargeTablet(context)) return 20;
    if (isTablet(context)) return 16;
    return 12;
  }

  // ─── Content sizing ───────────────────────────────────────────────────────

  /// Max width for centered content (forms, cards, profile)
  /// Unconstrained on phone; 680 on tablet; 900 on large tablet
  static double contentMaxWidth(BuildContext context) {
    if (isLargeTablet(context)) return 900;
    if (isTablet(context)) return 680;
    return double.infinity;
  }

  /// Narrower max width for forms (auth, alarm)
  static double formMaxWidth(BuildContext context) {
    if (isLargeTablet(context)) return 780;
    if (isTablet(context)) return 680;
    return double.infinity;
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  /// Height of the BottomPillNav bar: 86 / 172 / 200
  static double navBarHeight(BuildContext context) {
    if (isLargeTablet(context)) return 200;
    if (isTablet(context)) return 172;
    return 86;
  }

  /// Bottom padding to clear the floating BottomNavigationBar.
  /// On tablet the nav becomes a NavigationRail, so bottom padding is 0.
  static double bottomNavPadding(BuildContext context) =>
      isPhone(context) ? 120 : 24;

  // ─── Grid / list ─────────────────────────────────────────────────────────

  /// Column count for action-card grids: 2 / 3 / 4
  static int cardColumns(BuildContext context) {
    if (isLargeTablet(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  /// Column count for content lists (medication, workout, nutrition): 1 / 2 / 2
  static int listColumns(BuildContext context) =>
      isTabletOrLarger(context) ? 2 : 1;

  // ─── Layout mode ──────────────────────────────────────────────────────────

  /// True when tablet+ in landscape → use two-column detail layouts.
  static bool useTwoColumn(BuildContext context) =>
      isTabletOrLarger(context) &&
      MediaQuery.orientationOf(context) == Orientation.landscape;

  // ─── Component sizes ─────────────────────────────────────────────────────

  /// Avatar / profile image diameter: 90 / 110 / 130
  static double avatarSize(BuildContext context) {
    if (isLargeTablet(context)) return 130;
    if (isTablet(context)) return 110;
    return 90;
  }

  /// Medication alarm image size: 160 / 200 / 240
  static double medicationImageSize(BuildContext context) {
    if (isLargeTablet(context)) return 240;
    if (isTablet(context)) return 200;
    return 160;
  }

  /// Hero image height for detail screens: 207 / 260 / 320
  static double heroImageHeight(BuildContext context) {
    if (isLargeTablet(context)) return 320;
    if (isTablet(context)) return 260;
    return 207;
  }

  /// Action button height: 44 / 52 / 52
  static double buttonHeight(BuildContext context) =>
      isTabletOrLarger(context) ? 52 : 44;

  /// Number of days shown in date selector carousel: 5 / 7 / 7
  static int dateSelectorDays(BuildContext context) =>
      isTabletOrLarger(context) ? 7 : 5;

  // ─── Typography scale ─────────────────────────────────────────────────────

  /// Scale factor for headline text: 1.0 / 1.45 / 1.65
  static double textScaleFactor(BuildContext context) {
    if (isLargeTablet(context)) return 1.65;
    if (isTablet(context)) return 1.45;
    return 1.0;
  }
}
