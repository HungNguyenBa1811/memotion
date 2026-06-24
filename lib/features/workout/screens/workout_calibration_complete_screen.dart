import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Workout Calibration Complete Screen (Workout1 Done from Figma)
/// Shows results after calibration phase with Min/Max Angle, Amplitude
class WorkoutCalibrationCompleteScreen extends ConsumerWidget {
  final String workoutId;
  final int minAngle;
  final int maxAngle;
  final String? videoPath;

  const WorkoutCalibrationCompleteScreen({
    super.key,
    required this.workoutId,
    this.minAngle = 20,
    this.maxAngle = 140,
    this.videoPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rangeAngle = maxAngle - minAngle;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F7E8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Header
                _buildHeader(context),
                const SizedBox(height: 16),

                // Session Complete badge
                Text(
                  'Session Complete',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),

                // Exercise name
                Text(
                  'Knee Extension',
                  style: GoogleFonts.lexend(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B4332),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Circular score with range
                _buildCircularScore(rangeAngle),
                const SizedBox(height: 8),

                // Target badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD77658),
                    borderRadius: BorderRadius.circular(27),
                  ),
                  child: Text(
                    'Target',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Great Effort text
                Text(
                  'Great Effort!',
                  style: GoogleFonts.lexend(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B4332),
                  ),
                ),
                const SizedBox(height: 8),

                // Progress message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "You're making excellent progress on your daily posture goals.",
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFAAC5BA),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Stats cards row
                _buildStatsRow(),
                const SizedBox(height: 40),

                // Done button (goes to training)
                _buildDoneButton(context),
                const SizedBox(height: 16),

                // Next Step button
                _buildNextStepButton(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF00695C),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),

        // Empty space to maintain alignment
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildCircularScore(int range) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: const Size(300, 300),
            painter: _ScoreCirclePainter(
              progress: 0.75, // 75% progress
              backgroundColor: Colors.white,
              progressColor: const Color(0xFF00695C),
              strokeWidth: 14,
            ),
          ),

          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$range',
                style: GoogleFonts.lexend(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF00695C),
                ),
              ),
              Text(
                'Range',
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF00695C),
                ),
              ),
            ],
          ),

          // Small indicator dot
          Positioned(
            right: 35,
            top: 110,
            child: Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00695C), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Min Angle card
        _buildStatCard(
          icon: _buildAngleIcon(),
          value: '$minAngle',
          label: 'Min Angle',
        ),

        const SizedBox(width: 8),

        // Max Angle card
        _buildStatCard(
          icon: _buildChartIcon(),
          value: '$maxAngle',
          label: 'Max Angle',
        ),

        const SizedBox(width: 8),

        // Amplitude card
        _buildStatCard(
          icon: _buildFireIcon(),
          value: 'Good',
          label: 'Amplitude',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required Widget icon,
    required String value,
    required String label,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          icon,
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B4332),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFAAC5BA),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAngleIcon() {
    return Container(
      width: 47,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF57C091).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.show_chart, color: Color(0xFF00695C), size: 28),
    );
  }

  Widget _buildChartIcon() {
    return const SizedBox(
      width: 36,
      height: 36,
      child: Icon(Icons.pie_chart, color: Color(0xFF00695C), size: 32),
    );
  }

  Widget _buildFireIcon() {
    return const SizedBox(
      width: 32,
      height: 46,
      child: Icon(
        Icons.local_fire_department,
        color: Color(0xFFFF6B35),
        size: 36,
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Go back to workout detail and mark as complete
        context.go('/workout');
      },
      child: Container(
        width: 301,
        height: 61,
        decoration: BoxDecoration(
          color: const Color(0xFFD87659).withOpacity(0.75),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: Text(
            'Done',
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextStepButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to training phase
        context.push('/workout-training', extra: {
          'workoutId': workoutId,
          'videoPath': videoPath,
        });
      },
      child: Container(
        width: 301,
        height: 61,
        decoration: BoxDecoration(
          color: const Color(0xFF4DB6AC).withOpacity(0.75),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: Text(
            'Next Step',
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreCirclePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _ScoreCirclePainter({
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
  bool shouldRepaint(covariant _ScoreCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
