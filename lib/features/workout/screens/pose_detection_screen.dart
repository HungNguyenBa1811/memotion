/// Pose Detection Screen - Phase 1 & 2 Only
///
/// Screen 1 of workout flow:
/// - Phase 1: Detection (detect user pose)
/// - Phase 2: Calibration (collect angle measurements)
///
/// After Phase 2 completes → Auto navigate to Training Screen (Phase 3)
///
/// Author: MEMOTION Team
/// Version: 2.0.0

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/camera_service.dart';
import '../data/pose_detection_service.dart';
import '../models/pose_detection_model.dart';
import '../providers/pose_detection_provider.dart';

/// Screen 1: Pose Detection & Calibration (Phase 1 & 2)
///
/// Flow:
/// 1. Initialize camera → show user camera preview
/// 2. Start WebSocket session
/// 3. Phase 1: Detect user pose → auto transition to Phase 2
/// 4. Phase 2: Collect angle measurements → auto navigate to Training Screen
class PoseDetectionScreen extends ConsumerStatefulWidget {
  final String workoutId;
  final String? exerciseType;
  final String? videoPath;

  const PoseDetectionScreen({
    super.key,
    required this.workoutId,
    this.exerciseType,
    this.videoPath,
  });

  @override
  ConsumerState<PoseDetectionScreen> createState() =>
      _PoseDetectionScreenState();
}

