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

  const NutritionVerticalCard({
    super.key,
    required this.task,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          AppRoutes.nutritionDetail,
          extra: {'taskId': task.id},
        );
      },
      child: SizedBox(
        width: 200,
        height: 280,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // White card background
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                    bottomLeft: Radius.circular(27),
                    bottomRight: Radius.circular(27),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),

            // Food image with rotation effect
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Transform.rotate(
                  angle: -0.15, // Slight tilt to the left
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(5, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _buildImage(),
                    ),
                  ),
                ),
              ),
            ),

            // Text content at bottom
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    task.name,
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B4332),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Description
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
                  const SizedBox(height: 6),

                  // Calories and favorite row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Calories
                      Text(
                        task.calories != null ? '${task.calories} Kcal' : '',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B4332),
                        ),
                      ),

                      // Favorite heart icon
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
        width: 160,
        height: 160,
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
      child: Icon(
        task.mealIcon,
        size: 60,
        color: task.mealColor,
      ),
    );
  }
}
