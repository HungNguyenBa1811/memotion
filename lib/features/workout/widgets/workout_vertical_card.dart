import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../models/workout_model.dart';

/// Large vertical workout card for the Patient role.
/// Designed to fill the available display area — used inside a PageView.
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
                  // Workout illustration / image
                  Center(child: _buildImage(typeIcon, typeColor)),
                  // Type badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: typeColor.withOpacity(0.4), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 13, color: typeColor),
                          const SizedBox(width: 4),
                          Text(
                            workout.type.name.capitalize(),
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Completion badge
                  if (workout.isCompleted)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF2E7D32).withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 13, color: Color(0xFF2E7D32)),
                            const SizedBox(width: 4),
                            Text(
                              'Done',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Detail area ──────────────────────────────────────────────
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          workout.time,
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    workout.title,
                    style: GoogleFonts.lexend(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (workout.description != null &&
                      workout.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      workout.description!,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
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
                        ),
                      if (workout.caloriesBurn != null) ...[
                        const SizedBox(width: 16),
                        _buildStat(
                          Icons.local_fire_department_outlined,
                          '${workout.caloriesBurn} cal',
                          typeColor,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            'Start',
                            style: GoogleFonts.lexend(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF2E7D32), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Completed',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
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

  Widget _buildStat(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(IconData typeIcon, Color typeColor) {
    if (workout.imageAsset != null) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Image.asset(
          workout.imageAsset!,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _buildIconPlaceholder(typeIcon, typeColor),
        ),
      );
    }
    return _buildIconPlaceholder(typeIcon, typeColor);
  }

  Widget _buildIconPlaceholder(IconData typeIcon, Color typeColor) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(typeIcon, size: 72, color: typeColor.withOpacity(0.7)),
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

extension _StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
