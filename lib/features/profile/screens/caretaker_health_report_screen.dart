import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../health_connect/models/health_data.dart';
import '../../health_connect/providers/health_connect_providers.dart';
import '../../home/widgets/health_summary_card.dart';

/// Health Report Screen for Caretaker (Figma design node 538:4727)
/// Displays progress indicator, today's health metrics (calories, steps, heart rate)
/// and a summary card with vitals
class CaretakerHealthReportScreen extends ConsumerStatefulWidget {
  const CaretakerHealthReportScreen({super.key});

  @override
  ConsumerState<CaretakerHealthReportScreen> createState() =>
      _CaretakerHealthReportScreenState();
}

class _CaretakerHealthReportScreenState
    extends ConsumerState<CaretakerHealthReportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(healthDataProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final healthAsync = ref.watch(healthDataProvider);
    final health = healthAsync.valueOrNull ?? const HealthData();
    final isLoading = healthAsync.isLoading;

    return Scaffold(
      backgroundColor: AppColors.lightGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with back button and refresh
              _buildTopBar(context, isLoading),

              const SizedBox(height: 16),

              // Progress Card
              _buildProgressCard(),

              const SizedBox(height: 24),

              // Today's Information Section
              _buildTodaysInfoSection(health),

              const SizedBox(height: 24),

              // Health Summary Card (reused from home screen)
              HealthSummaryCard(
                heartRate: '${health.heartRate}',
                bloodPressure: '120/80',
                steps: '${health.steps}',
                statusLabel: 'Excellent',
              ),

              // Bottom padding for navigation bar
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF00695C),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          // Refresh Button
          GestureDetector(
            onTap: isLoading
                ? null
                : () => ref.read(healthDataProvider.notifier).fetch(),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.refresh, color: AppColors.primary, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFF1B4332), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.5),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            // Left side: Progress text
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with icon
                  Row(
                    children: [
                      Icon(
                        Icons.data_thresholding_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Progress',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Percentage
                  Text(
                    '95%',
                    style: GoogleFonts.lexend(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Date
                  Text(
                    DateFormat('dd MMMM yyyy').format(DateTime.now()),
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Right side: Circular progress
            Expanded(
              flex: 4,
              child: SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.grey.shade200,
                        ),
                      ),
                    ),
                    // Progress circle
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: CircularProgressIndicator(
                        value: 0.9, // 9/10 = 90%
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // Center text
                    Text(
                      '9/10',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
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

  Widget _buildTodaysInfoSection(HealthData health) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left column: Calories and Steps stacked
            Expanded(
              child: Column(
                children: [
                  _buildCaloriesCard(health.calories.toInt().toString()),
                  const SizedBox(height: 12),
                  _buildStepsCard(health.steps.toString()),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right column: Heart card spanning full height
            Expanded(child: _buildHeartCard(health.heartRate.toString())),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesCard(String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFBFBFBF).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Text(
                'Calories',
                style: GoogleFonts.sourceSans3(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF040415),
                ),
              ),
              const Spacer(),
              // Flame icon
              Icon(
                Icons.local_fire_department,
                color: Colors.green.shade300,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Value
          Text(
            value,
            style: GoogleFonts.sourceSans3(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF040415),
            ),
          ),
          const SizedBox(height: 4),
          // Unit
          Text(
            'Kcal',
            style: GoogleFonts.mavenPro(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7F7F7F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard(String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFBFBFBF).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Text(
                'Steps',
                style: GoogleFonts.sourceSans3(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF040415),
                ),
              ),
              const Spacer(),
              // Shoe icon
              Icon(Icons.directions_run, color: Colors.blue.shade300, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          // Value
          Text(
            value,
            style: GoogleFonts.sourceSans3(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF040415),
            ),
          ),
          const SizedBox(height: 4),
          // Unit
          Text(
            'Steps',
            style: GoogleFonts.mavenPro(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7F7F7F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartCard(String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFBFBFBF).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Text(
                'Heart',
                style: GoogleFonts.sourceSans3(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF040415),
                ),
              ),
              const Spacer(),
              // Heart icon
              Icon(Icons.favorite, color: Colors.red.shade300, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          // Chart area (simplified wave pattern)
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: _HeartRateChartPainter(),
            ),
          ),
          const SizedBox(height: 8),
          // Value
          Text(
            value,
            style: GoogleFonts.sourceSans3(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF040415),
            ),
          ),
          const SizedBox(height: 4),
          // Unit
          Text(
            'bpm',
            style: GoogleFonts.mavenPro(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7F7F7F),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for heart rate chart wave
class _HeartRateChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.shade200
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.red.shade100.withOpacity(0.5),
          Colors.red.shade100.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // Start from left
    path.moveTo(0, size.height * 0.6);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height * 0.6);

    // Create wave pattern
    final points = <Offset>[
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.1, size.height * 0.55),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.45),
      Offset(size.width * 0.4, size.height * 0.3),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.35),
      Offset(size.width * 0.7, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.45),
      Offset(size.width * 0.9, size.height * 0.5),
      Offset(size.width, size.height * 0.55),
    ];

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
      fillPath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}