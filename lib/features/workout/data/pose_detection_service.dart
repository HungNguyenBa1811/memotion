/// Pose Detection Service - Real-time WebSocket Integration
/// 
/// Manages connection to backend pose detection API with:
/// - Session lifecycle (start, stream, end)
/// - WebSocket real-time frame streaming
/// - Clean logging by phase
/// - Auto phase transition handling
/// 
/// Author: MEMOTION Team
/// Version: 1.0.0

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../models/pose_detection_model.dart';

/// Logger for pose detection with phase-based tagging
class PoseLogger {
  static const String _tag = '🎯 PoseDetection';
  
  static void phase(int phase, String message) {
    developer.log('[$_tag][Phase $phase] $message');
  }

  static void phaseStart(int phase, String message) {
    developer.log('[$_tag][Phase $phase][START] $message');
  }

  static void phaseComplete(int phase, String message) {
    developer.log('[$_tag][Phase $phase][COMPLETE] $message');
  }
  
  static void info(String message) {
    developer.log('[$_tag] $message');
  }
  
  static void warning(String message) {
    developer.log('[$_tag][WARNING] $message');
  }
  
  static void error(String message, [Object? error]) {
    developer.log('[$_tag][ERROR] $message', error: error);
  }
  
  static void ws(String message) {
    developer.log('[$_tag][WS] $message');
  }
}

/// Pose Detection Service for real-time streaming
class PoseDetectionService {
  // Singleton instance
  static PoseDetectionService? _instance;
  static PoseDetectionService get instance {
    _instance ??= PoseDetectionService._();
    return _instance!;
  }

  PoseDetectionService._();

  // State
  String? _sessionId;
  String? _websocketUrl;
  WebSocketChannel? _channel;
  bool _isConnected = false;
  int _currentPhase = 1;
  int _frameCount = 0;
  DateTime? _sessionStartTime;

  // Stream controllers
  final _frameResultController = StreamController<PoseFrameResult>.broadcast();
  final _phaseChangeController = StreamController<PosePhase>.broadcast();
  final _errorController = StreamController<PoseWebSocketError>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  // Public streams
  Stream<PoseFrameResult> get frameResults => _frameResultController.stream;
  Stream<PosePhase> get phaseChanges => _phaseChangeController.stream;
  Stream<PoseWebSocketError> get errors => _errorController.stream;
  Stream<bool> get connectionState => _connectionStateController.stream;

  // Getters
  String? get sessionId => _sessionId;
  bool get isConnected => _isConnected;
  int get currentPhase => _currentPhase;
  int get frameCount => _frameCount;

  // ==================== SESSION LIFECYCLE ====================

  /// Start a new pose detection session
  /// Returns session info with websocket URL
  Future<PoseSessionResponse> startSession({
    String? userId,
    String exerciseType = 'arm_raise',
    String defaultJoint = 'left_shoulder',
  }) async {
    PoseLogger.info('Starting session: userId=$userId, exercise=$exerciseType');

    try {
      final response = await ApiClient.instance.dio.post(
        '${ApiConstants.baseUrl}/api/pose/sessions',
        data: {
          'user_id': userId,
          'exercise_type': exerciseType,
          'default_joint': defaultJoint,
        },
      );

      final sessionResponse = PoseSessionResponse.fromJson(response.data);
      
      _sessionId = sessionResponse.sessionId;
      _websocketUrl = sessionResponse.websocketUrl;
      _currentPhase = 1;
      _frameCount = 0;
      _sessionStartTime = DateTime.now();

      PoseLogger.info('Session started: $_sessionId');
      PoseLogger.info('WebSocket URL: $_websocketUrl');

      return sessionResponse;
    } catch (e) {
      PoseLogger.error('Failed to start session', e);
      rethrow;
    }
  }

  /// Connect to WebSocket for real-time streaming
  Future<void> connectWebSocket() async {
    if (_websocketUrl == null) {
      throw Exception('Session not started. Call startSession() first.');
    }

    PoseLogger.ws('Connecting to WebSocket...');

    try {
      // Build full WebSocket URL
      final baseUrl = ApiConstants.baseUrl.replaceFirst('http', 'ws');
      final fullUrl = '$baseUrl$_websocketUrl';
      
      PoseLogger.ws('Full URL: $fullUrl');

      _channel = WebSocketChannel.connect(Uri.parse(fullUrl));
      
      // Listen for messages
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _isConnected = true;
      _connectionStateController.add(true);
      PoseLogger.ws('Connected successfully');
    } catch (e) {
      PoseLogger.error('WebSocket connection failed', e);
      _isConnected = false;
      _connectionStateController.add(false);
      rethrow;
    }
  }

