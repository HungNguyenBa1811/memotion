import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Floating health summary card with vitals
class HealthSummaryCard extends StatelessWidget {
  final String heartRate;
  final String bloodPressure;
  final String steps;
  final String? backgroundImageUrl;

  const HealthSummaryCard({
    super.key,
    this.heartRate = '72',
    this.bloodPressure = '120/80',
    this.steps = '5,420',
    this.backgroundImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.tealGreen,
            AppColors.tealGreen.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
          // Background pattern or image would go here
          // For now, using a semi-transparent overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          // Health metrics
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHealthMetric(
                  icon: Icons.favorite,
                  label: 'Heart Rate',
                  value: heartRate,
                  unit: 'bpm',
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildHealthMetric(
                  icon: Icons.monitor_heart,
                  label: 'Blood Pressure',
                  value: bloodPressure,
                  unit: 'mmHg',
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildHealthMetric(
                  icon: Icons.directions_walk,
                  label: 'Steps',
                  value: steps,
                  unit: 'today',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetric({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.numericStat.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: AppTextStyles.lightDescription.copyWith(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
