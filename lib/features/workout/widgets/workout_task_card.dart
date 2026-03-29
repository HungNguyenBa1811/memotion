import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../models/workout_model.dart';

class WorkoutTaskCard extends StatelessWidget {
  final WorkoutTask workout;
  final VoidCallback onTap;
  final double scale;

  const WorkoutTaskCard({
    super.key,
    required this.workout,
    required this.onTap,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = ResponsiveUtils.textScaleFactor(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 110 * scale,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(27 * scale),
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
              top: 10 * scale,
              right: 15 * scale,
              child: Container(
                width: 10 * scale,
                height: 10 * scale,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Image on left side
            Positioned(
              left: 20 * scale,
              top: 0,
              bottom: 0,
              child: Center(
                child: SizedBox(
                  width: 86 * scale,
                  height: 86 * scale,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12 * scale),
                    child: workout.imageAsset != null
                        ? Image.asset(
                            workout.imageAsset!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildIconPlaceholder(textScale * scale);
                            },
                          )
                        : _buildIconPlaceholder(textScale * scale),
                  ),
                ),
              ),
            ),

            // Title and Description
            Positioned(
              left: 120 * scale,
              top: 15 * scale,
              right: 80 * scale,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.title,
                    style: GoogleFonts.lexend(
                      fontSize: 16 * textScale * scale * 0.85,
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
                        fontSize: 11 * textScale * scale * 0.85,
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
              bottom: 15 * scale,
              right: 20 * scale,
              child: Text(
                workout.time,
                style: GoogleFonts.lexend(
                  fontSize: 12 * textScale * scale * 0.8,
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

  Widget _buildIconPlaceholder(double scaleFactor) {
    return Container(
      decoration: BoxDecoration(
        color: _getColorForType(workout.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Icon(
        _getIconForType(workout.type),
        size: 40 * scaleFactor,
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
