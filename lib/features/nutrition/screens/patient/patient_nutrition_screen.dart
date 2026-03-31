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
import '../../../workout/widgets/calendar_day_picker.dart';
import '../../../voice_command/widgets/voice_command_fab.dart';

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

    final displayTasks = nutritionTasksAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, ref),
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
      floatingActionButton: const VoiceCommandFAB(),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final textScale = ResponsiveUtils.textScaleFactor(context);
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final isLarge = ResponsiveUtils.isLargeTablet(context);
    // Mimic the font scale from medication screen
    final fontScale = isLarge ? 2.3 : isTablet ? 2.0 : 1.0;
    
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
                  // Match Medication screen size on tablet, but keep mobile original size
                  fontSize: 18 * textScale * (isTablet ? fontScale * 0.7 : 1.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Your daily meals',
                style: GoogleFonts.lexend(
                  fontSize: 12 * textScale * (isTablet ? fontScale * 0.7 : 1.0),
                  color: const Color(0xFFD87659),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }



  Widget _buildPagedCards(
    BuildContext context,
    List<NutritionTask> tasks, {
    bool isLoading = false,
    Object? apiError,
  }) {
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    
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

        // PageView with large cards
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: tasks.length,
            onPageChanged: (_) {},
            itemBuilder: (context, index) => Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  ResponsiveUtils.bottomNavPadding(context) + (isTablet ? 180 : 16),
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
          final scale = ResponsiveUtils.textScaleFactor(context);
          // Image fills ~86% of card width, same circle + border style as caretaker
          final imageSize = constraints.maxWidth * 0.86;
          // Image overlaps ~45% above the card top edge
          final imageOverlap = imageSize * 0.45;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Non-positioned element defines Stack size
              Padding(
                padding: EdgeInsets.only(top: imageOverlap),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(70 * scale),
                      topRight: Radius.circular(70 * scale),
                      bottomLeft: Radius.circular(27 * scale),
                      bottomRight: Radius.circular(27 * scale),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10 * scale,
                        offset: Offset(0, 4 * scale),
                      ),
                    ],
                  ),
                  // Padding inside the white card
                  padding: EdgeInsets.only(
                    top: (imageSize - imageOverlap) + (24 * scale), // push text below image
                    left: 28 * scale,
                    right: 28 * scale,
                    bottom: 32 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Wrap content height
                    children: [
                      Text(
                        task.name,
                        style: GoogleFonts.lexend(
                          fontSize: 28 * scale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B4332),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4 * scale),
                      if (task.description != null &&
                          task.description!.isNotEmpty)
                        Text(
                          task.description!,
                          style: GoogleFonts.lexend(
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFF1B4332),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: 12 * scale),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            task.calories != null
                                ? '${task.calories} Kcal'
                                : '',
                            style: GoogleFonts.lexend(
                              fontSize: 20 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B4332),
                            ),
                          ),
                          Icon(
                            Icons.favorite_outline,
                            size: 28 * scale,
                            color:
                                const Color(0xFF4DB6AC).withOpacity(0.7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Circular image — positioned at top
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(child: _buildImage(imageSize)),
                    ),
                  ),
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
