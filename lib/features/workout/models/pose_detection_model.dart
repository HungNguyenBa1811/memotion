/// Pose Detection Models for real-time pose analysis
/// 
/// These models match the backend API responses for pose detection

import 'dart:convert';

/// Phases in pose detection flow
enum PosePhase {
  detection(1, 'detection', 'Phát hiện tư thế'),
  calibration(2, 'calibration', 'Hiệu chỉnh khớp'),
  sync(3, 'sync', 'Đồng bộ với video'),
  scoring(4, 'scoring', 'Tính điểm'),
  completed(5, 'completed', 'Hoàn thành');

  const PosePhase(this.value, this.name, this.displayName);
  
  final int value;
  final String name;
  final String displayName;

  static PosePhase fromValue(int value) {
    return PosePhase.values.firstWhere(
      (p) => p.value == value,
      orElse: () => PosePhase.detection,
    );
  }

  static PosePhase fromName(String name) {
    return PosePhase.values.firstWhere(
      (p) => p.name == name,
      orElse: () => PosePhase.detection,
    );
  }
}

/// Session status
enum SessionStatus {
  active,
  paused,
  completed,
  error;

  static SessionStatus fromString(String value) {
    return SessionStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => SessionStatus.active,
    );
  }
}

/// Response from POST /sessions - Start Session
class PoseSessionResponse {
  final String sessionId;
  final SessionStatus status;
  final PosePhase currentPhase;
  final String websocketUrl;
  final String message;

  const PoseSessionResponse({
    required this.sessionId,
    required this.status,
    required this.currentPhase,
    required this.websocketUrl,
    required this.message,
  });

  factory PoseSessionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return PoseSessionResponse(
      sessionId: data['session_id'] as String,
      status: SessionStatus.fromString(data['status'] as String),
      currentPhase: PosePhase.fromName(data['current_phase'] as String),
      websocketUrl: data['websocket_url'] as String,
      message: data['message'] as String,
    );
  }
}

/// Real-time frame result from WebSocket
class PoseFrameResult {
  final int phase;
  final String phaseName;
  final Map<String, dynamic> data;
  final String? message;
  final String? warning;
  final double timestamp;
  final int frameNumber;
  final double fps;

  const PoseFrameResult({
    required this.phase,
    required this.phaseName,
    required this.data,
    this.message,
    this.warning,
    required this.timestamp,
    required this.frameNumber,
    required this.fps,
  });

  PosePhase get posePhase => PosePhase.fromValue(phase);

