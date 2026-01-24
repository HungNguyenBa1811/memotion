import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/theme/theme.dart';
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
                      'Không thể tải thông tin',
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
                      label: const Text('Thử lại'),
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
class _NutritionDetailContent extends StatelessWidget {
  final NutritionTask task;

  const _NutritionDetailContent({required this.task});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back and notification
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 70,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.notifications,
                          color: _textDarkGreen,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Title - from API
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    task.name,
                    style: GoogleFonts.lexend(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: _textDarkGreen,
                      height: 1.12,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Subtitle - meal type from API
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _getMealTypeLabel(task.mealType),
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _subtitleOrange,
                      height: 1.12,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Hero image area with nutrition badges
                SizedBox(
                  height: 350,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Main image from API or fallback
                      Positioned(
                        right: -100,
                        top: -10,
                        child: _buildMainImage(),
                      ),

                      // Nutrition section title and badges (left side)
                      Positioned(
                        left: 25,
                        top: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dinh dưỡng',
                              style: GoogleFonts.lexend(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: _textDarkGreen,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildNutritionBadge(
                              '${task.calories ?? 0}',
                              'Calories',
                            ),
                            const SizedBox(height: 12),
                            _buildNutritionBadge('--', 'Carbo'),
                            const SizedBox(height: 12),
                            _buildNutritionBadge('--', 'Protein'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // Description section (if available)
                if (task.description != null &&
                    task.description!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Text(
                      'Mô tả',
                      style: GoogleFonts.lexend(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: _textDarkGreen,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      task.description!,
                      style: GoogleFonts.lexend(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: _textDarkGreen,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                // Time info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Text(
                    'Thời gian',
                    style: GoogleFonts.lexend(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: _textDarkGreen,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 24,
                        color: _textDarkGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        task.time,
                        style: GoogleFonts.lexend(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: _textDarkGreen,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Status indicator at bottom
          Positioned(
            left: 37,
            bottom: 120,
            child: _buildStatusIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainImage() {
    if (task.imagePath != null && task.imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          '${ApiConstants.baseUrl}${task.imagePath}',
          width: 300,
          height: 300,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
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
          errorBuilder: (context, error, stack) => _buildFallbackImage(),
        ),
      );
    }
    return _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: task.mealColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          task.mealIcon,
          size: 120,
          color: task.mealColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final isCompleted = task.status == NutritionStatus.completed;

    return SizedBox(
      height: 48,
      width: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Label container (behind)
          Positioned(
            left: 17,
            top: 0,
            child: Container(
              padding: const EdgeInsets.only(
                left: 48,
                right: 20,
                top: 14,
                bottom: 14,
              ),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.shade50 : AppColors.background,
                borderRadius: BorderRadius.circular(70),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                isCompleted ? 'Đã hoàn thành' : 'Chưa hoàn thành',
                style: GoogleFonts.lexend(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isCompleted ? Colors.green : Colors.black,
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 50,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.schedule,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMealTypeLabel(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Bữa sáng';
      case 'lunch':
        return 'Bữa trưa';
      case 'dinner':
        return 'Bữa tối';
      case 'snack':
        return 'Bữa phụ';
      default:
        return mealType;
    }
  }

  Widget _buildNutritionBadge(String value, String label) {
    return SizedBox(
      height: 62,
      width: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Label container (behind)
          Positioned(
            left: 22,
            top: 8,
            child: Container(
              padding: const EdgeInsets.only(
                left: 50,
                right: 18,
                top: 10,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(27),
                  topRight: Radius.circular(27),
                  bottomLeft: Radius.circular(27),
                  bottomRight: Radius.circular(27),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 15,
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
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  value,
                  style: GoogleFonts.lexend(
                    fontSize: 20,
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
