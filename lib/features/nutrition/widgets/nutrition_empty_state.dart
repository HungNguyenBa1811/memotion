import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../models/nutrition_task.dart';

/// Empty state shown when a nutrition request succeeds without any meals.
class NutritionEmptyState extends StatelessWidget {
  final NutritionFilter filter;

  const NutritionEmptyState({super.key, this.filter = NutritionFilter.all});

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveUtils.textScaleFactor(context);
    final isFiltered = filter != NutritionFilter.all;
    final mealName = filter.displayText.toLowerCase();
    final title = isFiltered
        ? 'No $mealName meals scheduled'
        : 'No meals scheduled for today';
    final description = isFiltered
        ? 'Try another meal category to see the rest of today\'s plan.'
        : 'Your meal plan will appear here once it has been added.';

    return Semantics(
      container: true,
      label: '$title. $description',
      child: ExcludeSemantics(
        child: CustomScrollView(
          primary: false,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.horizontalPadding(context),
                vertical: ResponsiveUtils.verticalPadding(context),
              ),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88 * scale,
                        height: 88 * scale,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.no_food_outlined,
                          size: 44 * scale,
                          color: AppColors.secondary,
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 360 * scale),
                        child: Text(
                          description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lexend(
                            fontSize: 14 * scale,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