  factory PoseFrameResult.fromJson(Map<String, dynamic> json) {
    final phaseNum = json['phase'] as int? ?? 1;
    
    // Lấy data từ đúng field dựa trên phase
    // Backend gửi: detection (phase 1), calibration (phase 2), sync (phase 3), final_report (phase 4)
    Map<String, dynamic> phaseData = {};
    switch (phaseNum) {
      case 1:
        phaseData = json['detection'] as Map<String, dynamic>? ?? {};
        break;
      case 2:
        // Backend sends calibration data in 'data' field, not 'calibration'
        phaseData = json['calibration'] as Map<String, dynamic>? ??
                    json['data'] as Map<String, dynamic>? ?? {};
        break;
      case 3:
        phaseData = json['sync'] as Map<String, dynamic>? ?? {};
        break;
      case 4:
        phaseData = json['final_report'] as Map<String, dynamic>? ?? {};
        break;
      default:
        phaseData = json['data'] as Map<String, dynamic>? ?? {};
    }
    
    return PoseFrameResult(
      phase: phaseNum,
      phaseName: json['phase_name'] as String? ?? 'detection',
      data: phaseData,
      message: json['message'] as String?,
      warning: json['warning'] as String?,
      timestamp: (json['timestamp'] as num?)?.toDouble() ?? 0.0,
      frameNumber: json['frame_number'] as int? ?? 0,
      fps: (json['fps'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // ==================== Phase 1: Detection Data ====================
  bool get poseDetected => data['pose_detected'] as bool? ?? false;
  int get stableCount => data['stable_count'] as int? ?? 0;
  double get progress => (data['progress'] as num?)?.toDouble() ?? 0.0;
  List<dynamic> get landmarks => data['landmarks'] as List<dynamic>? ?? [];

  // ==================== Phase 2: Calibration Data ====================
  String? get currentJoint => data['current_joint'] as String?;
  String? get currentJointName => data['current_joint_name'] as String?;
  double get currentAngle => (data['current_angle'] as num?)?.toDouble() ?? 0.0;
  double get maxAngle => (data['user_max_angle'] as num?)?.toDouble() ?? 0.0;
  double get calibrationProgress => (data['progress'] as num?)?.toDouble() ?? 0.0;
  int get queueIndex => data['queue_index'] as int? ?? 0;
  int get totalJoints => data['total_joints'] as int? ?? 6;
  double get overallProgress => (data['overall_progress'] as num?)?.toDouble() ?? 0.0;
  String? get calibrationStatus => data['status'] as String?;
  double? get countdownRemaining => (data['countdown_remaining'] as num?)?.toDouble();
  String? get positionInstruction => data['position_instruction'] as String?;

  // ==================== Phase 3: Sync Data ====================
  String? get videoFrame => data['video_frame'] as String?;
  double get currentScore => (data['current_score'] as num?)?.toDouble() ?? 0.0;
  int get repCount => data['rep_count'] as int? ?? 0;
  String get fatigueLevel => data['fatigue_level'] as String? ?? 'FRESH';

  // ==================== Phase 4: Scoring Data ====================
  double get totalScore => (data['total_score'] as num?)?.toDouble() ?? 0.0;
  double get romScore => (data['rom_score'] as num?)?.toDouble() ?? 0.0;
  double get stabilityScore => (data['stability_score'] as num?)?.toDouble() ?? 0.0;
  double get flowScore => (data['flow_score'] as num?)?.toDouble() ?? 0.0;
  String get grade => data['grade'] as String? ?? '';
}

/// Final session results from DELETE /sessions/{id}
class PoseSessionResults {
  final String sessionId;
  final String exerciseName;
  final int durationSeconds;
  final double totalScore;
  final double romScore;
  final double stabilityScore;
  final double flowScore;
  final String grade;
  final String gradeColor;
  final int totalReps;
  final String fatigueLevel;
  final List<CalibratedJoint> calibratedJoints;
  final List<RepScore> repScores;
  final List<String> recommendations;

  const PoseSessionResults({
    required this.sessionId,
    required this.exerciseName,
    required this.durationSeconds,
    required this.totalScore,
    required this.romScore,
    required this.stabilityScore,
    required this.flowScore,
    required this.grade,
    required this.gradeColor,
    required this.totalReps,
    required this.fatigueLevel,
    required this.calibratedJoints,
    required this.repScores,
    required this.recommendations,
  });

  factory PoseSessionResults.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return PoseSessionResults(
      sessionId: data['session_id'] as String? ?? '',
      exerciseName: data['exercise_name'] as String? ?? '',
      durationSeconds: data['duration_seconds'] as int? ?? 0,
      totalScore: (data['total_score'] as num?)?.toDouble() ?? 0.0,
      romScore: (data['rom_score'] as num?)?.toDouble() ?? 0.0,
      stabilityScore: (data['stability_score'] as num?)?.toDouble() ?? 0.0,
      flowScore: (data['flow_score'] as num?)?.toDouble() ?? 0.0,
      grade: data['grade'] as String? ?? '',
      gradeColor: data['grade_color'] as String? ?? 'yellow',
      totalReps: data['total_reps'] as int? ?? 0,
      fatigueLevel: data['fatigue_level'] as String? ?? 'FRESH',
      calibratedJoints: (data['calibrated_joints'] as List<dynamic>?)
              ?.map((j) => CalibratedJoint.fromJson(j))
              .toList() ??
          [],
      repScores: (data['rep_scores'] as List<dynamic>?)
              ?.map((r) => RepScore.fromJson(r))
              .toList() ??
          [],
      recommendations: (data['recommendations'] as List<dynamic>?)
              ?.map((r) => r as String)
              .toList() ??
          [],
    );
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Calibrated joint data
class CalibratedJoint {
  final String joint;
  final double maxAngle;

  const CalibratedJoint({
    required this.joint,
    required this.maxAngle,
  });

  factory CalibratedJoint.fromJson(Map<String, dynamic> json) {
    return CalibratedJoint(
      joint: json['joint'] as String? ?? '',
      maxAngle: (json['max_angle'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Rep score data
class RepScore {
  final int rep;
  final double score;

  const RepScore({
    required this.rep,
    required this.score,
  });

  factory RepScore.fromJson(Map<String, dynamic> json) {
    return RepScore(
      rep: json['rep'] as int? ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// WebSocket error response
class PoseWebSocketError {
  final String error;
  final String code;

  const PoseWebSocketError({
    required this.error,
    required this.code,
  });

  factory PoseWebSocketError.fromJson(Map<String, dynamic> json) {
    return PoseWebSocketError(
      error: json['error'] as String? ?? 'Unknown error',
      code: json['code'] as String? ?? '500',
    );
  }
}

/// Health check response
class PoseHealthResponse {
  final String status;
  final bool mediapipeAvailable;
  final int activeSessions;
  final String version;

  const PoseHealthResponse({
    required this.status,
    required this.mediapipeAvailable,
    required this.activeSessions,
    required this.version,
  });

  factory PoseHealthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return PoseHealthResponse(
      status: data['status'] as String? ?? 'unknown',
      mediapipeAvailable: data['mediapipe_available'] as bool? ?? false,
      activeSessions: data['active_sessions'] as int? ?? 0,
      version: data['version'] as String? ?? '0.0.0',
    );
  }

  bool get isHealthy => status == 'healthy' && mediapipeAvailable;
}
