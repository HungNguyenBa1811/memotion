import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/router/app_router.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/theme.dart';
import '../models/nutrition_task.dart';
import '../providers/nutrition_provider.dart';

/// Original screen - kept for backwards compatibility
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const NutritionScreenContent();
  }
}

/// Content version without bottom nav - used inside MainShell
class NutritionScreenContent extends ConsumerWidget {
  const NutritionScreenContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(nutritionFilterProvider);
    final nutritionTasksAsync = ref.watch(
      filteredNutritionTasksProvider(selectedFilter),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back and notification
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Row(
                    children: [
                      // Refresh button
                      GestureDetector(
                        onTap: () => ref.invalidate(nutritionTasksProvider),
                        child: Icon(
                          Icons.refresh,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 24,
                        height: 24,
                        child: Stack(
                          children: [
                            Icon(
                              Icons.notifications,
                              color: AppColors.textPrimary,
                              size: 24,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Nutrition Plan',
                style: GoogleFonts.lexend(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Your daily meal tasks',
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD87659),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category pills (filter by meal type)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryPill(
                      ref,
                      'All',
                      filter: NutritionFilter.all,
                      isActive: selectedFilter == NutritionFilter.all,
                      icon: Icons.restaurant_menu,
                    ),
                    const SizedBox(width: 12),
                    _buildCategoryPill(
                      ref,
                      'Breakfast',
                      filter: NutritionFilter.breakfast,
                      isActive: selectedFilter == NutritionFilter.breakfast,
                      icon: Icons.free_breakfast,
                    ),
                    const SizedBox(width: 12),
                    _buildCategoryPill(
                      ref,
                      'Lunch',
                      filter: NutritionFilter.lunch,
                      isActive: selectedFilter == NutritionFilter.lunch,
                      icon: Icons.lunch_dining,
                    ),
                    const SizedBox(width: 12),
                    _buildCategoryPill(
                      ref,
                      'Dinner',
                      filter: NutritionFilter.dinner,
                      isActive: selectedFilter == NutritionFilter.dinner,
                      icon: Icons.dinner_dining,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Content - API data
            Expanded(
              child: nutritionTasksAsync.when(
                data: (tasks) => _buildTasksList(context, ref, tasks),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorWidget(ref, error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(
    WidgetRef ref,
    String label, {
    required NutritionFilter filter,
    bool isActive = false,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(nutritionFilterProvider.notifier).state = filter;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  icon,
                  size: 20,
                  color: isActive ? Colors.white : Colors.black,
                ),
              ),
            Text(
              label,
              style: GoogleFonts.glory(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(
    BuildContext context,
    WidgetRef ref,
    List<NutritionTask> tasks,
  ) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No nutrition tasks for today',
              style: GoogleFonts.lexend(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 160),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _NutritionTaskCard(task: task),
        );
      },
    );
  }

  Widget _buildErrorWidget(WidgetRef ref, Object error) {
    // Check if error is PatientProfileNotFoundException
    final isPatientNotFound = error is PatientProfileNotFoundException;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPatientNotFound ? Icons.person_off : Icons.error_outline,
              size: 64,
              color: isPatientNotFound
                  ? AppColors.primary
                  : Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isPatientNotFound
                  ? 'Chưa có hồ sơ bệnh nhân'
                  : 'Failed to load nutrition tasks',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPatientNotFound
                  ? 'Vui lòng liên hệ bác sĩ để được tạo hồ sơ bệnh nhân và nhận kế hoạch dinh dưỡng.'
                  : error.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (!isPatientNotFound)
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(nutritionTasksProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Card widget for displaying a nutrition task
class _NutritionTaskCard extends ConsumerWidget {
  final NutritionTask task;

  const _NutritionTaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = task.status == NutritionStatus.completed;

    return GestureDetector(
      onTap: () {
        context.push(
          AppRoutes.nutritionDetail,
          extra: {'taskId': task.id},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Meal image from API or fallback icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: task.mealColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: task.imagePath != null && task.imagePath!.isNotEmpty
                    ? Image.network(
                        '${ApiConstants.baseUrl}${task.imagePath}',
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(task.mealIcon, color: task.mealColor, size: 30);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: task.mealColor,
                            ),
                          );
                        },
                      )
                    : Icon(task.mealIcon, color: task.mealColor, size: 30),
              ),
            ),
            const SizedBox(width: 16),

            // Task info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.time,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: task.mealColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.mealType,
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            color: task.mealColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (task.calories != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${task.calories} Kcal',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Status / Complete button
            if (isCompleted)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.green, size: 24),
              )
            else
              GestureDetector(
                onTap: () async {
                  await ref
                      .read(nutritionNotifierProvider.notifier)
                      .completeTask(task.id);
                  // Refresh list after completing
                  ref.invalidate(nutritionTasksProvider);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
