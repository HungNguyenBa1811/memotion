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

    // Demo card is always shown; API tasks are appended when available
    final apiTasks = nutritionTasksAsync.valueOrNull ?? [];
    final displayTasks = [_ketoSaladDemo, ...apiTasks];

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
              child: _buildPagedCards(
                context,
                displayTasks,
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

  NutritionTask get _ketoSaladDemo => NutritionTask(
        id: 'demo_keto_salad',
        name: 'Keto Salad',
        description: 'Beans & fruits',
        calories: 370,
        mealType: 'lunch',
        time: '12:00',
        scheduledDate: DateTime.now(),
        status: NutritionStatus.pending,
      );

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

  Widget _buildPagedCards(
    BuildContext context,
    List<NutritionTask> tasks, {
    bool isLoading = false,
    Object? apiError,
  }) {
    return Column(
      children: [
        // Inline API state: loading spinner or error banner
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                color: AppColors.secondary,
                backgroundColor: Colors.transparent,
              ),
            ),
          )
        else if (apiError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                Icon(
                  apiError is PatientProfileNotFoundException
                      ? Icons.person_off
                      : Icons.error_outline,
                  size: 16,
                  color: apiError is PatientProfileNotFoundException
                      ? AppColors.primary
                      : Colors.red.shade300,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    apiError is PatientProfileNotFoundException
                        ? 'No patient profile — showing demo meal.'
                        : 'Could not load meals — showing demo.',
                    style: GoogleFonts.lexend(
                        fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
                if (apiError is! PatientProfileNotFoundException)
                  GestureDetector(
                    onTap: () => ref.invalidate(nutritionTasksProvider),
                    child: const Icon(Icons.refresh,
                        size: 16, color: AppColors.primary),
                  ),
              ],
            ),
          ),

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

}

// ─── Full-width patient card — same layout as Keto Salad, scaled to screen ───

class _PatientNutritionCard extends StatelessWidget {
  final NutritionTask task;
  final VoidCallback? onTap;

  const _PatientNutritionCard({required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Image fills ~86% of card width, same circle + border style as caretaker
          final imageSize = constraints.maxWidth * 0.86;
          // Image overlaps ~45% above the card top edge
          final imageOverlap = imageSize * 0.45;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // White card bg — pill top, gentle bottom (same radius as caretaker)
              Positioned(
                top: imageOverlap,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(70),
                      topRight: Radius.circular(70),
                      bottomLeft: Radius.circular(27),
                      bottomRight: Radius.circular(27),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),

              // Circular image — -11° tilt, white bg, 1px black border
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Transform.rotate(
                    angle: -0.194,
                    child: Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: ClipOval(child: _buildImage(imageSize)),
                    ),
                  ),
                ),
              ),

              // Text — scaled up font sizes for patient readability
              Positioned(
                bottom: 32,
                left: 28,
                right: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.name,
                      style: GoogleFonts.lexend(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B4332),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (task.description != null &&
                        task.description!.isNotEmpty)
                      Text(
                        task.description!,
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF1B4332),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          task.calories != null
                              ? '${task.calories} Kcal'
                              : '',
                          style: GoogleFonts.lexend(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B4332),
                          ),
                        ),
                        Icon(
                          Icons.favorite_outline,
                          size: 28,
                          color:
                              const Color(0xFF4DB6AC).withOpacity(0.7),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImage(double size) {
    if (task.imagePath != null && task.imagePath!.isNotEmpty) {
      return Image.network(
        '${ApiConstants.baseUrl}${task.imagePath}',
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _buildPlaceholder(size),
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
    return _buildPlaceholder(size);
  }

  Widget _buildPlaceholder(double size) {
    return Container(
      color: task.mealColor.withOpacity(0.1),
      child: Icon(task.mealIcon, size: size * 0.4, color: task.mealColor),
    );
  }
}
