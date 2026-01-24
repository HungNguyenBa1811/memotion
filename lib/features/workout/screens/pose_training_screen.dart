/// Pose Training Screen - Real-time Analysis with Video Sync
/// 
/// Phase 3 (Sync) screen showing:
/// - User camera view with pose overlay
/// - Trainer reference video synchronized with user frames
/// - Real-time scoring and feedback
/// 
/// Frame sync: User frames are matched with video frames for accurate comparison
/// 
/// Author: MEMOTION Team
/// Version: 1.0.0

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/theme.dart';
import '../data/camera_service.dart';
import '../data/pose_detection_service.dart';
import '../models/pose_detection_model.dart';
import '../providers/pose_detection_provider.dart';

/// Training screen with video synchronization
class PoseTrainingScreen extends ConsumerStatefulWidget {
  final String workoutId;
  final String? exerciseType;
  final String? videoPath;

  const PoseTrainingScreen({
    super.key,
    required this.workoutId,
    this.exerciseType,
    this.videoPath,
  });

  @override
  ConsumerState<PoseTrainingScreen> createState() => _PoseTrainingScreenState();
}

class _PoseTrainingScreenState extends ConsumerState<PoseTrainingScreen> {
  final CameraService _cameraService = CameraService.instance;
  
  // Video player for trainer reference
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isCameraReady = false;
  bool _isInitialized = false;
  String? _error;
  
  // Timing
  int _elapsedSeconds = 0;
  Timer? _timer;
  DateTime? _sessionStartTime;
  
  // Frame sync tracking
  int _userFrameCount = 0;
  // ignore: unused_field
  int _videoFrameNumber = 0;
  double _syncOffset = 0.0; // ms offset between user and video

  @override
  void initState() {
    super.initState();
    _initializeTraining();
  }

  /// Initialize training screen (Phase 3)
  /// Camera session continues from Phase 1-2, just need to restart streaming
  Future<void> _initializeTraining() async {
    try {
      PoseLogger.phaseStart(3, 'Initializing training screen with video sync');
      
      _sessionStartTime = DateTime.now();

      // 1. Re-initialize camera (always re-init to ensure it's fresh)
      PoseLogger.info('Phase 3: Initializing camera...');
      await _cameraService.initialize(useFrontCamera: true);
      setState(() => _isCameraReady = true);
      PoseLogger.info('Phase 3: Camera initialized');

      // 2. Check WebSocket connection - reconnect if needed
      final sessionState = ref.read(poseSessionProvider);
      if (!sessionState.isConnected) {
        PoseLogger.info('Phase 3: WebSocket not connected, reconnecting...');
        await ref.read(poseSessionProvider.notifier).connectWebSocket();
        PoseLogger.info('Phase 3: WebSocket reconnected');
      }

      // 3. Initialize video player (trainer reference video)
      await _initializeVideo();
      
      // 4. Start timer
      _startTimer();
      
      // 5. Start camera streaming
      await _startFrameStreaming();
      
      // 6. Listen for phase changes
      ref.read(poseSessionProvider.notifier).onPhaseChange = _onPhaseChange;

      setState(() => _isInitialized = true);
      PoseLogger.info('Phase 3: Training screen ready - streaming frames');
    } catch (e) {
      PoseLogger.error('Phase 3: Initialization failed', e);
      setState(() => _error = e.toString());
    }
  }

  /// Get video URL based on exercise type
  String _getVideoUrl() {
    if (widget.videoPath != null) {
      return widget.videoPath!;
    }
    // Default video based on exercise type
    final exerciseType = widget.exerciseType ?? 'arm_raise';
    // TODO: Replace with actual video URLs from backend
    return 'assets/videos/${exerciseType}_demo.mp4';
  }

