/// MediaPipe Pose currently returns 33 landmarks in the backend contract.
const mediaPipePoseLandmarkCount = 33;

/// A landmark in the normalized, upright inference-payload coordinate space.
final class NormalizedPoseLandmark {
  const NormalizedPoseLandmark({
    required this.index,
    required this.x,
    required this.y,
    this.z,
    required this.visibility,
    this.presence,
  });

  final int index;
  final double x;
  final double y;
  final double? z;
  final double visibility;
  final double? presence;

  /// Conservative confidence used only by the visual overlay.
  double get displayConfidence {
    final presenceValue = presence;
    if (presenceValue == null) return visibility;
    return presenceValue < visibility ? presenceValue : visibility;
  }

  bool get hasFiniteCoordinates =>
      x.isFinite && y.isFinite && (z == null || z!.isFinite);
}

typedef PoseSkeletonEdge = ({int start, int end});
