/// Pose Detection Provider - State Management
/// 
/// Riverpod provider for managing pose detection state across workout screens
/// Handles phase transitions and auto screen navigation
/// 
/// Author: MEMOTION Team
/// Version: 1.0.0

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pose_detection_service.dart';
import '../models/pose_detection_model.dart';

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
  final PoseFrameResult? lastResult;
  final PoseSessionResults? finalResults;
  final bool isSessionActive;
  
  // Phase-specific data
  final double detectionProgress;
  final int stableCount;
  final bool poseDetected;
  
  final String? calibrationJoint;
  final double calibrationAngle;
  final double calibrationMaxAngle;
  final double calibrationProgress;
  
  final double syncScore;
  final int repCount;
  final String fatigueLevel;
  
  final double totalScore;
  final String grade;

  const PoseSessionState({
    this.isLoading = false,
    this.isConnected = false,
    this.sessionId,
    this.currentPhase = PosePhase.detection,
    this.error,
    this.lastResult,
    this.finalResults,
    this.isSessionActive = false,
    // Detection
    this.detectionProgress = 0.0,
    this.stableCount = 0,
    this.poseDetected = false,
    // Calibration
    this.calibrationJoint,
    this.calibrationAngle = 0.0,
    this.calibrationMaxAngle = 0.0,
    this.calibrationProgress = 0.0,
    // Sync
    this.syncScore = 0.0,
    this.repCount = 0,
    this.fatigueLevel = 'FRESH',
    // Scoring
    this.totalScore = 0.0,
    this.grade = '',
  });

  PoseSessionState copyWith({
    bool? isLoading,
    bool? isConnected,
    String? sessionId,
    PosePhase? currentPhase,
    String? error,
    PoseFrameResult? lastResult,
    PoseSessionResults? finalResults,
    bool? isSessionActive,
    double? detectionProgress,
    int? stableCount,
    bool? poseDetected,
    String? calibrationJoint,
    double? calibrationAngle,
    double? calibrationMaxAngle,
    double? calibrationProgress,
    double? syncScore,
    int? repCount,
    String? fatigueLevel,
    double? totalScore,
    String? grade,
  }) {
    return PoseSessionState(
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      sessionId: sessionId ?? this.sessionId,
      currentPhase: currentPhase ?? this.currentPhase,
      error: error,
      lastResult: lastResult ?? this.lastResult,
      finalResults: finalResults ?? this.finalResults,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      detectionProgress: detectionProgress ?? this.detectionProgress,
      stableCount: stableCount ?? this.stableCount,
      poseDetected: poseDetected ?? this.poseDetected,
      calibrationJoint: calibrationJoint ?? this.calibrationJoint,
      calibrationAngle: calibrationAngle ?? this.calibrationAngle,
      calibrationMaxAngle: calibrationMaxAngle ?? this.calibrationMaxAngle,
      calibrationProgress: calibrationProgress ?? this.calibrationProgress,
      syncScore: syncScore ?? this.syncScore,
      repCount: repCount ?? this.repCount,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      totalScore: totalScore ?? this.totalScore,
      grade: grade ?? this.grade,
    );
  }
}

/// Notifier for pose session state
class PoseSessionNotifier extends StateNotifier<PoseSessionState> {
  final PoseDetectionService _service;
  StreamSubscription<PoseFrameResult>? _frameSubscription;
  StreamSubscription<PosePhase>? _phaseSubscription;
  StreamSubscription<PoseWebSocketError>? _errorSubscription;
  StreamSubscription<bool>? _connectionSubscription;

  // Callback for phase changes (for screen navigation)
  void Function(PosePhase phase)? onPhaseChange;

  PoseSessionNotifier(this._service) : super(const PoseSessionState());

  /// Start a new pose detection session
  Future<void> startSession({
    String? userId,
    String exerciseType = 'arm_raise',
    String defaultJoint = 'left_shoulder',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _service.startSession(
        userId: userId,
        exerciseType: exerciseType,
        defaultJoint: defaultJoint,
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
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Connect to WebSocket and start listening
  Future<void> connectWebSocket() async {
    try {
      await _service.connectWebSocket();
      _setupListeners();
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
      return results;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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
    final oldPhase = state.currentPhase;
    PosePhase newPhase;
    
    switch (result.phase) {
      case 1: // Detection
        newPhase = PosePhase.detection;
        state = state.copyWith(
          lastResult: result,
          currentPhase: newPhase,
          poseDetected: result.poseDetected,
          stableCount: result.stableCount,
          detectionProgress: result.progress,
        );
        break;
        
      case 2: // Calibration
        newPhase = PosePhase.calibration;
        state = state.copyWith(
          lastResult: result,
          currentPhase: newPhase,
          calibrationJoint: result.currentJointName,
          calibrationAngle: result.currentAngle,
          calibrationMaxAngle: result.maxAngle,
          calibrationProgress: result.calibrationProgress,
        );
        break;
        
      case 3: // Sync
        newPhase = PosePhase.sync;
        state = state.copyWith(
          lastResult: result,
          currentPhase: newPhase,
          syncScore: result.currentScore,
          repCount: result.repCount,
          fatigueLevel: result.fatigueLevel,
        );
        break;
        
      case 4: // Scoring
        newPhase = PosePhase.scoring;
        state = state.copyWith(
          lastResult: result,
          currentPhase: newPhase,
          totalScore: result.totalScore,
          grade: result.grade,
        );
        break;
        
      case 5: // Completed
        newPhase = PosePhase.completed;
        state = state.copyWith(
          lastResult: result,
          currentPhase: newPhase,
        );
        break;
        
      default:
        return;
    }
    
    // Trigger callback when phase changes (also from frame result)
    if (oldPhase != newPhase) {
      PoseLogger.info('Phase change detected from frame: ${oldPhase.displayName} → ${newPhase.displayName}');
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
final poseSessionProvider = StateNotifierProvider<PoseSessionNotifier, PoseSessionState>((ref) {
  final service = ref.watch(poseDetectionServiceProvider);
  return PoseSessionNotifier(service);
});

/// Provider for current phase (for conditional UI rendering)
final currentPosePhaseProvider = Provider<PosePhase>((ref) {
  return ref.watch(poseSessionProvider.select((state) => state.currentPhase));
});

/// Provider for connection status
final poseConnectionStatusProvider = Provider<bool>((ref) {
  return ref.watch(poseSessionProvider.select((state) => state.isConnected));
});

/// Provider for last frame result
final lastFrameResultProvider = Provider<PoseFrameResult?>((ref) {
  return ref.watch(poseSessionProvider.select((state) => state.lastResult));
});
