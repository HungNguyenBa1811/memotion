import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../models/workout_model.dart';

class WorkoutTaskCard extends StatelessWidget {
  final WorkoutTask workout;
  final VoidCallback onTap;

  const WorkoutTaskCard({
    super.key,
    required this.workout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teal dot indicator
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),

            // Task content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    workout.title,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        workout.time,
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Image thumbnail (if available)
            if (workout.imageAsset != null) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  workout.imageAsset!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconForType(workout.type),
                        size: 30,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              // Icon placeholder based on workout type
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getColorForType(workout.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForType(workout.type),
                  size: 26,
                  color: _getColorForType(workout.type),
                ),
              ),
            ],
          ],
        ),
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
}
