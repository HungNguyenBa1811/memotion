import 'package:flutter/material.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive_utils.dart';

/// Card displaying upcoming medication with details (Figma design)
class UpcomingMedicationCard extends StatelessWidget {
  final String title;
  final String time;
  final String dosage;
  final String? imageUrl;
  final VoidCallback? onTakenPressed;
  final VoidCallback? onDetailsPressed;
  final bool isTaken;

  const UpcomingMedicationCard({
    super.key,
    required this.title,
    required this.time,
    required this.dosage,
    this.imageUrl,
    this.onTakenPressed,
    this.onDetailsPressed,
    this.isTaken = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final textScale = ResponsiveUtils.textScaleFactor(context);
    final cardHeight = ResponsiveUtils.isLargeTablet(context) ? 440.0
        : ResponsiveUtils.isTablet(context) ? 370.0
        : 250.0;
    final imageSize = ResponsiveUtils.isLargeTablet(context) ? 290.0
        : ResponsiveUtils.isTablet(context) ? 240.0
        : 120.0;
    final clockIconSize = ResponsiveUtils.isLargeTablet(context) ? 34.0
        : ResponsiveUtils.isTablet(context) ? 28.0
        : 12.0;
    final checkIconSize = ResponsiveUtils.isLargeTablet(context) ? 50.0
        : ResponsiveUtils.isTablet(context) ? 40.0
        : 20.0;

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Content
          Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time with clock icon
                      Row(
                        children: [
                          Container(
                            width: clockIconSize * 1.6,
                            height: clockIconSize * 1.6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.textPrimary,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.access_time,
                              size: clockIconSize,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontSize: 20 * textScale,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 8 : 12),
                      // Section title
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.sectionHeading.copyWith(
                          fontSize: 22 * textScale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: isTablet ? 4 : 8),
                      // Dosage description
                      Text(
                        dosage,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.lightDescription.copyWith(
                          fontSize: 14 * textScale,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const Spacer(),
                      // "Taken" button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onTakenPressed ?? onDetailsPressed,
                          borderRadius: BorderRadius.circular(7),
                          child: Container(
                            width: isTablet ? 200 : 153,
                            height: isTablet ? 56 : 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4F0EE),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isTaken
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                  color: AppColors.primary,
                                  size: checkIconSize,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Taken',
                                  style: AppTextStyles.headline3.copyWith(
                                    fontSize: 20 * textScale,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
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
                // Right side - Medication image
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(27),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(27),
                    child: imageUrl != null
                        ? Image.network(
                            '${ApiConstants.baseUrl}$imageUrl',
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/medication/medication_pills.png',
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.medication,
                                size: isTablet ? 80 : 50,
                                color: AppColors.tealGreen,
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}