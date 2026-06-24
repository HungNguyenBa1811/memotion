import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../data/nutrition_repository.dart';
import '../models/nutrition_task.dart';

/// Provider for the nutrition repository
final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepository();
});

/// Provider for the list of all nutrition tasks
final nutritionTasksProvider = FutureProvider<List<NutritionTask>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.status != AuthStatus.authenticated) return [];
  debugPrint('┌─────────────────────────────────────────────────────────────');
  debugPrint('│ 🍽️ NUTRITION PROVIDER: Fetching all tasks');
  debugPrint('└─────────────────────────────────────────────────────────────');
  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.getNutritionTasks();
});

/// Provider for nutrition tasks filtered by meal type
final filteredNutritionTasksProvider =
    Provider.family<AsyncValue<List<NutritionTask>>, NutritionFilter>((
      ref,
      filter,
    ) {
      final tasksAsync = ref.watch(nutritionTasksProvider);

      return tasksAsync.when(
        data: (tasks) {
          if (filter == NutritionFilter.all) {
            return AsyncData(tasks);
          }
          return AsyncData(
            tasks
                .where(
                  (t) => t.mealType.toLowerCase() == filter.name.toLowerCase(),
                )
                .toList(),
          );
        },
        loading: () => const AsyncLoading(),
        error: (error, stack) => AsyncError(error, stack),
      );
    });

/// Current selected filter state
final nutritionFilterProvider = StateProvider<NutritionFilter>((ref) {
  return NutritionFilter.all;
});

/// Current selected date for viewing nutrition tasks
final nutritionSelectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// Notifier for nutrition actions
class NutritionNotifier extends StateNotifier<AsyncValue<void>> {
  final NutritionRepository _repository;
  final Ref _ref;

  NutritionNotifier(this._repository, this._ref) : super(const AsyncData(null));

  Future<void> completeTask(String taskId) async {
    debugPrint('┌─────────────────────────────────────────────────────────────');
    debugPrint('│ 🍽️ NUTRITION NOTIFIER: Completing task: $taskId');
    debugPrint('└─────────────────────────────────────────────────────────────');
    state = const AsyncLoading();
    try {
      await _repository.completeNutritionTask(taskId);
      _ref.invalidate(nutritionTasksProvider);
      debugPrint('┌─────────────────────────────────────────────────────────────');
      debugPrint('│ ✅ NUTRITION NOTIFIER: Task completed, invalidated tasks provider');
      debugPrint('└─────────────────────────────────────────────────────────────');
      state = const AsyncData(null);
    } catch (e, st) {
      debugPrint('┌─────────────────────────────────────────────────────────────');
      debugPrint('│ ❌ NUTRITION NOTIFIER ERROR: $e');
      debugPrint('└─────────────────────────────────────────────────────────────');
      state = AsyncError(e, st);
    }
  }
}

/// Provider for nutrition actions
final nutritionNotifierProvider =
    StateNotifierProvider<NutritionNotifier, AsyncValue<void>>((ref) {
      return NutritionNotifier(ref.watch(nutritionRepositoryProvider), ref);
    });

/// Provider for fetching nutrition task detail by ID
final nutritionTaskDetailProvider =
    FutureProvider.family<NutritionTask, String>((ref, taskId) async {
      debugPrint('┌─────────────────────────────────────────────────────────────');
      debugPrint('│ 🍽️ NUTRITION PROVIDER: Fetching detail for taskId: $taskId');
      debugPrint('└─────────────────────────────────────────────────────────────');
      final repository = ref.watch(nutritionRepositoryProvider);
      return repository.getNutritionTaskDetail(taskId);
    });
