import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../models/workout_model.dart';

/// Large vertical workout card for the Patient role.
/// Designed to fill the available display area — used inside a PageView or Split-pane detail.
class WorkoutVerticalCard extends StatelessWidget {
  final WorkoutTask workout;
  final VoidCallback? onStart;

  const WorkoutVerticalCard({
    super.key,
    required this.workout,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = ResponsiveUtils.textScaleFactor(context);
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    
    final typeColor = _colorForType(workout.type);
    final typeIcon = _iconForType(workout.type);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
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
            flex: 5,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: typeColor.withOpacity(0.07)),
                  _buildImage(typeIcon, typeColor, isTablet),
                ],
              ),
            ),
          ),

          // ── Detail area ──────────────────────────────────────────────
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 32 : 24, 
                isTablet ? 20 : 12, 
                isTablet ? 32 : 24, 
                isTablet ? 24 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time chip
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * textScale, 
                      vertical: 4 * textScale,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 14 * textScale, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          workout.time,
                          style: GoogleFonts.lexend(
                            fontSize: 13 * textScale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isTablet ? 12 : 6),
                  // Title
                  Text(
                    workout.title,
                    style: GoogleFonts.lexend(
                      fontSize: 22 * textScale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                      height: 1.2,
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
                        fontSize: 14 * textScale,
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
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
                        SizedBox(width: isTablet ? 24 : 16),
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
                                borderRadius: BorderRadius.circular(14)),
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 32 : 20, 
                              vertical: isTablet ? 18 : 12,
                            ),
                          ),
                          child: Text(
                            'Start',
                            style: GoogleFonts.lexend(
                              fontSize: 15 * textScale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: const Color(0xFF2E7D32), size: 18 * textScale),
                            const SizedBox(width: 6),
                            Text(
                              'Completed',
                              style: GoogleFonts.lexend(
                                fontSize: 14 * textScale,
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
        Icon(icon, size: 16 * textScale, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 13 * textScale,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(IconData typeIcon, Color typeColor, bool isTablet) {
    if (workout.imageAsset != null) {
      return Image.asset(
        workout.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildIconPlaceholder(typeIcon, typeColor, isTablet),
      );
    }
    return Center(child: _buildIconPlaceholder(typeIcon, typeColor, isTablet));
  }

  Widget _buildIconPlaceholder(IconData typeIcon, Color typeColor, bool isTablet) {
    final size = isTablet ? 180.0 : 140.0;
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

