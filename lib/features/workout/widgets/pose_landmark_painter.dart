import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/pose_overlay_controller.dart';
import '../models/pose_overlay_model.dart';

/// Paint-only renderer. Parsing and confidence decisions happen upstream.
final class PoseLandmarkPainter extends CustomPainter {
  PoseLandmarkPainter({
    required this.controller,
    this.style = const PoseOverlayStyle(),
    this.mirrorHorizontally = false,
  }) : _bonePaint = Paint()
         ..style = PaintingStyle.stroke
         ..strokeCap = StrokeCap.round
         ..strokeJoin = StrokeJoin.round
         ..strokeWidth = style.boneWidthPx,
       _highConfidencePaint = Paint()
         ..style = PaintingStyle.stroke
         ..strokeCap = StrokeCap.round
         ..strokeWidth = style.highConfidenceDiameterPx,
       _mediumConfidencePaint = Paint()
         ..style = PaintingStyle.stroke
         ..strokeCap = StrokeCap.round
         ..strokeWidth = style.mediumConfidenceDiameterPx,
       super(repaint: controller);

  final PoseOverlayController controller;
  final PoseOverlayStyle style;
  final bool mirrorHorizontally;
  final Paint _bonePaint;
  final Paint _highConfidencePaint;
  final Paint _mediumConfidencePaint;

  Float32List _bonePixels = Float32List(0);
  Float32List _highConfidencePixels = Float32List(0);
  Float32List _mediumConfidencePixels = Float32List(0);

  @override
  void paint(Canvas canvas, Size size) {
    final snapshot = controller.snapshot;
    if (snapshot.isEmpty || snapshot.opacity <= 0 || size.isEmpty) return;

    _bonePixels = _project(snapshot.visibleBoneSegments, _bonePixels, size);
    _highConfidencePixels = _project(
      snapshot.highConfidencePoints,
      _highConfidencePixels,
      size,
    );
    _mediumConfidencePixels = _project(
      snapshot.mediumConfidencePoints,
      _mediumConfidencePixels,
      size,
    );

    _bonePaint.color = style.boneColor.withValues(
      alpha: style.boneColor.a * snapshot.opacity,
    );
    _highConfidencePaint.color = style.highConfidenceColor.withValues(
      alpha: style.highConfidenceColor.a * snapshot.opacity,
    );
    _mediumConfidencePaint.color = style.mediumConfidenceColor.withValues(
      alpha: style.mediumConfidenceColor.a * snapshot.opacity,
    );

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (_bonePixels.isNotEmpty) {
      canvas.drawRawPoints(ui.PointMode.lines, _bonePixels, _bonePaint);
    }
    if (_mediumConfidencePixels.isNotEmpty) {
      canvas.drawRawPoints(
        ui.PointMode.points,
        _mediumConfidencePixels,
        _mediumConfidencePaint,
      );
    }
    if (_highConfidencePixels.isNotEmpty) {
      canvas.drawRawPoints(
        ui.PointMode.points,
        _highConfidencePixels,
        _highConfidencePaint,
      );
    }
    canvas.restore();
  }

  Float32List _project(
    Float32List normalized,
    Float32List existing,
    Size size,
  ) {
    final output = existing.length == normalized.length
        ? existing
        : Float32List(normalized.length);
    for (var index = 0; index < normalized.length; index += 2) {
      final normalizedX = normalized[index];
      output[index] =
          (mirrorHorizontally ? 1 - normalizedX : normalizedX) * size.width;
      output[index + 1] = normalized[index + 1] * size.height;
    }
    return output;
  }

  @override
  bool shouldRepaint(covariant PoseLandmarkPainter oldDelegate) =>
      oldDelegate.controller != controller ||
      oldDelegate.style != style ||
      oldDelegate.mirrorHorizontally != mirrorHorizontally;
}
