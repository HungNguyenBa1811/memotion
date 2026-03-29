import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../models/workout_model.dart';

/// Large vertical workout card for the Patient role.
/// Designed to fill the available display area — used inside a PageView.
class WorkoutVerticalCard extends StatelessWidget {
  final WorkoutTask workout;
  final VoidCallback? onStart;
  final double scale;

  const WorkoutVerticalCard({
    super.key,
    required this.workout,
    this.onStart,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = ResponsiveUtils.textScaleFactor(context);
    
    final typeColor = _colorForType(workout.type);
    final typeIcon = _iconForType(workout.type);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Image / visual area ──────────────────────────────────────
          Expanded(
            flex: 8,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(32 * scale)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: typeColor.withOpacity(0.07)),
                  _buildImage(typeIcon, typeColor),
                ],
              ),
            ),
          ),

          // ── Detail area ──────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24 * scale,
                8 * scale,
                24 * scale,
                8 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time chip
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * textScale * scale, 
                      vertical: 4 * textScale * scale,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10 * scale),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 14 * textScale * scale, color: AppColors.primary),
                        SizedBox(width: 4 * scale),
                        Text(
                          workout.time,
                          style: GoogleFonts.lexend(
                            fontSize: 13 * textScale * scale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  // Title
                  Text(
                    workout.title,
                    style: GoogleFonts.lexend(
                      fontSize: 22 * textScale * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (workout.description != null &&
                      workout.description!.isNotEmpty) ...[
                    SizedBox(height: 4 * scale),
                    Text(
                      workout.description!,
                      style: GoogleFonts.lexend(
                        fontSize: 14 * textScale * scale,
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 4 * scale),
                  // Stats row
                  Row(
                    children: [
                      if (workout.durationMinutes != null)
                        _buildStat(
                          Icons.timer_outlined,
                          '${workout.durationMinutes} min',
                          typeColor,
                          textScale,
                        ),
                      if (workout.caloriesBurn != null) ...[
                        SizedBox(width: 16 * scale),
                        _buildStat(
                          Icons.local_fire_department_outlined,
                          '${workout.caloriesBurn} cal',
                          typeColor,
                          textScale,
                        ),
                      ],
                      const Spacer(),
                      // CTA
                      if (!workout.isCompleted)
                        ElevatedButton(
                          onPressed: onStart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14 * scale)),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20 * scale,
                              vertical: 8 * scale,
                            ),
                          ),
                          child: Text(
                            'Start',
                            style: GoogleFonts.lexend(
                              fontSize: 15 * textScale * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: const Color(0xFF2E7D32), size: 18 * textScale * scale),
                            SizedBox(width: 6 * scale),
                            Text(
                              'Completed',
                              style: GoogleFonts.lexend(
                                fontSize: 14 * textScale * scale,
                                color: const Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
    );
  }

  Widget _buildStat(IconData icon, String label, Color color, double textScale) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16 * textScale * scale, color: color),
        SizedBox(width: 4 * scale),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 13 * textScale * scale,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(IconData typeIcon, Color typeColor) {
    if (workout.imageAsset != null) {
      return Image.asset(
        workout.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildIconPlaceholder(typeIcon, typeColor),
      );
    }
    return Center(child: _buildIconPlaceholder(typeIcon, typeColor));
  }

  Widget _buildIconPlaceholder(IconData typeIcon, Color typeColor) {
    final size = 140.0 * scale;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(typeIcon, size: size * 0.5, color: typeColor.withOpacity(0.7)),
    );
  }

  IconData _iconForType(WorkoutType type) {
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

  Color _colorForType(WorkoutType type) {
    switch (type) {
      case WorkoutType.yoga:
        return const Color(0xFF7E57C2);
      case WorkoutType.meal:
        return const Color(0xFFFF7043);
      case WorkoutType.medicine:
        return const Color(0xFF42A5F5);
      case WorkoutType.exercise:
        return const Color(0xFF66BB6A);
      case WorkoutType.rest:
        return const Color(0xFFAB47BC);
      case WorkoutType.other:
        return AppColors.primary;
    }
  }
}
