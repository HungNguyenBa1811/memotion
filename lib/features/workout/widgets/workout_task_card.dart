import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';
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
    final textScale = ResponsiveUtils.textScaleFactor(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Teal dot indicator - top right
            Positioned(
              top: 10,
              right: 15,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Image on left side
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: SizedBox(
                  width: 86,
                  height: 86,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: workout.imageAsset != null
                        ? Image.asset(
                            workout.imageAsset!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildIconPlaceholder(textScale);
                            },
                          )
                        : _buildIconPlaceholder(textScale),
                  ),
                ),
              ),
            ),

            // Title and Description
            Positioned(
              left: 120,
              top: 15,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.title,
                    style: GoogleFonts.lexend(
                      fontSize: 16 * textScale,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (workout.description != null &&
                      workout.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      workout.description!,
                      style: GoogleFonts.lexend(
                        fontSize: 11 * textScale,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Time at bottom right
            Positioned(
              bottom: 15,
              right: 20,
              child: Text(
                workout.time,
                style: GoogleFonts.lexend(
                  fontSize: 12 * textScale,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconPlaceholder(double textScale) {
    return Container(
      decoration: BoxDecoration(
        color: _getColorForType(workout.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getIconForType(workout.type),
        size: 40 * textScale,
        color: _getColorForType(workout.type),
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
