import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utils/responsive_utils.dart';
import '../../features/health_connect/providers/yesterday_health_summary_provider.dart';

class HealthStatusNotice extends ConsumerWidget {
  final HealthSummaryArea area;

  const HealthStatusNotice.home({super.key}) : area = HealthSummaryArea.home;

  const HealthStatusNotice.workout({super.key})
    : area = HealthSummaryArea.workout;

  const HealthStatusNotice.nutrition({super.key})
    : area = HealthSummaryArea.nutrition;

  const HealthStatusNotice.medication({super.key})
    : area = HealthSummaryArea.medication;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(yesterdayHealthSummaryProvider(area));
    final content = summary.when(
      data: (value) => HealthStatusNoticeContent.fromSummary(area, value),
      loading: HealthStatusNoticeContent.loading,
      error: (_, _) => HealthStatusNoticeContent.unavailable(),
    );
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
            Icon(content.icon, size: 24 * scale, color: const Color(0xFF1B5E20)),
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

  factory HealthStatusNoticeContent.loading() {
    return const HealthStatusNoticeContent(
      message: "Checking yesterday's summary...",
      icon: Icons.history,
    );
  }

  factory HealthStatusNoticeContent.unavailable() {
    return const HealthStatusNoticeContent(
      message: "Yesterday's summary isn't available yet.",
      icon: Icons.info_outline,
    );
  }

  factory HealthStatusNoticeContent.fromSummary(
    HealthSummaryArea area,
    YesterdayHealthSummary summary,
  ) {
    return switch (area) {
      HealthSummaryArea.home => HealthStatusNoticeContent(
        message: _homeMessage(summary),
        icon: summary.completedAllTasks
            ? Icons.check_circle_outline
            : Icons.lightbulb_outline,
      ),
      HealthSummaryArea.nutrition => HealthStatusNoticeContent(
        message: _nutritionMessage(summary),
        icon: Icons.restaurant_outlined,
      ),
      HealthSummaryArea.workout => HealthStatusNoticeContent(
        message: _workoutMessage(summary),
        icon: Icons.directions_walk_outlined,
      ),
      HealthSummaryArea.medication => HealthStatusNoticeContent(
        message: _medicationMessage(summary),
        icon: Icons.medication_outlined,
      ),
    };
  }

  static String _homeMessage(YesterdayHealthSummary summary) {
    final heartRate = summary.averageHeartRate == null
        ? ''
        : ' (avg ${summary.averageHeartRate} bpm)';
    if (!summary.hasTasks) {
      return 'No care tasks were scheduled yesterday$heartRate.';
    }
    final tasks = _pluralize('care task', summary.totalTasks);
    if (summary.completedAllTasks) {
      return 'Yesterday you completed all ${summary.totalTasks} '
          '$tasks$heartRate.';
    }
    return 'Yesterday you completed ${summary.completedTasks} of '
        '${summary.totalTasks} $tasks$heartRate.';
  }

  static String _nutritionMessage(YesterdayHealthSummary summary) {
    if (!summary.hasTasks) return 'No meals were scheduled yesterday.';
    final calories = summary.recordedCalories == null
        ? ''
        : ' (${summary.recordedCalories} kcal)';
    final meals = _pluralize('meal', summary.totalTasks);
    if (summary.completedAllTasks) {
      return 'Yesterday you logged all ${summary.totalTasks} planned '
          '$meals$calories.';
    }
    return 'Yesterday you logged ${summary.completedTasks} of '
        '${summary.totalTasks} planned $meals$calories.';
  }

  static String _workoutMessage(YesterdayHealthSummary summary) {
    if (!summary.hasTasks) return 'No exercises were scheduled yesterday.';
    final estimateLabel = summary.caloriesAreEstimated ? '~' : '';
    final calories = summary.recordedCalories == null
        ? ''
        : ' ($estimateLabel${summary.recordedCalories} kcal)';
    final exercises = _pluralize('exercise', summary.totalTasks);
    if (summary.completedAllTasks) {
      return 'Yesterday you completed all ${summary.totalTasks} planned '
          '$exercises$calories.';
    }
    return 'Yesterday you completed ${summary.completedTasks} of '
        '${summary.totalTasks} planned $exercises$calories.';
  }

  static String _medicationMessage(YesterdayHealthSummary summary) {
    if (!summary.hasTasks) {
      return 'No medication doses were scheduled yesterday.';
    }
    final doses = _pluralize('dose', summary.totalTasks);
    if (summary.completedAllTasks) {
      return 'Yesterday you took all ${summary.totalTasks} scheduled $doses.';
    }
    return 'Yesterday you took ${summary.completedTasks} of '
        '${summary.totalTasks} scheduled $doses.';
  }

  static String _pluralize(String word, int count) {
    return count == 1 ? word : '${word}s';
  }
}
