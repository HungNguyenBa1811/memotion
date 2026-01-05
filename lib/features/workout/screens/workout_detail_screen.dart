import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../providers/workout_provider.dart';
import '../models/workout_model.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final String workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load workout details when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutDetailProvider.notifier).loadWorkout(widget.workoutId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(workoutDetailProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: detailState.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : detailState.error != null
            ? _buildErrorView(detailState.error!)
            : detailState.workout != null
            ? _buildDetailContent(detailState.workout!)
            : _buildErrorView('Không tìm thấy nhiệm vụ'),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              error,
              style: GoogleFonts.lexend(fontSize: 16, color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'Quay lại',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(WorkoutTask workout) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                // Mark as done button
                GestureDetector(
                  onTap: () => _markAsCompleted(workout),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: workout.isCompleted
                          ? AppColors.secondary.withOpacity(0.2)
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          workout.isCompleted
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: workout.isCompleted
                              ? AppColors.secondary
                              : Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          workout.isCompleted ? 'Đã hoàn thành' : 'Hoàn thành',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: workout.isCompleted
                                ? AppColors.secondary
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Image section with glassmorphism overlay card
          _buildHeroImageSection(workout),
          const SizedBox(height: 24),

          // Title and time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getColorForType(workout.type).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getTypeName(workout.type),
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getColorForType(workout.type),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  workout.title,
                  style: GoogleFonts.lexend(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Time and duration info
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      workout.time,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (workout.durationMinutes != null) ...[
                      const SizedBox(width: 20),
                      Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${workout.durationMinutes} phút',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Description
          if (workout.description != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mô tả',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workout.description!,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Steps
          if (workout.steps != null && workout.steps!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Các bước thực hiện',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...workout.steps!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildStepItem(index + 1, step),
                    );
                  }),
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),

          // Action button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: workout.isCompleted
                    ? null
                    : () => _markAsCompleted(workout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: workout.isCompleted
                      ? AppColors.textSecondary.withOpacity(0.3)
                      : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  workout.isCompleted
                      ? 'Đã hoàn thành nhiệm vụ'
                      : 'Đánh dấu hoàn thành',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStepItem(int stepNumber, String step) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Step content
          Expanded(
            child: Text(
              step,
              style: GoogleFonts.lexend(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the hero image section with glassmorphism overlay card
  /// Design pattern: Stack with positioned overlay for depth effect
  Widget _buildHeroImageSection(WorkoutTask workout) {
    const double imageHeight = 227.0;
    const double overlayCardHeight = 60.0;
    const double overlapOffset = 30.0; // How much the card overlaps the image

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: imageHeight + overlayCardHeight - overlapOffset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main image container
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: imageHeight,
              decoration: BoxDecoration(
                color: _getColorForType(workout.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: _getColorForType(workout.type).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: workout.imageAsset != null
                    ? Image.asset(
                        workout.imageAsset!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: imageHeight,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder(workout);
                        },
                      )
                    : _buildImagePlaceholder(workout),
              ),
            ),
          ),

          // Play button overlay (center of image)
          Positioned(
            top: (imageHeight - 48) / 2,
            left: 0,
            right: 0,
            child: Center(child: _buildPlayButton()),
          ),

          // Glassmorphism info overlay card
          Positioned(
            bottom: 0,
            left: 50,
            right: 50,
            child: _buildGlassmorphismInfoCard(workout),
          ),
        ],
      ),
    );
  }

  /// Builds placeholder when image is not available
  Widget _buildImagePlaceholder(WorkoutTask workout) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getColorForType(workout.type).withOpacity(0.3),
            _getColorForType(workout.type).withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getIconForType(workout.type),
          size: 80,
          color: _getColorForType(workout.type),
        ),
      ),
    );
  }

  /// Builds the centered play button
  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: () {
        // TODO: Implement video play functionality
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tính năng xem video sẽ sớm được cập nhật!',
              style: GoogleFonts.lexend(),
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.play_arrow_rounded,
            color: AppColors.textPrimary,
            size: 28,
          ),
        ),
      ),
    );
  }

  /// Builds the glassmorphism info card with Time and Burn calories
  /// Design: Semi-transparent background with blur effect and gradient border
  Widget _buildGlassmorphismInfoCard(WorkoutTask workout) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF192126).withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              width: 0.5,
              color: const Color(0xFFBBF246).withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Time section
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.access_time_rounded,
                  iconColor: AppColors.primary,
                  label: 'Time',
                  value: workout.durationMinutes != null
                      ? '${workout.durationMinutes} min'
                      : workout.time,
                ),
              ),

              // Vertical divider
              Container(width: 1, height: 35, color: AppColors.primary),

              // Burn calories section
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.textPrimary,
                  label: 'Burn',
                  value: workout.caloriesBurn != null
                      ? '${workout.caloriesBurn} kcal'
                      : '-- kcal',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds individual info item (Time or Burn)
  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Icon container with background
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(icon, color: const Color(0xFFFAFAF5), size: 18),
          ),
          const SizedBox(width: 6),

          // Label and value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFFAFAF5),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFAFAF5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _markAsCompleted(WorkoutTask workout) {
    ref.read(workoutDetailProvider.notifier).markCompleted();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          workout.isCompleted
              ? 'Đã đánh dấu chưa hoàn thành'
              : 'Đã hoàn thành nhiệm vụ!',
          style: GoogleFonts.lexend(),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  IconData _getIconForType(WorkoutType type) {
    switch (type) {
      case WorkoutType.yoga:
        return Icons.self_improvement;
      case WorkoutType.meal:
        return Icons.restaurant;
      case WorkoutType.medicine:
        return Icons.medication;
      case WorkoutType.exercise:
        return Icons.fitness_center;
      case WorkoutType.rest:
        return Icons.hotel;
      case WorkoutType.other:
        return Icons.event;
    }
  }

  Color _getColorForType(WorkoutType type) {
    switch (type) {
      case WorkoutType.yoga:
        return const Color(0xFF7E57C2); // Purple
      case WorkoutType.meal:
        return const Color(0xFFFF7043); // Orange
      case WorkoutType.medicine:
        return const Color(0xFF42A5F5); // Blue
      case WorkoutType.exercise:
        return const Color(0xFF66BB6A); // Green
      case WorkoutType.rest:
        return const Color(0xFFAB47BC); // Violet
      case WorkoutType.other:
        return AppColors.primary;
    }
  }

  String _getTypeName(WorkoutType type) {
    switch (type) {
      case WorkoutType.yoga:
        return 'Yoga';
      case WorkoutType.meal:
        return 'Bữa ăn';
      case WorkoutType.medicine:
        return 'Thuốc';
      case WorkoutType.exercise:
        return 'Tập luyện';
      case WorkoutType.rest:
        return 'Nghỉ ngơi';
      case WorkoutType.other:
        return 'Khác';
    }
  }
}