  /// Send a camera frame for processing
  void sendFrame(Uint8List frameBytes, {int? timestampMs}) {
    if (!_isConnected || _channel == null) {
      PoseLogger.error('Cannot send frame: not connected');
      return;
    }

    final timestamp = timestampMs ?? DateTime.now().millisecondsSinceEpoch;
    final base64Frame = base64Encode(frameBytes);

    final message = jsonEncode({
      'frame_data': base64Frame,
      'timestamp_ms': timestamp,
    });

    _channel!.sink.add(message);
    _frameCount++;

    // Log every 30 frames (approximately 1 second at 30fps)
    if (_frameCount % 30 == 0) {
      PoseLogger.phase(_currentPhase, 'Sent frame #$_frameCount');
    }
  }

  /// End the current session and get results
  Future<PoseSessionResults> endSession() async {
    if (_sessionId == null) {
      throw Exception('No active session');
    }

    PoseLogger.info('Ending session: $_sessionId');

    try {
      // Close WebSocket first
      await _closeWebSocket();

      // Call API to end session
      final response = await ApiClient.instance.dio.delete(
        '${ApiConstants.baseUrl}/api/pose/sessions/$_sessionId',
      );

      final results = PoseSessionResults.fromJson(response.data);

      PoseLogger.info('Session ended successfully');
      PoseLogger.info('Final score: ${results.totalScore}');
      PoseLogger.info('Duration: ${results.formattedDuration}');
      PoseLogger.info('Total reps: ${results.totalReps}');

      // Reset state
      _resetState();

      return results;
    } catch (e) {
      PoseLogger.error('Failed to end session', e);
      rethrow;
    }
  }

  /// Check if pose detection service is healthy
  Future<PoseHealthResponse> checkHealth() async {
    try {
      final response = await ApiClient.instance.dio.get(
        '${ApiConstants.baseUrl}/api/pose/health',
      );
      return PoseHealthResponse.fromJson(response.data);
    } catch (e) {
      PoseLogger.error('Health check failed', e);
      rethrow;
    }
  }

  /// Disconnect and cleanup
  Future<void> dispose() async {
    await _closeWebSocket();
    await _frameResultController.close();
    await _phaseChangeController.close();
    await _errorController.close();
    await _connectionStateController.close();
    _instance = null;
  }

  // ==================== PRIVATE METHODS ====================

  void _onMessage(dynamic message) {
    try {
      final json = jsonDecode(message as String) as Map<String, dynamic>;

      // Check for session completed event
      if (json.containsKey('event') && json['event'] == 'session_completed') {
        PoseLogger.info('Session completed event received');
        return;
      }

      // Check for error
      if (json.containsKey('error')) {
        final error = PoseWebSocketError.fromJson(json);
        PoseLogger.error('WebSocket error: ${error.error}');
        _errorController.add(error);
        return;
      }

      // Parse frame result
      final result = PoseFrameResult.fromJson(json);

      // Check for phase change
      if (result.phase != _currentPhase) {
        final oldPhase = _currentPhase;
        _currentPhase = result.phase;
        
        PoseLogger.phase(_currentPhase, 
          'Phase changed: ${PosePhase.fromValue(oldPhase).displayName} → ${result.posePhase.displayName}');
        
        _phaseChangeController.add(result.posePhase);
      }

      // Log phase-specific data
      _logPhaseData(result);

      // Emit result
      _frameResultController.add(result);
    } catch (e) {
      PoseLogger.error('Failed to parse message', e);
    }
  }

  void _logPhaseData(PoseFrameResult result) {
    // Log every 30 frames
    if (_frameCount % 30 != 0) return;

    switch (result.phase) {
      case 1:
        PoseLogger.phase(1, 
          'Detection: detected=${result.poseDetected}, stable=${result.stableCount}, progress=${(result.progress * 100).toStringAsFixed(1)}%');
        break;
      case 2:
        PoseLogger.phase(2, 
          'Calibration: joint=${result.currentJointName}, angle=${result.currentAngle.toStringAsFixed(1)}°, max=${result.maxAngle.toStringAsFixed(1)}°');
        break;
      case 3:
        PoseLogger.phase(3, 
          'Sync: score=${result.currentScore.toStringAsFixed(1)}, reps=${result.repCount}, fatigue=${result.fatigueLevel}');
        break;
      case 4:
        PoseLogger.phase(4, 
          'Scoring: total=${result.totalScore.toStringAsFixed(1)}, grade=${result.grade}');
        break;
    }
  }

  void _onError(Object error) {
    PoseLogger.error('WebSocket error', error);
    _isConnected = false;
    _connectionStateController.add(false);
    _errorController.add(PoseWebSocketError(
      error: error.toString(),
      code: '500',
    ));
  }

  void _onDone() {
    PoseLogger.ws('WebSocket connection closed');
    _isConnected = false;
    _connectionStateController.add(false);
  }

  Future<void> _closeWebSocket() async {
    if (_channel != null) {
      PoseLogger.ws('Closing WebSocket...');
      await _channel!.sink.close();
      _channel = null;
      _isConnected = false;
      _connectionStateController.add(false);
    }
  }

  void _resetState() {
    _sessionId = null;
    _websocketUrl = null;
    _currentPhase = 1;
    _frameCount = 0;
    _sessionStartTime = null;
  }
}
