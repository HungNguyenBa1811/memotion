import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/router/app_router.dart';
import '../models/nutrition_task.dart';

/// Horizontal card widget for popular recipes section.
/// Layout: circular image left (overlapping), text content right.
///
/// Pass a [task] to render API data in the Cavolo Nero style.
/// Omit [task] to show the hardcoded Figma demo card.
class NutritionHorizontalCard extends StatelessWidget {
  final NutritionTask? task;

  const NutritionHorizontalCard({super.key, this.task});

  @override
  Widget build(BuildContext context) {
    final title = task?.name ?? 'Cavolo Nero Salad';
    final description = task?.description?.isNotEmpty == true
        ? task!.description!
        : 'Cavolo nero & tomato';
    final calories = task?.calories != null
        ? '${task!.calories} kcal'
        : '230 kcal';

    return GestureDetector(
      onTap: task != null
          ? () => context.push(
              AppRoutes.nutritionDetail,
              extra: {'taskId': task!.id},
            )
          : null,
      child: Container(
        height: 147,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(70),
            bottomLeft: Radius.circular(70),
            topRight: Radius.circular(27),
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
        child: Row(
          children: [
            // Left side — circular image overlapping the card edge
            SizedBox(
              width: 140,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: -16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: ClipOval(child: _buildImage()),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right side — text content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      calories,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Favourite icon
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF4DB6AC).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_outline,
                  size: 18,
                  color: Color(0xFF4DB6AC),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (task?.imagePath != null && task!.imagePath!.isNotEmpty) {
      return Image.network(
        '${ApiConstants.baseUrl}${task!.imagePath}',
        fit: BoxFit.cover,
        errorBuilder: (_, error, _) => _buildPlaceholder(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: task!.mealColor,
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }
    if (task != null) return _buildPlaceholder();
    return Image.asset(
      'assets/images/salad_placeholder.png',
      fit: BoxFit.cover,
      errorBuilder: (_, error, _) =>
          const Icon(Icons.restaurant, size: 52, color: Color(0xFF4DB6AC)),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: task!.mealColor.withOpacity(0.1),
      child: Icon(task!.mealIcon, size: 52, color: task!.mealColor),
    );
  }
}
