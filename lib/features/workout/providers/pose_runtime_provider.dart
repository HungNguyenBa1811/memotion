import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pose_overlay_controller.dart';

/// Session-scoped visual lane. Camera/transport ownership remains in the
/// existing services until the later runtime-lifecycle phase is implemented.
final poseOverlayControllerProvider = Provider<PoseOverlayController>((ref) {
  final controller = PoseOverlayController();
  ref.onDispose(controller.dispose);
  return controller;
});
