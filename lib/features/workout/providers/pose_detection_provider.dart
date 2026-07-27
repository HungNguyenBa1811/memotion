/// Pose Detection Provider - State Management
///
/// Riverpod provider for managing pose detection state across workout screens
/// Handles phase transitions and auto screen navigation
///
/// Author: MEMOTION Team
/// Version: 1.0.0

library;

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pose_detection_service.dart';
import '../data/pose_overlay_controller.dart';
import '../models/pose_detection_model.dart';
import 'pose_runtime_provider.dart';

/// Provider for PoseDetectionService singleton
final poseDetectionServiceProvider = Provider<PoseDetectionService>((ref) {
  return PoseDetectionService.instance;
});

/// State class for pose session
class PoseSessionState {
  final bool isLoading;
  final bool isConnected;
  final String? sessionId;
  final PosePhase currentPhase;
  final String? error;
  final PoseSessionResults? finalResults;
  final bool isSessionActive;
  final String? message;
  final double? countdownRemaining;

  // Phase-specific data
  final double detectionProgress;
  final int stableCount;
  final bool poseDetected;

  final String? calibrationJoint;
  final double calibrationAngle;
  final double calibrationMaxAngle;
  final double calibrationProgress;
  final int calibrationQueueIndex;
  final int calibrationTotalJoints;

  final double syncScore;
  final int repCount;
  final String fatigueLevel;

  final double totalScore;
  final double romScore;
  final double stabilityScore;
  final double flowScore;
  final String grade;
  final String gradeColor;
  final List<String> recommendations;

  const PoseSessionState({
    this.isLoading = false,
    this.isConnected = false,
    this.sessionId,
    this.currentPhase = PosePhase.detection,
    this.error,
    this.finalResults,
    this.isSessionActive = false,
    this.message,
    this.countdownRemaining,
    // Detection
    this.detectionProgress = 0.0,
    this.stableCount = 0,
    this.poseDetected = false,
    // Calibration
    this.calibrationJoint,
    this.calibrationAngle = 0.0,
    this.calibrationMaxAngle = 0.0,
    this.calibrationProgress = 0.0,
    this.calibrationQueueIndex = 0,
    this.calibrationTotalJoints = 6,
    // Sync
    this.syncScore = 0.0,
    this.repCount = 0,
    this.fatigueLevel = 'FRESH',
    // Scoring
    this.totalScore = 0.0,
    this.romScore = 0.0,
    this.stabilityScore = 0.0,
    this.flowScore = 0.0,
    this.grade = '',
    this.gradeColor = 'yellow',
    this.recommendations = const [],
  });

  PoseSessionState copyWith({
    bool? isLoading,
    bool? isConnected,
    String? sessionId,
    PosePhase? currentPhase,
    String? error,
    PoseSessionResults? finalResults,
    bool? isSessionActive,
    String? message,
    double? countdownRemaining,
    double? detectionProgress,
    int? stableCount,
    bool? poseDetected,
    String? calibrationJoint,
    double? calibrationAngle,
    double? calibrationMaxAngle,
    double? calibrationProgress,
    int? calibrationQueueIndex,
    int? calibrationTotalJoints,
    double? syncScore,
    int? repCount,
    String? fatigueLevel,
    double? totalScore,
    double? romScore,
    double? stabilityScore,
    double? flowScore,
    String? grade,
    String? gradeColor,
    List<String>? recommendations,
  }) {
    return PoseSessionState(
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      sessionId: sessionId ?? this.sessionId,
      currentPhase: currentPhase ?? this.currentPhase,
      error: error,
      finalResults: finalResults ?? this.finalResults,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      message: message ?? this.message,
      countdownRemaining: countdownRemaining ?? this.countdownRemaining,
      detectionProgress: detectionProgress ?? this.detectionProgress,
      stableCount: stableCount ?? this.stableCount,
      poseDetected: poseDetected ?? this.poseDetected,
      calibrationJoint: calibrationJoint ?? this.calibrationJoint,
      calibrationAngle: calibrationAngle ?? this.calibrationAngle,
      calibrationMaxAngle: calibrationMaxAngle ?? this.calibrationMaxAngle,
      calibrationProgress: calibrationProgress ?? this.calibrationProgress,
      calibrationQueueIndex:
          calibrationQueueIndex ?? this.calibrationQueueIndex,
      calibrationTotalJoints:
          calibrationTotalJoints ?? this.calibrationTotalJoints,
      syncScore: syncScore ?? this.syncScore,
      repCount: repCount ?? this.repCount,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      totalScore: totalScore ?? this.totalScore,
      romScore: romScore ?? this.romScore,
      stabilityScore: stabilityScore ?? this.stabilityScore,
      flowScore: flowScore ?? this.flowScore,
      grade: grade ?? this.grade,
      gradeColor: gradeColor ?? this.gradeColor,
      recommendations: recommendations ?? this.recommendations,
    );
  }
}

/// Notifier for pose session state
class PoseSessionNotifier extends StateNotifier<PoseSessionState> {
  final PoseDetectionService _service;
  final PoseOverlayController _overlayController;
  StreamSubscription<PoseFrameResult>? _frameSubscription;
  StreamSubscription<PosePhase>? _phaseSubscription;
  StreamSubscription<PoseWebSocketError>? _errorSubscription;
  StreamSubscription<bool>? _connectionSubscription;

  // Callback for phase changes (for screen navigation)
  void Function(PosePhase phase)? onPhaseChange;

  PoseSessionNotifier(this._service, this._overlayController)
    : super(const PoseSessionState());

