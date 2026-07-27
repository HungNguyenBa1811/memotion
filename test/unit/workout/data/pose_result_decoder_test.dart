import 'package:flutter_test/flutter_test.dart';
import 'package:memotion/features/workout/data/pose_result_decoder.dart';

void main() {
  const decoder = PoseResultDecoder();

  group('PoseResultDecoder', () {
    test('decodes the backend pose payload and frame metadata', () {
      final result = decoder.decode({
        'phase': 1,
        'phase_name': 'detection',
        'data': {'pose_detected': true, 'progress': 0.8},
        'detection': {'pose_detected': false, 'progress': 0.1},
        'pose': _pose(),
        'message': 'Hold still',
        'frame_number': 42,
        'frame_timestamp_ms': 1722057000123,
        'fps': 14.5,
      });

      expect(result.poseDetected, isTrue);
      expect(result.progress, 0.8);
      expect(result.hasPosePayload, isTrue);
      expect(result.isPoseDetected, isTrue);
      expect(result.landmarkCount, 33);
      expect(result.landmarks, hasLength(33));
      expect(result.landmarks.first.index, 0);
      expect(result.landmarks.first.presence, 0.85);
      expect(result.poseConnections, hasLength(16));
      expect(result.poseConnections.first, (start: 11, end: 13));
      expect(result.coordinateSystem, 'normalized');
      expect(result.frameWidth, 480);
      expect(result.frameHeight, 640);
      expect(result.poseTimestampMs, 1722057000123);
      expect(result.frameTimestampMs, 1722057000123);
      expect(result.frameNumber, 42);
      expect(result.fps, 14.5);
    });

    test('supports the old phase wrapper when data and pose are absent', () {
      final result = decoder.decode({
        'phase': '3',
        'phase_name': 'sync',
        'frame_number': '42',
        'fps': '14.5',
        'sync': {
          'current_score': 86,
          'rep_count': 4,
          'fatigue_level': 'MILD',
          'landmarks': _landmarks(),
        },
      });

      expect(result.phase, 3);
      expect(result.currentScore, 86);
      expect(result.repCount, 4);
      expect(result.hasPosePayload, isFalse);
      expect(result.isPoseDetected, isTrue);
      expect(result.landmarks, hasLength(33));
      expect(result.poseConnections, isEmpty);
    });

    test('accepts the backend no-pose shape without stale landmarks', () {
      final result = decoder.decode({
        'phase': 2,
        'data': {'current_angle': 90.0},
        'pose': _pose(detected: false),
        'frame_timestamp_ms': 1722057000123,
      });

      expect(result.currentAngle, 90);
      expect(result.hasPosePayload, isTrue);
      expect(result.isPoseDetected, isFalse);
      expect(result.landmarkCount, 0);
      expect(result.landmarks, isEmpty);
      expect(result.poseConnections, hasLength(16));
    });

    test('rejects inconsistent detected state and landmark counts', () {
      final malformedCount = _pose();
      malformedCount['landmark_count'] = 32;

      expect(
        () => decoder.decode({
          'phase': 1,
          'pose': malformedCount,
          'frame_timestamp_ms': 1722057000123,
        }),
        throwsA(isA<FormatException>()),
      );

      final undetectedWithLandmarks = _pose();
      undetectedWithLandmarks['detected'] = false;
      expect(
        () => decoder.decode({
          'phase': 1,
          'pose': undetectedWithLandmarks,
          'frame_timestamp_ms': 1722057000123,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects invalid coordinates, connections, and timestamps', () {
      final invalidCoordinates = _pose();
      (invalidCoordinates['landmarks'] as List)[5]['x'] = double.nan;
      expect(
        () => decoder.decode({
          'phase': 1,
          'pose': invalidCoordinates,
          'frame_timestamp_ms': 1722057000123,
        }),
        throwsA(isA<FormatException>()),
      );

      final invalidConnection = _pose();
      invalidConnection['connections'] = [
        [11, 99],
      ];
      expect(
        () => decoder.decode({
          'phase': 1,
          'pose': invalidConnection,
          'frame_timestamp_ms': 1722057000123,
        }),
        throwsA(isA<FormatException>()),
      );

      expect(
        () => decoder.decode({
          'phase': 1,
          'pose': _pose(),
          'frame_timestamp_ms': 1722057000999,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('keeps off-frame normalized coordinates for paint-time clipping', () {
      final pose = _pose();
      (pose['landmarks'] as List).first['x'] = -0.2;
      (pose['landmarks'] as List).last['y'] = 1.3;

      final result = decoder.decode({
        'phase': 1,
        'pose': pose,
        'frame_timestamp_ms': 1722057000123,
      });

      expect(result.landmarks.first.x, -0.2);
      expect(result.landmarks.last.y, 1.3);
    });
  });
}

Map<String, dynamic> _pose({bool detected = true}) {
  final landmarks = detected ? _landmarks() : <Map<String, dynamic>>[];
  return <String, dynamic>{
    'detected': detected,
    'landmark_count': landmarks.length,
    'landmarks': landmarks,
    'connections': _connections(),
    'coordinate_system': 'normalized',
    'frame_width': 480,
    'frame_height': 640,
    'timestamp_ms': 1722057000123,
    'error': null,
  };
}

List<Map<String, dynamic>> _landmarks() {
  return List.generate(33, (index) {
    return <String, dynamic>{
      'index': index,
      'x': index / 32,
      'y': 1 - (index / 64),
      'z': 0.0,
      'visibility': 0.9,
      'presence': 0.85,
    };
  });
}

List<List<int>> _connections() => const [
  [11, 13],
  [13, 15],
  [12, 14],
  [14, 16],
  [11, 12],
  [11, 23],
  [12, 24],
  [23, 24],
  [23, 25],
  [25, 27],
  [27, 29],
  [29, 31],
  [24, 26],
  [26, 28],
  [28, 30],
  [30, 32],
];
