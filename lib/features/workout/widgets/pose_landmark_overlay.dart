import 'package:flutter/material.dart';

import '../data/pose_overlay_controller.dart';
import '../models/pose_overlay_model.dart';
import 'pose_landmark_painter.dart';

class PoseLandmarkOverlay extends StatelessWidget {
  const PoseLandmarkOverlay({
    super.key,
    required this.controller,
    this.style = const PoseOverlayStyle(),
    this.mirrorHorizontally = false,
  });

  final PoseOverlayController controller;
  final PoseOverlayStyle style;
  final bool mirrorHorizontally;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: PoseLandmarkPainter(
            controller: controller,
            style: style,
            mirrorHorizontally: mirrorHorizontally,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
