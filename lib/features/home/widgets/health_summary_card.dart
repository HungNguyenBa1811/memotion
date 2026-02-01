import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Floating health summary card with vitals (Figma design)
/// Shows: "Today's Vitals" label, status text, blood pressure, heart rate
class HealthSummaryCard extends StatelessWidget {
  final String heartRate;
  final String bloodPressure;
  final String steps;
  final String statusLabel;
  final String? backgroundImageUrl;

  const HealthSummaryCard({
    super.key,
    this.heartRate = '72',
    this.bloodPressure = '120/80',
    this.steps = '5,420',
    this.statusLabel = 'Very Good',
    this.backgroundImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      height: 99,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Use app color gradient (from Figma) instead of image background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.tealAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Left section: Status
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Today's Vitals",
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF889D93),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusLabel,
                          style: AppTextStyles.largeStat.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFDDE2DF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Middle section: Blood Pressure
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'BLOOD PRESSURE',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF799087),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bloodPressure,
                          style: AppTextStyles.headline2.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFC3CCC7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    width: 2,
                    height: 45,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(width: 12),
                  // Right section: Heart Rate
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'HEART RATE',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF81968D),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              heartRate,
                              style: AppTextStyles.numericStat.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFC6CFCA),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'bpm',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFABB7B0),
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
          ],
        ),
      ),
    );
  }
}