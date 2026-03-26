import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../models/nutrition_task.dart';
import '../../providers/nutrition_provider.dart';

/// Nutrition screen for PATIENT (Elderly) role.
/// Displays one large vertical card per meal task in a PageView.
class PatientNutritionScreenContent extends ConsumerStatefulWidget {
  const PatientNutritionScreenContent({super.key});

  @override
  ConsumerState<PatientNutritionScreenContent> createState() =>
      _PatientNutritionScreenContentState();
}

class _PatientNutritionScreenContentState
    extends ConsumerState<PatientNutritionScreenContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(nutritionFilterProvider);
    final nutritionTasksAsync = ref.watch(
      filteredNutritionTasksProvider(selectedFilter),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, ref),
            const SizedBox(height: 8),
            _buildFilterPills(selectedFilter),
            const SizedBox(height: 20),
            Expanded(
              child: nutritionTasksAsync.when(
                data: (tasks) => _buildPagedCards(context, tasks),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) => _buildErrorWidget(ref, error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
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
              decoration: const BoxDecoration(
                color: Color(0xFF00695C),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                'Nutrition Plan',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Your daily meals',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  color: const Color(0xFFD87659),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => ref.invalidate(nutritionTasksProvider),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.refresh, color: AppColors.primary, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills(NutritionFilter selectedFilter) {
    const filters = [
      (NutritionFilter.all, 'All', Icons.restaurant_menu),
      (NutritionFilter.breakfast, 'Breakfast', Icons.free_breakfast),
      (NutritionFilter.lunch, 'Lunch', Icons.lunch_dining),
      (NutritionFilter.dinner, 'Dinner', Icons.dinner_dining),
    ];

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: filters.map((entry) {
          final (filter, label, icon) = entry;
          final isActive = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                ref.read(nutritionFilterProvider.notifier).state = filter;
                _pageController.jumpToPage(0);
                setState(() => _currentPage = 0);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.secondary : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: isActive
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon,
                        size: 18,
                        color: isActive ? Colors.white : Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: GoogleFonts.glory(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPagedCards(BuildContext context, List<NutritionTask> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu,
                size: 72, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No meals for today',
              style: GoogleFonts.lexend(
                  fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Counter "X / N"
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_currentPage + 1}',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                ' / ${tasks.length}',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),

        // PageView with large cards
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: tasks.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                ResponsiveUtils.bottomNavPadding(context) + 16,
              ),
              child: _PatientNutritionCard(
                task: tasks[index],
                onTap: () => context.push(
                  AppRoutes.nutritionDetail,
                  extra: {'taskId': tasks[index].id},
                ),
              ),
            ),
          ),
        ),

        // Dot indicators
        if (tasks.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                tasks.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? AppColors.secondary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget(WidgetRef ref, Object error) {
    final isPatientNotFound = error is PatientProfileNotFoundException;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                  ? 'No patient profile yet'
                  : 'Unable to load meals',
              style: GoogleFonts.lexend(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              isPatientNotFound
                  ? 'Please contact your doctor to set up your nutrition plan.'
                  : error.toString(),
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.lexend(fontSize: 14, color: Colors.grey[600]),
            ),
            if (!isPatientNotFound) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(nutritionTasksProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Full-width patient card ─────────────────────────────────────────────────

class _PatientNutritionCard extends StatelessWidget {
  final NutritionTask task;
  final VoidCallback? onTap;

  const _PatientNutritionCard({required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image area ────────────────────────────────────────────
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: task.mealColor.withOpacity(0.08),
                    ),
                    Center(
                      child: Transform.rotate(
                        angle: -0.08,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: task.mealColor.withOpacity(0.35),
                                blurRadius: 32,
                                offset: const Offset(6, 8),
                              ),
                            ],
                          ),
                          child: ClipOval(child: _buildImage()),
                        ),
                      ),
                    ),
                    // Meal type badge
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: task.mealColor.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: task.mealColor.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(task.mealIcon,
                                size: 14, color: task.mealColor),
                            const SizedBox(width: 4),
                            Text(
                              task.mealType,
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: task.mealColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Detail area ───────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 14, color: task.mealColor),
                        const SizedBox(width: 4),
                        Text(
                          task.time,
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: task.mealColor,
                          ),
                        ),
                        if (task.remainingTime != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '· ${task.remainingTime}',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Name
                    Text(
                      task.name,
                      style: GoogleFonts.lexend(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B4332),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    // Calories + tap hint
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (task.calories != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: task.mealColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${task.calories} kcal',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: task.mealColor,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        Row(
                          children: [
                            Text(
                              'View details',
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                color: task.mealColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 12, color: task.mealColor),
                          ],
                        ),
                      ],
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

  Widget _buildImage() {
    if (task.imagePath != null && task.imagePath!.isNotEmpty) {
      return Image.network(
        '${ApiConstants.baseUrl}${task.imagePath}',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: task.mealColor,
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: task.mealColor.withOpacity(0.1),
      child: Icon(task.mealIcon, size: 80, color: task.mealColor),
    );
  }
}
