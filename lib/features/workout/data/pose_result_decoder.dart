import '../models/pose_detection_model.dart';
import '../models/pose_landmark_model.dart';

/// Converts the backend WebSocket frame response into typed hot-path data.
final class PoseResultDecoder {
  const PoseResultDecoder();

  PoseFrameResult decode(Map<String, dynamic> json) {
    final phase = _readInt(json['phase'], fallback: 1);
    final phaseData = _phaseData(json, phase);
    final pose = _asStringMap(json['pose']);
    final hasPosePayload = pose != null;
    final landmarks = _decodeLandmarks(
      hasPosePayload ? pose['landmarks'] : phaseData['landmarks'],
    );
    final isPoseDetected = hasPosePayload
        ? _readBool(pose['detected'], fallback: landmarks.isNotEmpty)
        : landmarks.isNotEmpty;
    final landmarkCount = hasPosePayload
        ? _readInt(pose['landmark_count'], fallback: landmarks.length)
        : landmarks.length;
    final connections = hasPosePayload
        ? _decodeConnections(pose['connections'])
        : const <PoseSkeletonEdge>[];
    final coordinateSystem = hasPosePayload
        ? (pose['coordinate_system'] as String? ?? 'normalized')
        : 'normalized';
    final poseTimestampMs = hasPosePayload ? _readInt(pose['timestamp_ms']) : 0;
    final frameTimestampMs = _readInt(json['frame_timestamp_ms']);

    _validatePosePayload(
      hasPosePayload: hasPosePayload,
      isPoseDetected: isPoseDetected,
      landmarkCount: landmarkCount,
      landmarks: landmarks,
      coordinateSystem: coordinateSystem,
      poseTimestampMs: poseTimestampMs,
      frameTimestampMs: frameTimestampMs,
    );

    return PoseFrameResult(
      phase: phase,
      phaseName:
          json['phase_name'] as String? ?? PosePhase.fromValue(phase).name,
      data: phaseData,
      hasPosePayload: hasPosePayload,
      isPoseDetected: isPoseDetected,
      landmarkCount: landmarkCount,
      landmarks: landmarks,
      poseConnections: connections,
      coordinateSystem: coordinateSystem,
      frameWidth: hasPosePayload ? _readInt(pose['frame_width']) : 0,
      frameHeight: hasPosePayload ? _readInt(pose['frame_height']) : 0,
      poseTimestampMs: poseTimestampMs,
      frameTimestampMs: frameTimestampMs,
      poseError: hasPosePayload ? pose['error'] as String? : null,
      message: json['message'] as String? ?? phaseData['message'] as String?,
      warning: json['warning'] as String?,
      timestamp: _readDouble(json['timestamp']),
      frameNumber: _readInt(json['frame_number']),
      fps: _readDouble(json['fps']),
    );
  }

  Map<String, dynamic> _phaseData(Map<String, dynamic> json, int phase) {
    final data = _asStringMap(json['data']);
    if (data != null) return data;

    final phaseKey = switch (phase) {
      1 => 'detection',
      2 => 'calibration',
      3 => 'sync',
      4 => 'final_report',
      _ => null,
    };

    if (phaseKey != null) {
      final wrapped = _asStringMap(json[phaseKey]);
      if (wrapped != null) return wrapped;
    }
    return const <String, dynamic>{};
  }

