import 'package:flutter/material.dart';
import 'package:memotion/core/utils/responsive_utils.dart';

/// Builds different widget trees based on the current screen breakpoint.
///
/// Usage:
/// ```dart
/// ResponsiveLayout(
///   phone: (context) => PhoneLayout(),
///   tablet: (context) => TabletLayout(),       // optional
///   largeTablet: (context) => LargeLayout(),   // optional
/// )
/// ```
/// Falls back: largeTablet → tablet → phone.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.phone,
    this.tablet,
    this.largeTablet,
  });

  final WidgetBuilder phone;
  final WidgetBuilder? tablet;
  final WidgetBuilder? largeTablet;

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isLargeTablet(context)) {
      return (largeTablet ?? tablet ?? phone)(context);
    }
    if (ResponsiveUtils.isTablet(context)) {
      return (tablet ?? phone)(context);
    }
    return phone(context);
  }
}

/// Wraps [child] in a centered [ConstrainedBox] using [ResponsiveUtils.contentMaxWidth].
/// Use for screens that should cap their content width on tablet.
class ResponsiveContentBox extends StatelessWidget {
  const ResponsiveContentBox({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;

  /// Optional outer padding. Defaults to [ResponsiveUtils.horizontalPadding].
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveUtils.horizontalPadding(context);
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: hPad),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.contentMaxWidth(context),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Switches between a [Column] (phone) and [Row] (tablet+) for two-panel layouts.
/// Useful for side-by-side content/illustration patterns.
class ResponsiveTwoPanel extends StatelessWidget {
  const ResponsiveTwoPanel({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryFlex = 1,
    this.secondaryFlex = 1,
    this.spacing = 24,
  });

  final Widget primary;
  final Widget secondary;
  final int primaryFlex;
  final int secondaryFlex;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isTabletOrLarger(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: primaryFlex, child: primary),
          SizedBox(width: spacing),
          Expanded(flex: secondaryFlex, child: secondary),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        primary,
        SizedBox(height: spacing),
        secondary,
      ],
    );
  }
}
