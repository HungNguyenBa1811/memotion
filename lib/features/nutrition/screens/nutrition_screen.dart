import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../models/nutrition_task.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/nutrition_vertical_card.dart';
import '../widgets/nutrition_horizontal_card.dart';
import '../../../features/profile/providers/profile_provider.dart';
import 'patient/patient_nutrition_screen.dart';

/// Role-aware entry point: CARETAKER → NutritionScreenContent, PATIENT → PatientNutritionScreenContent
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileViewModel = ref.watch(profileViewModelProvider);

    if (profileViewModel.isLoadingUserDetails) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final role =
        profileViewModel.userDetails?.role.toUpperCase() ?? 'PATIENT';

    if (role == 'CARETAKER') {
      return const NutritionScreenContent();
    } else {
      return const PatientNutritionScreenContent();
    }
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
    final scale = ResponsiveUtils.textScaleFactor(context);
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final isLarge = ResponsiveUtils.isLargeTablet(context);
    final fontScale = isLarge ? 2.3 : isTablet ? 2.0 : 1.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back and notification
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.horizontalPadding(context),
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.home),
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
                      SizedBox(
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
              padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.horizontalPadding(context)),
              child: Text(
                'Nutrition Plan',
                style: GoogleFonts.lexend(
                  fontSize: 32 * scale * (isTablet ? fontScale * 0.7 : 1.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.horizontalPadding(context)),
              child: Text(
                'Your daily meal tasks',
                style: GoogleFonts.lexend(
                  fontSize: 20 * scale * (isTablet ? fontScale * 0.7 : 1.0),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD87659),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category pills (filter by meal type)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.horizontalPadding(context)),
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

            // Content — demo card always visible; API tasks appended when available
            Expanded(
              child: _buildTasksList(
                context,
                ref,
                nutritionTasksAsync.valueOrNull ?? [],
                isLoading: nutritionTasksAsync.isLoading,
                apiError: nutritionTasksAsync.hasError
                    ? nutritionTasksAsync.error
                    : null,
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
    List<NutritionTask> tasks, {
    bool isLoading = false,
    Object? apiError,
  }) {
    final displayTasks = tasks;

    final hPad = ResponsiveUtils.horizontalPadding(context);
    final bottomPad = ResponsiveUtils.bottomNavPadding(context) + 40;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured vertical cards — demo card always visible
          SizedBox(
            height: 315,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: hPad),
              itemCount: displayTasks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < displayTasks.length - 1 ? 16 : 0,
                  ),
                  child: NutritionVerticalCard(task: displayTasks[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Popular recipes section header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Popular ',
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'recipes',
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFACACAC),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // API state: loading indicator or error banner inline
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (apiError != null)
            _buildInlineApiError(ref, apiError)
          // Additional API task cards when data is present
          else if (tasks.length > 2)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (tasks.length - 2).clamp(0, 3),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: NutritionHorizontalCard(task: tasks[index + 2]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInlineApiError(WidgetRef ref, Object error) {
    final isPatientNotFound = error is PatientProfileNotFoundException;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(
            isPatientNotFound ? Icons.person_off : Icons.error_outline,
            size: 20,
            color: isPatientNotFound ? AppColors.primary : Colors.red.shade300,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPatientNotFound
                  ? 'No patient profile — contact your doctor for a plan.'
                  : 'Could not load tasks. Tap to retry.',
              style: GoogleFonts.lexend(fontSize: 13, color: Colors.grey),
            ),
          ),
          if (!isPatientNotFound)
            GestureDetector(
              onTap: () => ref.invalidate(nutritionTasksProvider),
              child: Icon(Icons.refresh, size: 20, color: AppColors.primary),
            ),
        ],
      ),
    );
  }

}
