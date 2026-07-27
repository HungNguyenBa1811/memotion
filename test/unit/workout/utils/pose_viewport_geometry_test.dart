import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memotion/features/workout/utils/pose_viewport_geometry.dart';

void main() {
  group('PoseViewportGeometry', () {
    test('orients the camera source like CameraPreview', () {
      const previewSize = Size(640, 480);

      expect(
        PoseViewportGeometry.orientedPreviewSize(
          previewSize,
          DeviceOrientation.portraitUp,
        ),
        const Size(480, 640),
      );
      expect(
        PoseViewportGeometry.orientedPreviewSize(
          previewSize,
          DeviceOrientation.landscapeLeft,
        ),
        previewSize,
      );
    });

    test('contain preserves aspect ratio and centers letterboxing', () {
      final rect = PoseViewportGeometry.fittedRect(
        sourceSize: const Size(640, 480),
        viewportSize: const Size(400, 600),
        fit: BoxFit.contain,
      );

      expect(rect, const Rect.fromLTWH(0, 150, 400, 300));
    });

    test('cover preserves aspect ratio and centers cropping', () {
      final rect = PoseViewportGeometry.fittedRect(
        sourceSize: const Size(640, 480),
        viewportSize: const Size(400, 600),
        fit: BoxFit.cover,
      );

      expect(rect, const Rect.fromLTWH(-200, 0, 800, 600));
    });

    test('maps keypoints through the same fitted rect and mirror', () {
      const fittedRect = Rect.fromLTWH(0, 150, 400, 300);

      expect(
        PoseViewportGeometry.mapNormalizedPoint(
          normalizedPoint: const Offset(0.25, 0.5),
          fittedRect: fittedRect,
        ),
        const Offset(100, 300),
      );
      expect(
        PoseViewportGeometry.mapNormalizedPoint(
          normalizedPoint: const Offset(0.25, 0.5),
          fittedRect: fittedRect,
          mirrorHorizontally: true,
        ),
        const Offset(300, 300),
      );
    });
  });
}
