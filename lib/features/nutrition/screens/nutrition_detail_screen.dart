import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../models/nutrition_task.dart';
import '../providers/nutrition_provider.dart';

const Color _textDarkGreen = Color(0xFF1B4332);
const Color _subtitleOrange = Color(0xFFD87659);

class NutritionDetailScreen extends ConsumerWidget {
  final String taskId;

  const NutritionDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(nutritionTaskDetailProvider(taskId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: taskAsync.when(
        data: (task) => _NutritionDetailContent(task: task),
        loading: () => const _NutritionDetailLoading(),
        error: (error, stack) => _NutritionDetailError(
          error: error,
          onRetry: () => ref.invalidate(nutritionTaskDetailProvider(taskId)),
        ),
      ),
    );
  }
}

/// Loading state widget
class _NutritionDetailLoading extends StatelessWidget {
  const _NutritionDetailLoading();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state widget
class _NutritionDetailError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _NutritionDetailError({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load information',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textDarkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Main content widget with actual data
class _NutritionDetailContent extends ConsumerWidget {
  final NutritionTask task;

  const _NutritionDetailContent({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ResponsiveUtils.textScaleFactor(context);
    
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 120 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.horizontalPadding(context),
                    vertical: 16 * scale,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40 * scale,
                          height: 40 * scale,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 70 * scale,
                                offset: Offset(0, 4 * scale),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 17 * scale,
                          ),
                        ),
                      ),
                      SizedBox(width: 24 * scale),
                    ],
                  ),
                ),

                // Title - from API
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.horizontalPadding(context),
                  ),
                  child: Text(
                    task.name,
                    style: GoogleFonts.lexend(
                      fontSize: 40 * scale,
                      fontWeight: FontWeight.w700,
                      color: _textDarkGreen,
                      height: 1.12,
                    ),
                  ),
                ),
                SizedBox(height: 15 * scale),

                // Subtitle - meal type from API
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.horizontalPadding(context),
                  ),
                  child: Text(
                    _getMealTypeLabel(task.mealType),
                    style: GoogleFonts.lexend(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w700,
                      color: _subtitleOrange,
                      height: 1.12,
                    ),
                  ),
                ),
                SizedBox(height: 24 * scale),

                // Hero image area with nutrition badges
                SizedBox(
                  height: 350 * scale,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Main image from API or fallback
                      Positioned(
                        right: -140 * scale,
                        top: -10 * scale,
                        child: _buildMainImage(scale: scale),
                      ),

                      // Nutrition section title and badges (left side)
                      Positioned(
                        left: 25 * scale,
                        top: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nutrition',
                              style: GoogleFonts.lexend(
                                fontSize: 26 * scale,
                                fontWeight: FontWeight.w700,
                                color: _textDarkGreen,
                              ),
                            ),
                            SizedBox(height: 20 * scale),
                            _buildNutritionBadge(
                              '${task.calories ?? 0}',
                              'Calories',
                              scale: scale,
                            ),
                            SizedBox(height: 12 * scale),
                            _buildNutritionBadge('--', 'Carbo', scale: scale),
                            SizedBox(height: 12 * scale),
                            _buildNutritionBadge('--', 'Protein', scale: scale),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25 * scale),

                // Description section (if available)
                if (task.description != null &&
                    task.description!.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.horizontalPadding(context),
                    ),
                    child: Text(
                      'Description',
                      style: GoogleFonts.lexend(
                        fontSize: 30 * scale,
                        fontWeight: FontWeight.w700,
                        color: _textDarkGreen,
                        height: 1.25,
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.horizontalPadding(context),
                    ),
                    child: Text(
                      task.description!,
                      style: GoogleFonts.lexend(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.w300,
                        color: _textDarkGreen,
                        height: 1.25,
                      ),
                    ),
                  ),
                  SizedBox(height: 30 * scale),
                ],

                // Time info
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.horizontalPadding(context),
                  ),
                  child: Text(
                    'Time',
                    style: GoogleFonts.lexend(
                      fontSize: 30 * scale,
                      fontWeight: FontWeight.w700,
                      color: _textDarkGreen,
                      height: 1.25,
                    ),
                  ),
                ),
                SizedBox(height: 16 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.horizontalPadding(context),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 24 * scale,
                        color: _textDarkGreen,
                      ),
                      SizedBox(width: 8 * scale),
                      Text(
                        task.time,
                        style: GoogleFonts.lexend(
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.w500,
                          color: _textDarkGreen,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 80 * scale),
              ],
            ),
          ),

          // Status indicator at bottom (tap to complete)
          Positioned(
            left: 37 * scale,
            bottom: 60 * scale,
            child: _buildStatusIndicator(ref, scale: scale),
          ),
        ],
      ),
    );
  }

  Widget _buildMainImage({required double scale}) {
    if (task.imagePath != null && task.imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(200 * scale),
        child: Image.network(
          '${ApiConstants.baseUrl}${task.imagePath}',
          width: 300 * scale,
          height: 300 * scale,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 300 * scale,
              height: 300 * scale,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20 * scale),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.primary,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stack) => _buildFallbackImage(scale: scale),
        ),
      );
    }
    return _buildFallbackImage(scale: scale);
  }

  Widget _buildFallbackImage({required double scale}) {
    return Container(
      width: 300 * scale,
      height: 300 * scale,
      decoration: BoxDecoration(
        color: task.mealColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Center(
        child: Icon(
          task.mealIcon,
          size: 120 * scale,
          color: task.mealColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(WidgetRef ref, {required double scale}) {
    final isCompleted = task.status == NutritionStatus.completed;
    debugPrint('┌─────────────────────────────────────────────────────────────');
    debugPrint('│ 🍽️ UI: Building status indicator');
    debugPrint('│   - Task ID: ${task.id}');
    debugPrint('│   - Status: ${task.status}');
    debugPrint('│   - isCompleted: $isCompleted');
    debugPrint('└─────────────────────────────────────────────────────────────');

    return GestureDetector(
      onTap: isCompleted
          ? null
          : () async {
              await ref
                  .read(nutritionNotifierProvider.notifier)
                  .completeTask(task.id);
              // Refresh detail data after completing - use refresh to force immediate refetch
              ref.invalidate(nutritionTaskDetailProvider(task.id));
            },
      child: SizedBox(
        height: 48 * scale,
        width: isCompleted ? 140 * scale : 180 * scale,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Label container (behind)
            Positioned(
              left: 17 * scale,
              top: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: 48 * scale,
                  right: 20 * scale,
                  top: 14 * scale,
                  bottom: 14 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(70 * scale),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Mark as completed',
                  style: GoogleFonts.lexend(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnPrimary,
                    height: 1.12,
                  ),
                ),
              ),
            ),
            // Icon (in front, overlapping)
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 48 * scale,
                height: 48 * scale,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 50 * scale,
                      offset: Offset(0, 4 * scale),
                    ),
                  ],
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.check_circle_outline,
                  color: AppColors.textOnPrimary,
                  size: 24 * scale,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMealTypeLabel(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snack':
        return 'Snack';
      default:
        return mealType;
    }
  }

  Widget _buildNutritionBadge(String value, String label, {required double scale}) {
    return SizedBox(
      height: 62 * scale,
      width: 160 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Label container (behind)
          Positioned(
            left: 22 * scale,
            top: 8 * scale,
            child: Container(
              padding: EdgeInsets.only(
                left: 50 * scale,
                right: 18 * scale,
                top: 10 * scale,
                bottom: 10 * scale,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(27 * scale),
                  topRight: Radius.circular(27 * scale),
                  bottomLeft: Radius.circular(27 * scale),
                  bottomRight: Radius.circular(27 * scale),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10 * scale,
                    offset: Offset(0, 4 * scale),
                  ),
                ],
              ),
              child: Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.12,
                ),
              ),
            ),
          ),
          // Circle badge (in front, overlapping)
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 62 * scale,
              height: 62 * scale,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10 * scale,
                    offset: Offset(0, 4 * scale),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  value,
                  style: GoogleFonts.lexend(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}