  Future<void> _initializeVideo() async {
    try {
      final videoUrl = _getVideoUrl();

      print('🎬🎬🎬 VIDEO PLAYER INIT 🎬🎬🎬');
      print('📹 Video URL: $videoUrl');
      print('🔗 Is network URL: ${videoUrl.startsWith('http')}');

      // Use network URL or asset path
      if (videoUrl.startsWith('http')) {
        print('🌐 Creating NetworkUrl controller...');
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
        );
      } else {
        print('📁 Creating Asset controller...');
        _videoController = VideoPlayerController.asset(videoUrl);
      }

      print('⏳ Initializing video controller...');
      await _videoController!.initialize();
      print('✅ Video controller initialized!');
      print('📐 Video size: ${_videoController!.value.size}');
      print('⏱️ Duration: ${_videoController!.value.duration}');

      await _videoController!.setLooping(true);
      await _videoController!.play();

      setState(() => _isVideoInitialized = true);

      print('🎉 VIDEO READY TO PLAY! 🎉');
      PoseLogger.info('Video initialized: $videoUrl');
    } catch (e, stackTrace) {
      print('💀💀💀 VIDEO INIT FAILED 💀💀💀');
      print('❌ Error: $e');
      print('📜 Stack trace: $stackTrace');
      PoseLogger.error('Failed to initialize video', e);
      // Continue without video - still allow training
      setState(() => _isVideoInitialized = false);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  Future<void> _startFrameStreaming() async {
    PoseLogger.info('Phase 3: Starting frame streaming...');
    
    // Always start fresh streaming for Phase 3
    if (_cameraService.isStreaming) {
      await _cameraService.stopStreaming();
    }
    
    await _cameraService.startStreaming(
      onFrame: _onCameraFrame,
    );
    
    PoseLogger.info('Phase 3: Frame streaming started');
  }

  void _onCameraFrame(dynamic frameBytes, int timestamp) {
    _userFrameCount++;
    
    // Log every 30 frames (1 second at 30fps)
    if (_userFrameCount % 30 == 0) {
      final state = ref.read(poseSessionProvider);
      PoseLogger.phase(3, 'Frame #$_userFrameCount sent, connected=${state.isConnected}, '
          'score=${state.syncScore.toStringAsFixed(1)}, reps=${state.repCount}');
    }
    
    // Calculate sync with video
    if (_videoController != null && _isVideoInitialized) {
      final videoPosition = _videoController!.value.position.inMilliseconds;
      final userTime = timestamp - (_sessionStartTime?.millisecondsSinceEpoch ?? timestamp);
      _syncOffset = (userTime - videoPosition).toDouble();
      
      // Update video frame number for backend
      _videoFrameNumber = (videoPosition / 33.33).round(); // 30fps = 33.33ms per frame
    }
    
    // Send frame with video sync info
    ref.read(poseSessionProvider.notifier).sendFrame(
      frameBytes,
      timestampMs: timestamp,
    );
  }

  void _onPhaseChange(PosePhase phase) {
    final state = ref.read(poseSessionProvider);
    
    PoseLogger.info('Training _onPhaseChange: phase=${phase.displayName}, '
        'sessionActive=${state.isSessionActive}, repCount=${state.repCount}');
    
    // Only navigate to results if we actually completed training
    if (phase == PosePhase.completed || phase == PosePhase.scoring) {
      if (state.isSessionActive && state.repCount > 0) {
        PoseLogger.phaseComplete(3, 'Training complete - navigating to results');
        _navigateToResults();
      } else {
        PoseLogger.warning('Ignoring completed phase in training - no reps yet');
      }
    }
  }

  Future<void> _navigateToResults() async {
    _timer?.cancel();
    _videoController?.pause();
    await _cameraService.stopStreaming();
    
    final results = await ref.read(poseSessionProvider.notifier).endSession();
    
    if (mounted && results != null) {
      context.pushReplacement(
        '/workout-training-complete',
        extra: {
          'workoutId': widget.workoutId,
          'results': results,
          'duration': _formatTime(_elapsedSeconds),
        },
      );
    }
  }

  Future<void> _endSession() async {
    await _navigateToResults();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(poseSessionProvider);

    // Show loading while initializing
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFFF1F7E8),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF4CAF50)),
              const SizedBox(height: 16),
              Text(
                'Đang khởi tạo Phase 3...',
                style: GoogleFonts.lexend(fontSize: 16),
              ),
              if (_isCameraReady)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '✓ Camera sẵn sàng',
                    style: GoogleFonts.lexend(fontSize: 14, color: Colors.green),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Show error if any
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF1F7E8),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Lỗi: $_error', style: GoogleFonts.lexend(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F7E8),
      body: SafeArea(
        child: Stack(
          children: [
            // Split view - User camera on top, Trainer video on bottom
            Column(
              children: [
                // User camera section (top half)
                Expanded(flex: 1, child: _buildUserCameraSection(state)),
                
                // Trainer video section (bottom half)
                Expanded(flex: 1, child: _buildTrainerVideoSection()),
              ],
            ),

            // Back button
            Positioned(top: 8, left: 16, child: _buildBackButton()),

            // Live analysis badge on user camera
            Positioned(left: 8, top: 200, child: _buildLiveAnalysisBadge(state)),

            // Bottom control panel
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomPanel(state),
            ),

            // Sync indicator
            Positioned(right: 16, top: 200, child: _buildSyncIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => _showEndSessionDialog(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
      ),
    );
  }

  Widget _buildUserCameraSection(PoseSessionState state) {
    final hasCamera = _isCameraReady && 
                      _cameraService.controller != null && 
                      _cameraService.controller!.value.isInitialized;
    
    return Stack(
      children: [
        // Camera preview
        Container(
          width: double.infinity,
          color: Colors.grey[800],
          child: hasCamera
              ? CameraPreview(_cameraService.controller!)
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videocam_off, size: 64, color: Colors.white54),
                      const SizedBox(height: 8),
                      Text(
                        'Camera đang khởi tạo...',
                        style: GoogleFonts.lexend(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
        ),

        // Connection status indicator
        Positioned(
          left: 16,
          top: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: state.isConnected ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  state.isConnected ? Icons.wifi : Icons.wifi_off,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  state.isConnected ? 'Live' : 'Offline',
                  style: GoogleFonts.lexend(fontSize: 10, color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        // Pose overlay (if landmarks available)
        if (state.lastResult?.landmarks.isNotEmpty ?? false)
          CustomPaint(
            painter: PoseLandmarkPainter(
              landmarks: state.lastResult!.landmarks,
            ),
            size: Size.infinite,
          ),

        // Score overlay
        Positioned(
          right: 16,
          top: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Score',
                  style: GoogleFonts.lexend(fontSize: 10, color: Colors.white70),
                ),
                Text(
                  '${state.syncScore.toStringAsFixed(1)}',
                  style: GoogleFonts.lexend(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(state.syncScore),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainerVideoSection() {
    return Stack(
      children: [
        // Video player
        Container(
          width: double.infinity,
          color: Colors.grey[600],
          child: _isVideoInitialized && _videoController != null
              ? AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 64, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(height: 8),
                      Text(
                        'Video mẫu',
                        style: GoogleFonts.lexend(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
        ),

        // Trainer View badge
        Positioned(
          left: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Trainer View',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveAnalysisBadge(PoseSessionState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC5C5).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Blinking indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: state.isConnected ? Colors.red : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'LIVE ANALYSIS',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncIndicator() {
    final syncStatus = _syncOffset.abs() < 100 ? 'SYNCED' : 'SYNCING';
    final syncColor = _syncOffset.abs() < 100 ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: syncColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: syncColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync, size: 14, color: syncColor),
          const SizedBox(width: 4),
          Text(
            syncStatus,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: syncColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(PoseSessionState state) {
    return Container(
      height: 140,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F8E9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Stats row
          Row(
            children: [
              // Duration
              _buildStatBox(
                _formatTime(_elapsedSeconds),
                'Thời gian',
                const Color(0xFFD67052),
              ),
              const SizedBox(width: 12),
              
              // Reps
              _buildStatBox(
                '${state.repCount}',
                'Lần lặp',
                const Color(0xFF00695C),
              ),
              const SizedBox(width: 12),
              
              // Fatigue
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      state.lastResult?.message ?? 'Đang phân tích...',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Mức mệt mỏi: ${state.fatigueLevel}',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: _getFatigueColor(state.fatigueLevel),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Spacer(),

          // End button
          GestureDetector(
            onTap: _endSession,
            child: Container(
              width: 180,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF00695C),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stop, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Kết thúc',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getFatigueColor(String level) {
    switch (level.toUpperCase()) {
      case 'FRESH': return Colors.green;
      case 'MILD': return Colors.lightGreen;
      case 'MODERATE': return Colors.orange;
      case 'HIGH': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showEndSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kết thúc?', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc muốn kết thúc bài tập?', style: GoogleFonts.lexend()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tiếp tục', style: GoogleFonts.lexend(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endSession();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD67052)),
            child: Text('Kết thúc', style: GoogleFonts.lexend(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for pose landmarks overlay
class PoseLandmarkPainter extends CustomPainter {
  final List<dynamic> landmarks;

  PoseLandmarkPainter({required this.landmarks});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.green.withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw landmarks
    for (final landmark in landmarks) {
      if (landmark is Map) {
        final x = (landmark['x'] as num?)?.toDouble() ?? 0;
        final y = (landmark['y'] as num?)?.toDouble() ?? 0;
        final visibility = (landmark['visibility'] as num?)?.toDouble() ?? 0;
        
        if (visibility > 0.5) {
          canvas.drawCircle(
            Offset(x * size.width, y * size.height),
            5,
            paint,
          );
        }
      }
    }

    // TODO: Draw skeleton connections
  }

  @override
  bool shouldRepaint(covariant PoseLandmarkPainter oldDelegate) {
    return oldDelegate.landmarks != landmarks;
  }
}
