import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pure camera/overlay viewport calculations shared by widgets and tests.
abstract final class PoseViewportGeometry {
  static Size orientedPreviewSize(
    Size previewSize,
    DeviceOrientation orientation,
  ) {
    final isLandscape =
        orientation == DeviceOrientation.landscapeLeft ||
        orientation == DeviceOrientation.landscapeRight;
    return isLandscape
        ? previewSize
        : Size(previewSize.height, previewSize.width);
  }

  static Rect fittedRect({
    required Size sourceSize,
    required Size viewportSize,
    required BoxFit fit,
  }) {
    if (sourceSize.isEmpty || viewportSize.isEmpty) return Rect.zero;
    final widthScale = viewportSize.width / sourceSize.width;
    final heightScale = viewportSize.height / sourceSize.height;
    final scale = switch (fit) {
      BoxFit.contain => math.min(widthScale, heightScale),
      BoxFit.cover => math.max(widthScale, heightScale),
      _ => throw ArgumentError.value(
        fit,
        'fit',
        'Pose camera viewport supports BoxFit.contain or BoxFit.cover.',
      ),
    };
    final fittedSize = Size(
      sourceSize.width * scale,
      sourceSize.height * scale,
    );
    return Alignment.center.inscribe(fittedSize, Offset.zero & viewportSize);
  }

  static Offset mapNormalizedPoint({
    required Offset normalizedPoint,
    required Rect fittedRect,
    bool mirrorHorizontally = false,
  }) {
    final x = mirrorHorizontally ? 1 - normalizedPoint.dx : normalizedPoint.dx;
    return Offset(
      fittedRect.left + x * fittedRect.width,
      fittedRect.top + normalizedPoint.dy * fittedRect.height,
    );
  }
}