  /// Start a new pose detection session
  Future<void> startSession({
    String? userId,
    String exerciseType = 'arm_raise',
    String defaultJoint = 'left_shoulder',
    String? refVideoPath,
  }) async {
    _overlayController.clear();
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _service.startSession(
        userId: userId,
        exerciseType: exerciseType,
        defaultJoint: defaultJoint,
        refVideoPath: refVideoPath,
      );

      state = state.copyWith(
        isLoading: false,
        sessionId: response.sessionId,
        currentPhase: response.currentPhase,
        isSessionActive: true,
      );

      // Connect WebSocket
      await connectWebSocket();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Connect to WebSocket and start listening
  Future<void> connectWebSocket() async {
    try {
      _setupListeners();
      await _service.connectWebSocket();

      // Sync state directly — broadcast stream delivers async (microtask),
      // so state.isConnected would still be false if we only rely on the stream.
      state = state.copyWith(isConnected: _service.isConnected);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Send camera frame for processing
  void sendFrame(Uint8List frameBytes, {int? timestampMs}) {
    _service.sendFrame(frameBytes, timestampMs: timestampMs);
  }

  /// End session and get final results
  Future<PoseSessionResults?> endSession() async {
    state = state.copyWith(isLoading: true);

    try {
      final results = await _service.endSession();

      state = state.copyWith(
        isLoading: false,
        isSessionActive: false,
        isConnected: false,
        finalResults: results,
        totalScore: results.totalScore,
        grade: results.grade,
      );

      _cancelSubscriptions();
      _overlayController.clear();
      return results;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Setup stream listeners
  void _setupListeners() {
    // Frame results
    _frameSubscription = _service.frameResults.listen((result) {
      _updateStateFromResult(result);
    });

    // Phase changes
    _phaseSubscription = _service.phaseChanges.listen((phase) {
      state = state.copyWith(currentPhase: phase);
      onPhaseChange?.call(phase);
    });

    // Errors
    _errorSubscription = _service.errors.listen((error) {
      state = state.copyWith(error: error.error);
    });

    // Connection state
    _connectionSubscription = _service.connectionState.listen((connected) {
      state = state.copyWith(isConnected: connected);
    });
  }

  /// Update state from frame result based on current phase
  void _updateStateFromResult(PoseFrameResult result) {
    if (result.hasPosePayload && !result.isPoseDetected) {
      _overlayController.clear();
    } else if (result.landmarks.isNotEmpty) {
      _overlayController.ingest(
        result.landmarks,
        connections: result.poseConnections,
      );
    }

    final oldPhase = state.currentPhase;
    PosePhase newPhase;

    switch (result.phase) {
      case 1: // Detection
        newPhase = PosePhase.detection;
        state = state.copyWith(
          currentPhase: newPhase,
          message: result.message,
          poseDetected: result.poseDetected,
          stableCount: result.stableCount,
          detectionProgress: result.progress,
        );
        break;

      case 2: // Calibration
        newPhase = PosePhase.calibration;
        state = state.copyWith(
          currentPhase: newPhase,
          message: result.message,
          countdownRemaining: result.countdownRemaining,
          calibrationJoint: result.currentJointName,
          calibrationAngle: result.currentAngle,
          calibrationMaxAngle: result.maxAngle,
          calibrationProgress: result.calibrationProgress,
          calibrationQueueIndex: result.queueIndex,
          calibrationTotalJoints: result.totalJoints,
        );
        break;

      case 3: // Sync
        newPhase = PosePhase.sync;
        // The backend's phase-3 completion frame currently resets rep_count to
        // zero and does not forward its `status` field. Repetitions are
        // monotonic, so a regression identifies a transition/default payload.
        final didRepCountRegress = result.repCount < state.repCount;
        state = state.copyWith(
          currentPhase: newPhase,
          message: result.message,
          syncScore: didRepCountRegress ? state.syncScore : result.currentScore,
          repCount: didRepCountRegress ? state.repCount : result.repCount,
          fatigueLevel: didRepCountRegress
              ? state.fatigueLevel
              : result.fatigueLevel,
        );
        break;

      case 4: // Scoring
        newPhase = PosePhase.scoring;
        state = state.copyWith(
          currentPhase: newPhase,
          message: result.message,
          totalScore: result.totalScore,
          romScore: result.romScore,
          stabilityScore: result.stabilityScore,
          flowScore: result.flowScore,
          grade: result.grade,
          gradeColor: result.gradeColor,
          repCount: result.totalReps,
          recommendations: result.recommendations,
        );
        break;

      case 5: // Completed
        newPhase = PosePhase.completed;
        state = state.copyWith(currentPhase: newPhase, message: result.message);
        break;

      default:
        return;
    }

    // Trigger callback when phase changes (also from frame result)
    if (oldPhase != newPhase) {
      PoseLogger.info(
        'Phase change detected from frame: ${oldPhase.displayName} → ${newPhase.displayName}',
      );
      onPhaseChange?.call(newPhase);
    }
  }

  void _cancelSubscriptions() {
    _frameSubscription?.cancel();
    _phaseSubscription?.cancel();
    _errorSubscription?.cancel();
    _connectionSubscription?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}

/// Provider for pose session state
final poseSessionProvider =
    StateNotifierProvider<PoseSessionNotifier, PoseSessionState>((ref) {
      final service = ref.watch(poseDetectionServiceProvider);
      final overlayController = ref.watch(poseOverlayControllerProvider);
      return PoseSessionNotifier(service, overlayController);
    });

/// Provider for current phase (for conditional UI rendering)
final currentPosePhaseProvider = Provider<PosePhase>((ref) {
  return ref.watch(poseSessionProvider.select((state) => state.currentPhase));
});

/// Provider for connection status
final poseConnectionStatusProvider = Provider<bool>((ref) {
  return ref.watch(poseSessionProvider.select((state) => state.isConnected));
});
