import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utils/responsive_utils.dart';
import '../../features/health_connect/providers/yesterday_health_summary_provider.dart';

class HealthStatusNotice extends StatelessWidget {
  final HealthSummaryArea area;

  const HealthStatusNotice.home({super.key}) : area = HealthSummaryArea.home;

  const HealthStatusNotice.workout({super.key})
    : area = HealthSummaryArea.workout;

  const HealthStatusNotice.nutrition({super.key})
    : area = HealthSummaryArea.nutrition;

  const HealthStatusNotice.medication({super.key})
    : area = HealthSummaryArea.medication;

  @override
  Widget build(BuildContext context) {
    final content = HealthStatusNoticeContent.hardcoded(area);
    final scale = ResponsiveUtils.textScaleFactor(context);

    return Semantics(
      container: true,
      label: content.message,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 14 * scale,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFC8E6C9),
          borderRadius: BorderRadius.circular(20 * scale),
          boxShadow: const [
            BoxShadow(
              color: Color(0x242E7D32),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              content.icon,
              size: 24 * scale,
              color: const Color(0xFF1B5E20),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Text(
                content.message,
                style: GoogleFonts.lexend(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B5E20),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HealthStatusNoticeContent {
  final String message;
  final IconData icon;

  const HealthStatusNoticeContent({required this.message, required this.icon});

  factory HealthStatusNoticeContent.hardcoded(HealthSummaryArea area) {
    return switch (area) {
      HealthSummaryArea.home => const HealthStatusNoticeContent(
        message:
            'Great job yesterday: your average heart rate was 74 bpm and you completed all 8 tasks — keep the same routine today.',
        icon: Icons.check_circle_outline,
      ),
      HealthSummaryArea.nutrition => const HealthStatusNoticeContent(
        message:
            'Good overall yesterday: you ate 3 meals and completed all nutrition tasks, but lunch was 25 minutes late — set an earlier reminder today.',
        icon: Icons.restaurant_outlined,
      ),
      HealthSummaryArea.workout => const HealthStatusNoticeContent(
        message:
            'Good effort yesterday: your exercise heart rate averaged 112 bpm, you burned 240 kcal, and you completed both workouts — prepare early to start on time.',
        icon: Icons.directions_walk_outlined,
      ),
      HealthSummaryArea.medication => const HealthStatusNoticeContent(
        message:
            'Needs improvement: you took all 3 doses yesterday, but the evening dose was 30 minutes late — set an alarm for tonight.',
        icon: Icons.medication_outlined,
      ),
    };
  }
}