class _PoseDetectionScreenState extends ConsumerState<PoseDetectionScreen> {
  final CameraService _cameraService = CameraService.instance;
  bool _isCameraInitialized = false;
  bool _handingOffToTraining = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  /// Initialize camera and pose detection session
  Future<void> _initializeSession() async {
    try {
      PoseLogger.phaseStart(1, 'Initializing pose detection session');

      // 1. Initialize camera (front camera for user)
      await _cameraService.initialize(useFrontCamera: true);
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);

      // 2. Start pose detection session via WebSocket
      await ref
          .read(poseSessionProvider.notifier)
          .startSession(
            exerciseType: widget.exerciseType ?? 'arm_raise',
            refVideoPath: widget.videoPath,
          );

      final stateAfterSession = ref.read(poseSessionProvider);
      if (!stateAfterSession.isConnected) {
        setState(
          () => _error =
              'We could not connect to the exercise guide. Please try again.',
        );
        return;
      }

      // 3. Setup phase change listener for auto navigation
      ref.read(poseSessionProvider.notifier).onPhaseChange = _onPhaseChange;

      // 4. Start streaming camera frames to backend
      await _startStreaming();
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _error =
            'We could not start the exercise camera. Please try again.',
      );
      PoseLogger.error('Failed to initialize session', e);
    }
  }

  /// Start streaming camera frames at 30fps
  Future<void> _startStreaming() async {
    await _cameraService.startStreaming(
      onFrame: (frameBytes, timestamp) {
        ref
            .read(poseSessionProvider.notifier)
            .sendFrame(frameBytes, timestampMs: timestamp);
      },
    );
  }

  /// Handle phase transitions - auto navigate when phases complete
  void _onPhaseChange(PosePhase phase) {
    final state = ref.read(poseSessionProvider);

    PoseLogger.info(
      '_onPhaseChange called: phase=${phase.displayName}, '
      'sessionActive=${state.isSessionActive}, repCount=${state.repCount}',
    );

    switch (phase) {
      case PosePhase.calibration:
        // Phase 1 complete → Now in Phase 2 (Calibration)
        // Stay on same screen, UI updates automatically
        PoseLogger.phaseStart(
          2,
          'Starting calibration - collecting angle data',
        );
        break;

      case PosePhase.sync:
        // Phase 2 complete → Navigate to Training Screen (Phase 3)
        // Only navigate if session is actually active
        if (state.isSessionActive) {
          PoseLogger.phaseComplete(2, 'Calibration complete');
          _navigateToTraining();
        } else {
          PoseLogger.warning('Ignoring sync phase change - session not active');
        }
        break;

      case PosePhase.completed:
      case PosePhase.scoring:
        // All phases complete → Navigate to results
        // Only navigate if we actually did some work (repCount > 0 or calibration done)
        if (state.isSessionActive && state.repCount > 0) {
          PoseLogger.phaseComplete(
            3,
            'Session complete - navigating to results',
          );
          _navigateToResults();
        } else {
          PoseLogger.warning('Ignoring completed phase - no reps recorded yet');
        }
        break;

      default:
        break;
    }
  }

  /// Navigate to Training Screen (Phase 3: Camera + Video)
  void _navigateToTraining() {
    PoseLogger.phaseStart(3, 'Navigating to training screen');

    // Stop streaming but keep camera alive — Phase 3 will reuse it
    _cameraService.stopStreaming();
    _handingOffToTraining = true;

    context.pushReplacement(
      '/pose-training',
      extra: {
        'workoutId': widget.workoutId,
        'exerciseType': widget.exerciseType,
        'videoPath': widget.videoPath,
      },
    );
  }

  /// Navigate to workout complete/results
  Future<void> _navigateToResults() async {
    final results = await ref.read(poseSessionProvider.notifier).endSession();
    if (results != null && mounted) {
      context.pushReplacement(
        '/workout-training-complete',
        extra: {'workoutId': widget.workoutId, 'results': results},
      );
    }
  }

  /// End session early
  Future<void> _endSession() async {
    await _cameraService.dispose();
    await ref.read(poseSessionProvider.notifier).endSession();

    if (mounted) {
      context.pop();
    }
  }

  @override
  void dispose() {
    // Don't dispose camera if handing off to Phase 3 — it will manage the camera
    if (!_handingOffToTraining) {
      _cameraService.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(poseSessionProvider);

    // Loading state
    if (!_isCameraInitialized || state.isLoading) {
      return _buildLoadingScreen();
    }

    // Error state
    if (_error != null || state.error != null) {
      return _buildErrorScreen(_error ?? state.error!);
    }

    // Main content: Camera with phase overlay
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7E8),
      body: SafeArea(
        child: Stack(
          children: [
            // Top panel with phase info
            _buildTopPanel(state),

            // Camera preview (full area)
            _buildCameraPreview(),

            // Connection status indicator
            _buildConnectionIndicator(state),

            // Bottom panel with status and controls
            _buildBottomPanel(state),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7E8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF00695C)),
            const SizedBox(height: 24),
            Text(
              'Initializing camera...',
              style: GoogleFonts.lexend(
                fontSize: 16,
                color: const Color(0xFF1B4332),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7E8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'An error occurred',
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top panel showing current phase info
  Widget _buildTopPanel(PoseSessionState state) {
    final isPhase1 = state.currentPhase == PosePhase.detection;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: const BoxConstraints(minHeight: 120, maxHeight: 140),
        decoration: const BoxDecoration(
          color: Color(0xFFF1F8E9),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase indicator
            Row(
              children: [
                _buildPhaseIndicator(
                  1,
                  isPhase1 || state.currentPhase == PosePhase.calibration,
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 2,
                  color: !isPhase1 ? const Color(0xFF00695C) : Colors.grey[300],
                ),
                const SizedBox(width: 8),
                _buildPhaseIndicator(2, !isPhase1),
              ],
            ),
            const SizedBox(height: 8),

            // Phase title
            Text(
              isPhase1 ? 'GETTING YOU IN FRAME' : 'CHECKING YOUR MOVEMENT',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 6),

            // Phase-specific info
            Flexible(
              child: isPhase1
                  ? _buildDetectionInfo(state)
                  : _buildCalibrationInfo(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseIndicator(int phase, bool isActive) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF00695C) : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$phase',
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  /// Phase 1: Detection progress info
  Widget _buildDetectionInfo(PoseSessionState state) {
    return Row(
      children: [
        // Progress percentage
        Text(
          '${(state.detectionProgress * 100).toStringAsFixed(0)}%',
          style: GoogleFonts.lexend(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1B4332),
          ),
        ),
        const SizedBox(width: 16),

        // Detection status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: state.poseDetected
                ? const Color(0xFF95D385).withOpacity(0.4)
                : Colors.orange.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            state.poseDetected ? '✓ Ready' : 'Finding you...',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: state.poseDetected
                  ? Colors.green[700]
                  : Colors.orange[700],
            ),
          ),
        ),
      ],
    );
  }

  /// Phase 2: Calibration progress info
  Widget _buildCalibrationInfo(PoseSessionState state) {
    final queueIndex = state.calibrationQueueIndex + 1; // 0-based to 1-based
    final totalJoints = state.calibrationTotalJoints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Current joint being calibrated with queue progress
        Row(
          children: [
            // Joint name badge
            if (state.calibrationJoint != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00695C).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00695C), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.accessibility_new,
                      size: 16,
                      color: Color(0xFF00695C),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${state.calibrationJoint}',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00695C),
                      ),
                    ),
                  ],
                ),
              ),

            // Queue progress badge (1/6, 2/6, ...)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$queueIndex/$totalJoints',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1565C0),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Angle info row
        Row(
          children: [
            // Current angle being measured
            Text(
              '${state.calibrationAngle.toStringAsFixed(0)}°',
              style: GoogleFonts.lexend(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B4332),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Current angle',
              style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(width: 16),

            // Max angle recorded
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD67052).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Max: ${state.calibrationMaxAngle.toStringAsFixed(0)}°',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD67052),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Camera preview area
  Widget _buildCameraPreview() {
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      bottom: 110,
      child: ClipRRect(
        child: _cameraService.controller != null
            ? CameraPreview(_cameraService.controller!)
            : Container(
                color: Colors.grey[400],
                child: const Center(
                  child: Icon(
                    Icons.videocam_off,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }

  /// Connection status indicator (top-right corner)
  Widget _buildConnectionIndicator(PoseSessionState state) {
    return Positioned(
      top: 130,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: state.isConnected ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              state.isConnected ? 'LIVE' : 'OFFLINE',
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom panel with status message and end button
  Widget _buildBottomPanel(PoseSessionState state) {
    final isCalibrating = state.currentPhase == PosePhase.calibration;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 160,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F8E9),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
        ),
        child: Stack(
          children: [
            // Center content - Title and message
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Large black title text
                  Text(
                    isCalibrating ? 'Calibrating...' : 'Detecting...',
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  // Gray instruction text from backend
                  Text(
                    state.lastResult?.message ??
                        _getDefaultMessage(state.currentPhase),
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF727070),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Circular timer (left side) - only show during calibration
            if (isCalibrating)
              Positioned(left: 6, top: 30, child: _buildCircularTimer(state)),

            // End Session button (center bottom)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _showEndSessionDialog,
                  child: Container(
                    width: 200,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00695C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Square stop icon
                        Container(width: 10, height: 10, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'End exercise',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Circular timer widget for calibration hold countdown
  Widget _buildCircularTimer(PoseSessionState state) {
    final countdown = state.lastResult?.countdownRemaining ?? 3.0;
    final progress = countdown / 3.0; // Assuming 3 second hold

    return SizedBox(
      width: 89,
      height: 89,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: 63,
            height: 63,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 6,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.transparent,
              ),
            ),
          ),
          // Progress arc
          SizedBox(
            width: 63,
            height: 63,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00695C),
              ),
            ),
          ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'HOLD',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF00695C),
                ),
              ),
              Text(
                '${countdown.toInt()}s',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF00695C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDefaultMessage(PosePhase phase) {
    switch (phase) {
      case PosePhase.detection:
        return 'Stand where your full body is visible to begin.';
      case PosePhase.calibration:
        return 'Checking your comfortable range of motion...';
      default:
        return 'Processing...';
    }
  }

  void _showEndSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Stop exercise?',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Would you like to stop now? Your current progress will not be saved.',
          style: GoogleFonts.lexend(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continue',
              style: GoogleFonts.lexend(color: AppColors.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD67052),
            ),
            child: Text('Stop', style: GoogleFonts.lexend(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
