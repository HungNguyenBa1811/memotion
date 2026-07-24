import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/workout_provider.dart';

/// Workout Training Complete Screen (Workout2 Done from Figma)
/// Shows final results with Score, feedback cards, and action buttons
class WorkoutTrainingCompleteScreen extends ConsumerWidget {
  final String workoutId;
  final String duration;
  final int durationSeconds;

  const WorkoutTrainingCompleteScreen({
    super.key,
    required this.workoutId,
    this.duration = '12:30',
    this.durationSeconds = 750,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7E8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
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

                // Circular score
                _buildCircularScore(),
                const SizedBox(height: 32),

                // Great Effort text
                Text(
                  'Well Done',
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
                    'You completed this exercise. Take a moment to rest if you need it.',
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
                const SizedBox(height: 24),

                // What to improve section
                Text(
                  'Tips for next time',
                  style: GoogleFonts.lexend(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B4332),
                  ),
                ),
                const SizedBox(height: 16),

                // Improvement cards
                _buildImprovementCard(
                  title: 'Lower shoulders',
                  description: 'Relax your upper back to avoid tension',
                  isWarning: true,
                ),
                const SizedBox(height: 16),

                _buildImprovementCard(
                  title: 'Good knee alignment',
                  description: 'Perfect stability during squats',
                  isWarning: false,
                ),
                const SizedBox(height: 32),

                // Done button
                _buildDoneButton(context, ref),
                const SizedBox(height: 16),

                // Back to Homepage button
                _buildBackToHomeButton(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
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
      ),
    );
  }

  Widget _buildCircularScore() {
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
              progress: 0.85, // 85% progress
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
                '85',
                style: GoogleFonts.lexend(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF00695C),
                ),
              ),
              Text(
                'Score',
                style: GoogleFonts.lexend(
                  fontSize: 24,
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

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Duration card
        _buildStatCard(icon: _buildClockIcon(), value: duration, label: 'Min'),

        const SizedBox(width: 8),

        // Accuracy card
        _buildStatCard(
          icon: _buildChartIcon(),
          value: '92%',
          label: 'Accuracy',
        ),

        const SizedBox(width: 8),

        // Calories card
        _buildStatCard(icon: _buildFireIcon(), value: '45', label: 'kcal'),
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

  Widget _buildClockIcon() {
    return Container(
      width: 47,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF57C091).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.access_time, color: Color(0xFF00695C), size: 28),
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

  Widget _buildImprovementCard({
    required String title,
    required String description,
    required bool isWarning,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status indicator circle
          Container(
            width: 58,
            height: 57,
            decoration: BoxDecoration(
              color: isWarning
                  ? Colors.red.withOpacity(0.15)
                  : Colors.green.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isWarning ? Icons.arrow_downward : Icons.check,
              color: isWarning
                  ? const Color(0xFFB50000)
                  : const Color(0xFF076500),
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.lexend(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // Status dot
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DB6AC),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        // Mark workout as completed
        await ref.read(workoutDetailProvider.notifier).markCompleted();
        if (context.mounted) {
          // Go back to workout list
          context.go('/workout');
        }
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

  Widget _buildBackToHomeButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/home');
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
            'Back to Home',
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
