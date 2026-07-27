import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/pose_overlay_controller.dart';
import '../utils/pose_viewport_geometry.dart';
import 'pose_landmark_overlay.dart';

/// Fits one camera preview and its landmark overlay through the same transform.
///
/// The current mobile encoder rotates its payload upright without mirroring it.
/// CameraX mirrors the front preview, so the overlay is mirrored exactly once.
class PoseCameraViewport extends StatelessWidget {
  const PoseCameraViewport({
    super.key,
    required this.cameraController,
    required this.overlayController,
    this.fit = BoxFit.contain,
    this.backgroundColor = Colors.black,
    this.mirrorFrontCameraLandmarks = true,
  }) : assert(fit == BoxFit.contain || fit == BoxFit.cover);

  final CameraController cameraController;
  final PoseOverlayController overlayController;
  final BoxFit fit;
  final Color backgroundColor;
  final bool mirrorFrontCameraLandmarks;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: ClipRect(
        child: ValueListenableBuilder<CameraValue>(
          valueListenable: cameraController,
          builder: (context, value, _) {
            final previewSize = value.previewSize;
            if (!value.isInitialized || previewSize == null) {
              return const SizedBox.expand();
            }

            final orientation = _applicableOrientation(value);
            final sourceSize = PoseViewportGeometry.orientedPreviewSize(
              previewSize,
              orientation,
            );
            final mirrorLandmarks =
                mirrorFrontCameraLandmarks &&
                cameraController.description.lensDirection ==
                    CameraLensDirection.front;

            return FittedBox(
              fit: fit,
              alignment: Alignment.center,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: sourceSize.width,
                height: sourceSize.height,
                child: CameraPreview(
                  cameraController,
                  child: PoseLandmarkOverlay(
                    controller: overlayController,
                    mirrorHorizontally: mirrorLandmarks,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  DeviceOrientation _applicableOrientation(CameraValue value) {
    if (value.isRecordingVideo && value.recordingOrientation != null) {
      return value.recordingOrientation!;
    }
    return value.previewPauseOrientation ??
        value.lockedCaptureOrientation ??
        value.deviceOrientation;
  }
}
