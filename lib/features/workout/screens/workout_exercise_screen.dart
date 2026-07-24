import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';

/// Workout Exercise Screen - Calibration Phase (Workout1 from Figma)
/// Flow: Workout Detail -> Workout1 (Calibration) -> Workout1 Done -> Workout2 -> Workout2 Done
class WorkoutExerciseScreen extends ConsumerStatefulWidget {
  final String workoutId;

  const WorkoutExerciseScreen({super.key, required this.workoutId});

  @override
  ConsumerState<WorkoutExerciseScreen> createState() =>
      _WorkoutExerciseScreenState();
}

class _WorkoutExerciseScreenState extends ConsumerState<WorkoutExerciseScreen>
    with TickerProviderStateMixin {
  // Calibration state
  int _holdCountdown = 3;
  bool _isCalibrating = true;
  Timer? _countdownTimer;

  // Simulated calibration values
  int _currentAngle = 0;
  final int _safeLimit = 90;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Start calibration simulation
    _startCalibration();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  void _startCalibration() {
    _progressController.forward();

    // Simulate angle updates during calibration
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !_isCalibrating) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentAngle = (45 * _progressAnimation.value).round();
      });
    });

    // Countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_holdCountdown > 1) {
          _holdCountdown--;
        } else {
          timer.cancel();
          _isCalibrating = false;
          // Navigate to calibration complete
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.push(
                '/workout-calibration-complete',
                extra: {
                  'workoutId': widget.workoutId,
                  'currentAngle': _currentAngle,
                  'safeLimit': _safeLimit,
                },
              );
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7E8),
      body: SafeArea(
        child: Stack(
          children: [
            // Background - Top panel with calibration info
            _buildTopInfoPanel(),

            // Main content with camera/pose placeholder
            _buildMainContent(),

            // Bottom panel with controls
            _buildBottomPanel(),

            // Circular timer overlay
            Positioned(left: 6, bottom: 60, child: _buildCircularTimer()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopInfoPanel() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 150,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F8E9),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'SET A COMFORTABLE RANGE',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 12),

            // Angle info row
            Row(
              children: [
                // Current Angle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Angle',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF979797),
                        ),
                      ),
                      Text(
                        '$_currentAngle',
                        style: GoogleFonts.lexend(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1B4332),
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(width: 1, height: 57, color: const Color(0xFF979797)),

                const SizedBox(width: 16),

                // Safe Limit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Safe Limit',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF979797),
                        ),
                      ),
                      Text(
                        '$_safeLimit',
                        style: GoogleFonts.lexend(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD67052),
                        ),
                      ),
                    ],
                  ),
                ),

                // Safe Zone badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF95D385).withOpacity(0.41),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Safe Zone',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF8CDC77),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Positioned(
      top: 150,
      left: 0,
      right: 0,
      bottom: 148,
      child: Container(
        color: Colors.grey[400],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.accessibility_new,
                size: 120,
                color: Colors.white.withOpacity(0.7),
              ),
              const SizedBox(height: 8),
              Text(
                'Camera View',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 148,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F8E9),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status text
            Text(
              _isCalibrating ? 'Checking your movement...' : 'Ready',
              style: GoogleFonts.lexend(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            Text(
              'Hold this position if it feels comfortable.',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF727070),
              ),
            ),
            const SizedBox(height: 12),

            // End Session button
            GestureDetector(
              onTap: () => _showEndSessionDialog(),
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
                      'End exercise',
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
      ),
    );
  }

  Widget _buildCircularTimer() {
    return SizedBox(
      width: 89,
      height: 89,
      child: Stack(
        children: [
          // Background circle
          CustomPaint(
            size: const Size(89, 89),
            painter: _CircleProgressPainter(
              progress: _progressAnimation.value,
              backgroundColor: Colors.white,
              progressColor: const Color(0xFF00695C),
              strokeWidth: 8,
            ),
          ),

          // Center text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  '${_holdCountdown}s',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF00695C),
                  ),
                ),
              ],
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
          'End exercise?',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Would you like to end this exercise now?',
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
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD67052),
            ),
            child: Text(
              'End exercise',
              style: GoogleFonts.lexend(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for circular progress indicator
class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
