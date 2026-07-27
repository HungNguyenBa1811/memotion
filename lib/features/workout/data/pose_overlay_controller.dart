import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/pose_landmark_model.dart';
import '../models/pose_overlay_model.dart';

/// Isolates high-frequency landmark updates from widget and Riverpod rebuilds.
final class PoseOverlayController extends ChangeNotifier {
  PoseOverlayController({
    this.showConfidence = 0.65,
    this.hideConfidence = 0.45,
    this.fadeAfter = const Duration(milliseconds: 100),
    this.staleAfter = const Duration(milliseconds: 250),
    bool startFreshnessTimer = true,
  }) : _startFreshnessTimer = startFreshnessTimer {
    assert(showConfidence >= hideConfidence);
    assert(fadeAfter < staleAfter);
  }

  final double showConfidence;
  final double hideConfidence;
  final Duration fadeAfter;
  final Duration staleAfter;
  final bool _startFreshnessTimer;

  final Stopwatch _sessionClock = Stopwatch()..start();
  final List<bool> _visibleJoints = List<bool>.filled(33, false);
  Timer? _freshnessTimer;
  int? _lastResultElapsedUs;
  PoseOverlaySnapshot _snapshot = PoseOverlaySnapshot.empty();

  PoseOverlaySnapshot get snapshot => _snapshot;

  /// Accepts one typed result and prepares all buffers outside the paint call.
  void ingest(
    List<NormalizedPoseLandmark> landmarks, {
    required List<PoseSkeletonEdge> connections,
    int? receivedElapsedUs,
  }) {
    if (landmarks.isEmpty) return;

    final byIndex = List<NormalizedPoseLandmark?>.filled(
      mediaPipePoseLandmarkCount,
      null,
    );
    final highConfidence = <double>[];
    final mediumConfidence = <double>[];

    for (final landmark in landmarks) {
      if (landmark.index < 0 || landmark.index >= mediaPipePoseLandmarkCount) {
        continue;
      }
      if (!landmark.hasFiniteCoordinates) {
        _visibleJoints[landmark.index] = false;
        continue;
      }

      final confidence = landmark.displayConfidence;
      final wasVisible = _visibleJoints[landmark.index];
      final isVisible = wasVisible
          ? confidence >= hideConfidence
          : confidence >= showConfidence;
      _visibleJoints[landmark.index] = isVisible;
      if (!isVisible) continue;

      byIndex[landmark.index] = landmark;
      final target = confidence >= showConfidence
          ? highConfidence
          : mediumConfidence;
      target
        ..add(landmark.x)
        ..add(landmark.y);
    }

    final boneSegments = <double>[];
    for (final edge in connections) {
      final start = byIndex[edge.start];
      final end = byIndex[edge.end];
      if (start == null || end == null) continue;
      boneSegments
        ..add(start.x)
        ..add(start.y)
        ..add(end.x)
        ..add(end.y);
    }

    _lastResultElapsedUs =
        receivedElapsedUs ?? _sessionClock.elapsedMicroseconds;
    _snapshot = PoseOverlaySnapshot(
      highConfidencePoints: Float32List.fromList(highConfidence),
      mediumConfidencePoints: Float32List.fromList(mediumConfidence),
      visibleBoneSegments: Float32List.fromList(boneSegments),
      opacity: 1,
    );
    notifyListeners();
    if (_snapshot.isEmpty) {
      _freshnessTimer?.cancel();
      _freshnessTimer = null;
      return;
    }
    _ensureFreshnessTimer();
  }

  /// Updates stale fade state. The optional value makes freshness deterministic
  /// in unit tests without introducing a fake clock dependency into widgets.
  void refreshStaleness({int? nowElapsedUs}) {
    final lastResultElapsedUs = _lastResultElapsedUs;
    if (lastResultElapsedUs == null || _snapshot.isEmpty) return;

    final ageUs =
        (nowElapsedUs ?? _sessionClock.elapsedMicroseconds) -
        lastResultElapsedUs;
    final fadeAfterUs = fadeAfter.inMicroseconds;
    final staleAfterUs = staleAfter.inMicroseconds;

    if (ageUs >= staleAfterUs) {
      clear();
      return;
    }

    final nextOpacity = ageUs <= fadeAfterUs
        ? 1.0
        : 1 - ((ageUs - fadeAfterUs) / (staleAfterUs - fadeAfterUs));
    if ((_snapshot.opacity - nextOpacity).abs() < 0.01) return;
    _snapshot = _snapshot.withOpacity(nextOpacity.clamp(0.0, 1.0));
    notifyListeners();
  }

  void clear() {
    _freshnessTimer?.cancel();
    _freshnessTimer = null;
    _lastResultElapsedUs = null;
    _visibleJoints.fillRange(0, _visibleJoints.length, false);
    if (_snapshot.isEmpty) return;
    _snapshot = PoseOverlaySnapshot.empty();
    notifyListeners();
  }

  void _ensureFreshnessTimer() {
    if (!_startFreshnessTimer || _freshnessTimer != null) return;
    _freshnessTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => refreshStaleness(),
    );
  }

  @override
  void dispose() {
    _freshnessTimer?.cancel();
    _sessionClock.stop();
    super.dispose();
  }
}
