import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      height: 234,
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
          // Status indicator dot (top-right)
          Positioned(
            top: 21,
            right: 25,
            child: Container(
              width: 15,
              height: 15,
              decoration: const BoxDecoration(
                color: AppColors.tealGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
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
                            width: 19,
                            height: 19,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.textPrimary,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.access_time,
                              size: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Section title (Caregiver: "Nhắc ông/bà uống thuốc")
                      Text(
                        title,
                        style: AppTextStyles.sectionHeading.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Dosage description
                      Text(
                        dosage,
                        style: AppTextStyles.lightDescription.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const Spacer(),
                      // "Đã uống" button
                      GestureDetector(
                        onTap: onTakenPressed ?? onDetailsPressed,
                        child: Container(
                          width: 153,
                          height: 44,
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
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Đã uống',
                                style: AppTextStyles.headline3.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side - Medication image
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(27),
                  ),
                  child: Center(
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            width: 60,
                            height: 120,
                            fit: BoxFit.contain,
                          )
                        : Image.asset(
                            'assets/images/medication/medication_pills.png',
                            width: 60,
                            height: 120,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.medication,
                                size: 50,
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
