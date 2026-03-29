import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/theme/theme.dart';
import '../models/medication.dart';

/// Large vertical medication card for the Patient role.
/// Designed to fill the available display area — used inside a PageView.
class MedicationVerticalCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback? onTaken;
  final VoidCallback? onSkip;

  const MedicationVerticalCard({
    super.key,
    required this.medication,
    this.onTaken,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
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

    final statusColor = switch (medication.status) {
      MedicationStatus.taken => const Color(0xFF2E7D32),
      MedicationStatus.missed => const Color(0xFFC62828),
      MedicationStatus.pending => AppColors.primary,
    };


    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Image area ──────────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background tint
                  Container(color: AppColors.primary.withOpacity(0.06)),
                  // Medication image
                  fullImageUrl != null
                      ? Image.network(
                          fullImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Image.asset(
                            pillImages[imageIndex],
                            fit: BoxFit.cover,
                          ),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        )
                      : Image.asset(
                          pillImages[imageIndex],
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.medication,
                            size: 80,
                            color: AppColors.primary.withOpacity(0.4),
                          ),
                        ),
                ],
              ),
            ),
          ),

          // ── Detail area ─────────────────────────────────────────────────
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          medication.time,
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Medication name
                  Text(
                    medication.name,
                    style: GoogleFonts.lexend(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Dosage
                  Text(
                    medication.dosage,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Action buttons (only shown for pending)
                  if (medication.status == MedicationStatus.pending)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onSkip,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.grey.shade300, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Skip',
                              style: GoogleFonts.lexend(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: onTaken,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Mark as Taken',
                              style: GoogleFonts.lexend(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    // Non-actionable status row
                    Row(
                      children: [
                        Icon(
                          medication.status == MedicationStatus.taken
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: statusColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          medication.status == MedicationStatus.taken
                              ? 'You have taken this medication'
                              : 'This dose was missed',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