  List<NormalizedPoseLandmark> _decodeLandmarks(Object? value) {
    if (value == null) return const [];
    if (value is! List) {
      throw const FormatException('Pose landmarks must be a list.');
    }
    if (value.isEmpty) return const [];

    final landmarks = <NormalizedPoseLandmark>[];
    final seenIndices = <int>{};
    for (var position = 0; position < value.length; position++) {
      final item = _asStringMap(value[position]);
      if (item == null) {
        throw FormatException('Pose landmark $position must be an object.');
      }

      final index = _readInt(item['index'], fallback: position);
      final x = _requiredFiniteDouble(item['x'], 'landmark[$position].x');
      final y = _requiredFiniteDouble(item['y'], 'landmark[$position].y');
      final z = _optionalFiniteDouble(item['z'], 'landmark[$position].z');
      final visibility =
          _optionalFiniteDouble(
            item['visibility'],
            'landmark[$position].visibility',
          ) ??
          0;
      final presence = _optionalFiniteDouble(
        item['presence'],
        'landmark[$position].presence',
      );

      if (index < 0 || index >= mediaPipePoseLandmarkCount) {
        throw FormatException('Pose landmark index $index is out of range.');
      }
      if (!seenIndices.add(index)) {
        throw FormatException('Duplicate pose landmark index $index.');
      }

      landmarks.add(
        NormalizedPoseLandmark(
          index: index,
          x: x,
          y: y,
          z: z,
          visibility: visibility.clamp(0.0, 1.0),
          presence: presence?.clamp(0.0, 1.0),
        ),
      );
    }
    return List.unmodifiable(landmarks);
  }

  List<PoseSkeletonEdge> _decodeConnections(Object? value) {
    if (value == null) return const [];
    if (value is! List) {
      throw const FormatException('Pose connections must be a list.');
    }

    final connections = <PoseSkeletonEdge>[];
    for (var index = 0; index < value.length; index++) {
      final connection = value[index];
      if (connection is! List || connection.length != 2) {
        throw FormatException(
          'Pose connection $index must contain two landmark indices.',
        );
      }

      final start = _readInt(connection[0], fallback: -1);
      final end = _readInt(connection[1], fallback: -1);
      if (start < 0 ||
          start >= mediaPipePoseLandmarkCount ||
          end < 0 ||
          end >= mediaPipePoseLandmarkCount) {
        throw FormatException('Pose connection $index is out of range.');
      }
      connections.add((start: start, end: end));
    }
    return List.unmodifiable(connections);
  }

  void _validatePosePayload({
    required bool hasPosePayload,
    required bool isPoseDetected,
    required int landmarkCount,
    required List<NormalizedPoseLandmark> landmarks,
    required String coordinateSystem,
    required int poseTimestampMs,
    required int frameTimestampMs,
  }) {
    if (landmarkCount != landmarks.length) {
      throw FormatException(
        'Pose landmark_count is $landmarkCount but ${landmarks.length} landmarks were received.',
      );
    }
    if (isPoseDetected && landmarkCount != mediaPipePoseLandmarkCount) {
      throw FormatException(
        'A detected pose must contain $mediaPipePoseLandmarkCount landmarks, got $landmarkCount.',
      );
    }
    if (!isPoseDetected && landmarkCount != 0) {
      throw const FormatException(
        'An undetected pose must not contain landmarks.',
      );
    }
    if (hasPosePayload && coordinateSystem != 'normalized') {
      throw FormatException(
        'Unsupported pose coordinate system: $coordinateSystem.',
      );
    }
    if (poseTimestampMs != 0 &&
        frameTimestampMs != 0 &&
        poseTimestampMs != frameTimestampMs) {
      throw FormatException(
        'Pose timestamp $poseTimestampMs does not match frame timestamp $frameTimestampMs.',
      );
    }
  }

  Map<String, dynamic>? _asStringMap(Object? value) {
    if (value is! Map) return null;
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  int _readInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  bool _readBool(Object? value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    return fallback;
  }

  double _readDouble(Object? value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  double _requiredFiniteDouble(Object? value, String field) {
    final parsed = _optionalFiniteDouble(value, field);
    if (parsed == null) throw FormatException('$field is required.');
    return parsed;
  }

  double? _optionalFiniteDouble(Object? value, String field) {
    if (value == null) return null;
    final parsed = value is num
        ? value.toDouble()
        : value is String
        ? double.tryParse(value)
        : null;
    if (parsed == null || !parsed.isFinite) {
      throw FormatException('$field must be a finite number.');
    }
    return parsed;
  }
}
