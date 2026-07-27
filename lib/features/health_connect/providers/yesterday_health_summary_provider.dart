import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/models/task_dto.dart';
import '../../../core/network/services/task_api_service.dart';
import 'health_connect_providers.dart';

enum HealthSummaryArea { home, nutrition, workout, medication }

class YesterdayHealthSummary {
  final int? averageHeartRate;
  final int totalTasks;
  final int completedTasks;
  final int? recordedCalories;
  final bool caloriesAreEstimated;

  const YesterdayHealthSummary({
    required this.averageHeartRate,
    required this.totalTasks,
    required this.completedTasks,
    this.recordedCalories,
    this.caloriesAreEstimated = false,
  });

  int get incompleteTasks => totalTasks - completedTasks;
  bool get hasTasks => totalTasks > 0;
  bool get completedAllTasks => hasTasks && incompleteTasks == 0;
}

final healthSummaryTaskApiServiceProvider = Provider<TaskApiService>((ref) {
  return TaskApiService();
});

final yesterdayAverageHeartRateProvider = FutureProvider<int?>((ref) async {
  final service = ref.watch(healthConnectServiceProvider);
  final now = DateTime.now();
  final end = DateTime(now.year, now.month, now.day);
  final start = end.subtract(const Duration(days: 1));

  final authorized = await service.requestAuthorization();
  if (!authorized) return null;

  return service.fetchAverageHeartRate(startTime: start, endTime: end);
});

final yesterdayHealthSummaryProvider =
    FutureProvider.family<YesterdayHealthSummary, HealthSummaryArea>((
      ref,
      area,
    ) async {
      final now = DateTime.now();
      final yesterday = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 1));
      final api = ref.watch(healthSummaryTaskApiServiceProvider);

      final heartRateFuture = ref.watch(
        yesterdayAverageHeartRateProvider.future,
      );
      final tasks = await _loadTasks(api, area, yesterday);
      final averageHeartRate = await heartRateFuture;
      final completedTasks = tasks.where(_isCompleted).toList();

      return YesterdayHealthSummary(
        averageHeartRate: averageHeartRate,
        totalTasks: tasks.length,
        completedTasks: completedTasks.length,
        recordedCalories: switch (area) {
          HealthSummaryArea.nutrition => _nutritionCalories(completedTasks),
          HealthSummaryArea.workout => _estimatedWorkoutCalories(
            completedTasks,
          ),
          _ => null,
        },
        caloriesAreEstimated: area == HealthSummaryArea.workout,
      );
    });

Future<List<TaskDto>> _loadTasks(
  TaskApiService api,
  HealthSummaryArea area,
  DateTime date,
) async {
  switch (area) {
    case HealthSummaryArea.home:
      final taskGroups = await Future.wait([
        api.getMedicationTasksByDate(date),
        api.getNutritionTasksByDate(date),
        api.getExerciseTasksByDate(date),
      ]);
      return taskGroups.expand((tasks) => tasks).toList();
    case HealthSummaryArea.nutrition:
      return api.getNutritionTasksByDate(date);
    case HealthSummaryArea.workout:
      return api.getExerciseTasksByDate(date);
    case HealthSummaryArea.medication:
      return api.getMedicationTasksByDate(date);
  }
}

bool _isCompleted(TaskDto task) {
  return const {
    'completed',
    'taken',
    'done',
  }.contains(task.status.toLowerCase());
}

int? _nutritionCalories(List<TaskDto> tasks) {
  var total = 0;
  var hasValue = false;
  for (final task in tasks) {
    final calories = task.nutritionDetail?.calories;
    if (calories == null) continue;
    total += calories;
    hasValue = true;
  }
  return hasValue ? total : null;
}

int? _estimatedWorkoutCalories(List<TaskDto> tasks) {
  var total = 0;
  var hasValue = false;
  for (final task in tasks) {
    final detail = task.exerciseDetail;
    final duration = detail?.durationMinutes;
    if (duration == null) continue;

    final multiplier = switch (detail?.difficultyLevel) {
      1 => 0.8,
      2 => 1.0,
      3 => 1.2,
      4 => 1.5,
      5 => 2.0,
      _ => 1.0,
    };
    total += (duration * 5 * multiplier).round();
    hasValue = true;
  }
  return hasValue ? total : null;
}
