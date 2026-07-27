import 'package:flutter_test/flutter_test.dart';
import 'package:memotion/features/workout/data/pose_overlay_controller.dart';
import 'package:memotion/features/workout/models/pose_landmark_model.dart';

void main() {
  group('PoseOverlayController', () {
    test('prepares visible points and only connects visible endpoints', () {
      final controller = PoseOverlayController(startFreshnessTimer: false);
      addTearDown(controller.dispose);

      controller.ingest(
        [
          _landmark(11, visibility: 0.9),
          _landmark(13, visibility: 0.9),
          _landmark(15, visibility: 0.2),
        ],
        connections: const [(start: 11, end: 13), (start: 13, end: 15)],
      );

      expect(controller.snapshot.highConfidencePoints, hasLength(4));
      expect(controller.snapshot.mediumConfidencePoints, isEmpty);
      expect(controller.snapshot.visibleBoneSegments, hasLength(4));
    });

    test('uses confidence hysteresis to prevent joint flicker', () {
      final controller = PoseOverlayController(startFreshnessTimer: false);
      addTearDown(controller.dispose);

      controller.ingest([
        _landmark(11, visibility: 0.7),
      ], connections: const []);
      expect(controller.snapshot.highConfidencePoints, hasLength(2));

      controller.ingest([
        _landmark(11, visibility: 0.5),
      ], connections: const []);
      expect(controller.snapshot.mediumConfidencePoints, hasLength(2));

      controller.ingest([
        _landmark(11, visibility: 0.4),
      ], connections: const []);
      expect(controller.snapshot.isEmpty, isTrue);
    });

    test('fades after 100 ms and clears at 250 ms', () {
      final controller = PoseOverlayController(startFreshnessTimer: false);
      addTearDown(controller.dispose);

      controller.ingest(
        [_landmark(11, visibility: 0.9)],
        connections: const [],
        receivedElapsedUs: 0,
      );
      controller.refreshStaleness(nowElapsedUs: 175000);
      expect(controller.snapshot.opacity, closeTo(0.5, 0.001));

      controller.refreshStaleness(nowElapsedUs: 250000);
      expect(controller.snapshot.isEmpty, isTrue);
      expect(controller.snapshot.opacity, 0);
    });
  });
}

NormalizedPoseLandmark _landmark(int index, {required double visibility}) {
  return NormalizedPoseLandmark(
    index: index,
    x: 0.2 + index / 100,
    y: 0.3 + index / 100,
    visibility: visibility,
  );
}
