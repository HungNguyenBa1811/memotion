import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Immutable visual configuration for the live pose overlay.
final class PoseOverlayStyle {
  const PoseOverlayStyle({
    this.highConfidenceColor = const Color(0xFF65E572),
    this.mediumConfidenceColor = const Color(0xFFFFC857),
    this.boneColor = const Color(0xCC65E572),
    this.highConfidenceDiameterPx = 9,
    this.mediumConfidenceDiameterPx = 7,
    this.boneWidthPx = 3,
  });

  final Color highConfidenceColor;
  final Color mediumConfidenceColor;
  final Color boneColor;
  final double highConfidenceDiameterPx;
  final double mediumConfidenceDiameterPx;
  final double boneWidthPx;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PoseOverlayStyle &&
          other.highConfidenceColor == highConfidenceColor &&
          other.mediumConfidenceColor == mediumConfidenceColor &&
          other.boneColor == boneColor &&
          other.highConfidenceDiameterPx == highConfidenceDiameterPx &&
          other.mediumConfidenceDiameterPx == mediumConfidenceDiameterPx &&
          other.boneWidthPx == boneWidthPx;

  @override
  int get hashCode => Object.hash(
    highConfidenceColor,
    mediumConfidenceColor,
    boneColor,
    highConfidenceDiameterPx,
    mediumConfidenceDiameterPx,
    boneWidthPx,
  );
}

/// Painter-ready normalized coordinate buffers.
final class PoseOverlaySnapshot {
  PoseOverlaySnapshot({
    required this.highConfidencePoints,
    required this.mediumConfidencePoints,
    required this.visibleBoneSegments,
    required this.opacity,
  });

  factory PoseOverlaySnapshot.empty() => PoseOverlaySnapshot(
    highConfidencePoints: Float32List(0),
    mediumConfidencePoints: Float32List(0),
    visibleBoneSegments: Float32List(0),
    opacity: 0,
  );

  final Float32List highConfidencePoints;
  final Float32List mediumConfidencePoints;
  final Float32List visibleBoneSegments;
  final double opacity;

  bool get isEmpty =>
      highConfidencePoints.isEmpty && mediumConfidencePoints.isEmpty;

  PoseOverlaySnapshot withOpacity(double value) => PoseOverlaySnapshot(
    highConfidencePoints: highConfidencePoints,
    mediumConfidencePoints: mediumConfidencePoints,
    visibleBoneSegments: visibleBoneSegments,
    opacity: value,
  );
}
