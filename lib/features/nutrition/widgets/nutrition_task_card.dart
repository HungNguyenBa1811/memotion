import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/router/app_router.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/theme/theme.dart';
import '../models/nutrition_task.dart';

class NutritionTaskCard extends StatelessWidget {
  final NutritionTask task;

  const NutritionTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          AppRoutes.nutritionDetail,
          extra: {'taskId': task.id},
        );
      },
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
                    child: task.imagePath != null && task.imagePath!.isNotEmpty
                        ? Image.network(
                            '${ApiConstants.baseUrl}${task.imagePath}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildIconPlaceholder();
                            },
                            loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: task.mealColor,
                                ),
                              );
                            },
                          )
                        : _buildIconPlaceholder(),
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
                    task.name,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.description != null &&
                      task.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: GoogleFonts.lexend(
                        fontSize: 11,
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
                task.time,
                style: GoogleFonts.lexend(
                  fontSize: 12,
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

  Widget _buildIconPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: task.mealColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        task.mealIcon,
        size: 40,
        color: task.mealColor,
      ),
    );
  }
}
