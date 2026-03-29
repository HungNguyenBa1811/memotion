import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../models/medication.dart';

class MedicationTaskCard extends StatelessWidget {
  final Medication medication;
  final double scale;

  const MedicationTaskCard({super.key, required this.medication, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final textScale = ResponsiveUtils.textScaleFactor(context);
    final pillImages = [
      'assets/images/medication/pill_1.png',
      'assets/images/medication/pill_2.png',
      'assets/images/medication/pill_3.png',
    ];
    final imageIndex = medication.id.hashCode % pillImages.length;

    final hasApiImage = medication.imageUrl.isNotEmpty;
    final fullImageUrl = hasApiImage
        ? '${ApiConstants.baseUrl}${medication.imageUrl}'
        : null;

    return Container(
      width: double.infinity,
      height: 110 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27 * scale),
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
            top: 10 * scale,
            right: 15 * scale,
            child: Container(
              width: 10 * scale,
              height: 10 * scale,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Image on left side
          Positioned(
            left: 20 * scale,
            top: 0,
            bottom: 0,
            child: Center(
              child: SizedBox(
                width: 86 * scale,
                height: 86 * scale,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12 * scale),
                  child: fullImageUrl != null
                      ? Image.network(
                          fullImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              pillImages[imageIndex],
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, err, st) {
                                return _buildIconPlaceholder(textScale * scale);
                              },
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        )
                      : Image.asset(
                          pillImages[imageIndex],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildIconPlaceholder(textScale * scale);
                          },
                        ),
                ),
              ),
            ),
          ),

          // Title and Description
          Positioned(
            left: 120 * scale,
            top: 15 * scale,
            right: 80 * scale,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: GoogleFonts.lexend(
                    fontSize: 16 * textScale * scale * 0.85,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  medication.dosage,
                  style: GoogleFonts.lexend(
                    fontSize: 11 * textScale * scale * 0.85,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Time at bottom right
          Positioned(
            bottom: 15 * scale,
            right: 20 * scale,
            child: Text(
              medication.time,
              style: GoogleFonts.lexend(
                fontSize: 12 * textScale * scale * 0.8,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconPlaceholder(double scaleFactor) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Icon(
        Icons.medication,
        size: 40 * scaleFactor,
        color: AppColors.primary,
      ),
    );
  }
}
