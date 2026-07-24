import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/router/app_router.dart';
import '../models/nutrition_task.dart';

/// Vertical card widget for displaying nutrition tasks
/// Layout: Image top (with tilt effect), text content bottom
/// Designed based on Figma design specifications
class NutritionVerticalCard extends StatelessWidget {
  final NutritionTask task;
  final VoidCallback? onFavorite;

  const NutritionVerticalCard({super.key, required this.task, this.onFavorite});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.nutritionDetail, extra: {'taskId': task.id});
      },
      child: SizedBox(
        // Card width 227px; image fills width-2px; total height gives room for text
        width: 227,
        height: 320,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // White card background — rounded pill top, gentle bottom corners
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                    bottomLeft: Radius.circular(27),
                    bottomRight: Radius.circular(27),
                  ),
                ),
              ),
            ),

            // Food image — floats above card with -11° tilt (matches Figma: -0.194 rad)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Transform.rotate(
                  angle: -0.194,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(child: _buildImage()),
                  ),
                ),
              ),
            ),

            // Text content — title 24px, subtitle 16px, calories 16px (Figma spec)
            Positioned(
              bottom: 10,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.name,
                    style: GoogleFonts.lexend(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B4332),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  if (task.description != null && task.description!.isNotEmpty)
                    Text(
                      task.description!,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFF1B4332),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        task.calories != null ? '${task.calories} kcal' : '',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B4332),
                        ),
                      ),
                      GestureDetector(
                        onTap: onFavorite,
                        child: Icon(
                          Icons.favorite_outline,
                          size: 22,
                          color: const Color(0xFF4DB6AC).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (task.imagePath != null && task.imagePath!.isNotEmpty) {
      return Image.network(
        '${ApiConstants.baseUrl}${task.imagePath}',
        fit: BoxFit.cover,
        width: 180,
        height: 180,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: task.mealColor,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 160,
      height: 160,
      color: task.mealColor.withOpacity(0.1),
      child: Icon(task.mealIcon, size: 60, color: task.mealColor),
    );
  }
}
