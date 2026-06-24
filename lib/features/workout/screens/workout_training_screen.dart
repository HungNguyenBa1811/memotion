import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/theme.dart';
import '../../../core/network/api_constants.dart';

/// Workout Training Screen (Workout2 from Figma)
/// Shows live analysis with dual camera view (user + trainer)
class WorkoutTrainingScreen extends ConsumerStatefulWidget {
  final String workoutId;
  final String? videoPath;

  const WorkoutTrainingScreen({
    super.key,
    required this.workoutId,
    this.videoPath,
  });

  @override
  ConsumerState<WorkoutTrainingScreen> createState() =>
      _WorkoutTrainingScreenState();
}

class _WorkoutTrainingScreenState extends ConsumerState<WorkoutTrainingScreen> {
  // Timer state
  int _elapsedSeconds = 0;
  Timer? _timer;

  // Video player for trainer reference
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initializeVideo();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    if (widget.videoPath == null || widget.videoPath!.isEmpty) {
      print('⚠️ No video path provided');
      return;
    }

    try {
      final fullVideoUrl = '${ApiConstants.baseUrl}${widget.videoPath}';
      print('🎬 Training video URL: $fullVideoUrl');

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(fullVideoUrl),
      );

      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(0); // Mute video
      await _videoController!.play();

      setState(() => _isVideoInitialized = true);
      print('✅ Training video ready!');
    } catch (e) {
      print('💀 Training video error: $e');
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
        // Auto-complete after 3 minutes for demo
        if (_elapsedSeconds >= 180) {
          _completeTraining();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _completeTraining() {
    _timer?.cancel();
    // Navigate to training complete screen
    context.push(
      '/workout-training-complete',
      extra: {
        'workoutId': widget.workoutId,
        'duration': _formatTime(_elapsedSeconds),
        'durationSeconds': _elapsedSeconds,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7E8),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content - split camera views
            Column(
              children: [
                // Top section - User camera with LIVE ANALYSIS badge
                Expanded(flex: 1, child: _buildUserCameraSection()),

                // Bottom section - Trainer view
                Expanded(flex: 1, child: _buildTrainerViewSection()),
              ],
            ),

            // Back button overlay
            Positioned(top: 8, left: 20, child: _buildBackButton()),

            // Bottom control panel
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomPanel(),
            ),
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
              color: Colors.black.withOpacity(0.25),
              blurRadius: 70,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
        ),
      ),
    );
  }

  Widget _buildUserCameraSection() {
    return Stack(
      children: [
        // Camera placeholder
        Container(
          width: double.infinity,
          color: Colors.grey[400],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.accessibility_new,
                  size: 80,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 8),
                Text(
                  'User Camera View',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),

        // LIVE ANALYSIS badge
        Positioned(
          left: 8,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC5C5).withOpacity(0.35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Recording indicator
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.43),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'LIVE ANALYSIS',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
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

  Widget _buildTrainerViewSection() {
    return Stack(
      children: [
        // Trainer video - auto-play, loop, no controls
        Container(
          width: double.infinity,
          color: Colors.grey[600],
          child: _isVideoInitialized && _videoController != null
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.videoPath != null)
                        const CircularProgressIndicator(color: Colors.white)
                      else
                        Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        widget.videoPath != null
                            ? 'Đang tải video...'
                            : 'Trainer View',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
        ),

        // Trainer View badge
        Positioned(
          left: 13,
          top: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF424040).withOpacity(0.35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF030000), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.43),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Trainer View',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
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

  Widget _buildBottomPanel() {
    return Container(
      height: 148,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F8E9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Duration box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD67052).withOpacity(0.64),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      _formatTime(_elapsedSeconds),
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B4332),
                      ),
                    ),
                    Text(
                      'Duration',
                      style: GoogleFonts.lexend(
                        fontSize: 8,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFFF0FFF9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Status text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Training...',
                      style: GoogleFonts.lexend(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Hold your position steady',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF727070),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // End Session button
          GestureDetector(
            onTap: () => _completeTraining(),
            child: Container(
              width: 220,
              height: 53,
              decoration: BoxDecoration(
                color: const Color(0xFF00695C),
                borderRadius: BorderRadius.circular(27),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stop,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'End Session',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
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

  void _showEndSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'End Session?',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to end this training session? Your progress will be saved.',
          style: GoogleFonts.lexend(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continue Training',
              style: GoogleFonts.lexend(color: AppColors.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeTraining();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD67052),
            ),
            child: Text(
              'End Session',
              style: GoogleFonts.lexend(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
