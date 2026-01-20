import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Card displaying upcoming medication with details
class UpcomingMedicationCard extends StatelessWidget {
  final String title;
  final String time;
  final String dosage;
  final String? imageUrl;
  final VoidCallback? onDetailsPressed;

  const UpcomingMedicationCard({
    super.key,
    required this.title,
    required this.time,
    required this.dosage,
    this.imageUrl,
    this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Upcoming Medication',
            style: AppTextStyles.sectionHeading,
          ),
          const SizedBox(height: 16),
          // Medication details row
          Row(
            children: [
              // Medication info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headline3,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: AppTextStyles.lightDescription,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dosage,
                      style: AppTextStyles.lightDescription,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Medication image placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.medication,
                  size: 40,
                  color: AppColors.tealGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDetailsPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'View Details',
                style: AppTextStyles.buttonLarge.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
