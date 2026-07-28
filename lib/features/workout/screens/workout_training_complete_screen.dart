import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pose_detection_model.dart';
import '../providers/workout_provider.dart';

/// Workout Training Complete Screen (Workout2 Done from Figma)
/// Shows final results with Score, feedback cards, and action buttons
class WorkoutTrainingCompleteScreen extends ConsumerWidget {
  final String workoutId;
  final String duration;
  final int durationSeconds;
  final PoseSessionResults? results;

  const WorkoutTrainingCompleteScreen({
    super.key,
    required this.workoutId,
    this.duration = '00:00',
    this.durationSeconds = 0,
    this.results,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = results?.totalScore;
    final scoreColor = _gradeColor(results?.gradeColor);
    final exerciseName = results?.exerciseName.trim();
    final grade = _englishGrade(results?.grade);
    final recommendations = results?.recommendations ?? const <String>[];

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
                  exerciseName == null || exerciseName.isEmpty
                      ? 'Exercise complete'
                      : exerciseName,
                  style: GoogleFonts.lexend(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B4332),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Circular score
                _buildCircularScore(score, scoreColor),
                const SizedBox(height: 32),

                // Great Effort text
                Text(
                  grade,
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
                    results == null
                        ? 'The session ended, but the server did not return final scores.'
                        : 'You completed this exercise. Take a moment to rest if you need it.',
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

                if (recommendations.isEmpty)
                  _buildImprovementCard(
                    title: 'No server recommendations',
                    description: results == null
                        ? 'Final scoring data was unavailable.'
                        : 'The server returned no recommendations for this session.',
                    isWarning: false,
                  )
                else
                  ...recommendations.map(
                    (recommendation) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildImprovementCard(
                        title: 'Recommendation',
                        description: recommendation,
                        isWarning: false,
                      ),
                    ),
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

  Widget _buildCircularScore(double? score, Color scoreColor) {
    final progress = ((score ?? 0) / 100).clamp(0.0, 1.0);
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
              progress: progress,
              backgroundColor: Colors.white,
              progressColor: scoreColor,
              strokeWidth: 14,
            ),
          ),

          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                score == null ? '—' : _formatScore(score),
                style: GoogleFonts.lexend(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  color: scoreColor,
                ),
              ),
              Text(
                score == null ? 'Unavailable' : 'Score',
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: scoreColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final result = results;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatCard(
          icon: _buildMetricIcon(Icons.access_time),
          value: _resolvedDuration,
          label: 'Duration',
        ),
        _buildStatCard(
          icon: _buildMetricIcon(Icons.repeat),
          value: result == null ? '—' : '${result.totalReps}',
          label: 'Reps',
        ),
        _buildStatCard(
          icon: _buildMetricIcon(Icons.accessibility_new),
          value: result == null ? '—' : '${_formatScore(result.romScore)}%',
          label: 'ROM',
        ),
        _buildStatCard(
          icon: _buildMetricIcon(Icons.balance),
          value: result == null
              ? '—'
              : '${_formatScore(result.stabilityScore)}%',
          label: 'Stability',
        ),
        _buildStatCard(
          icon: _buildMetricIcon(Icons.waves),
          value: result == null ? '—' : '${_formatScore(result.flowScore)}%',
          label: 'Flow',
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

  Widget _buildMetricIcon(IconData icon) {
    return Container(
      width: 47,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF57C091).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: const Color(0xFF00695C), size: 28),
    );
  }

  String get _resolvedDuration {
    final resultDuration = results?.durationSeconds ?? 0;
    if (resultDuration > 0) return _formatDuration(resultDuration);
    if (duration.isNotEmpty && duration != '00:00') return duration;
    return _formatDuration(durationSeconds);
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
  }

  String _formatScore(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  String _englishGrade(String? value) {
    final grade = value?.trim() ?? '';
    if (grade.isEmpty) return 'Well Done';

    final normalized = grade
        .toUpperCase()
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
    return switch (normalized) {
      'XUAT SAC' || 'XUẤT SẮC' => 'Excellent',
      'TOT' || 'TỐT' => 'Very Good',
      'KHA' || 'KHÁ' => 'Good',
      'TRUNG BINH' || 'TRUNG BÌNH' => 'Fair',
      'DAT' || 'ĐẠT' => 'Passed',
      'CAN CAI THIEN' ||
      'CẦN CẢI THIỆN' ||
      'YEU' ||
      'YẾU' ||
      'KEM' ||
      'KÉM' ||
      'CHUA DAT' ||
      'CHƯA ĐẠT' => 'Needs Improvement',
      _ => grade,
    };
  }

  Color _gradeColor(String? value) {
    return switch (value?.toLowerCase()) {
      'green' => const Color(0xFF00695C),
      'red' => const Color(0xFFB50000),
      'yellow' => const Color(0xFFD28B00),
      _ => const Color(0xFF00695C),
    };
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
