import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/router/app_router.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/theme.dart';
import '../providers/medication_provider.dart';
import '../models/medication.dart';

/// Original screen with bottom nav - kept for backwards compatibility
class MedicationMainScreen extends ConsumerStatefulWidget {
  const MedicationMainScreen({super.key});

  @override
  ConsumerState<MedicationMainScreen> createState() =>
      _MedicationMainScreenState();
}

class _MedicationMainScreenState extends ConsumerState<MedicationMainScreen> {
  @override
  Widget build(BuildContext context) {
    // Redirect to the shell route version
    return const MedicationMainScreenContent();
  }
}

/// Content version without bottom nav - used inside MainShell
class MedicationMainScreenContent extends ConsumerStatefulWidget {
  const MedicationMainScreenContent({super.key});

  @override
  ConsumerState<MedicationMainScreenContent> createState() =>
      _MedicationMainScreenContentState();
}

class _MedicationMainScreenContentState
    extends ConsumerState<MedicationMainScreenContent> {
  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(selectedFilterProvider);
    final medicationsAsync = ref.watch(
      filteredMedicationsProvider(selectedFilter),
    );
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
                _buildHeader(context),

                // Date selector
                _buildDateSelector(selectedDate),

                const SizedBox(height: 16),

                // Filter tabs
                _buildFilterTabs(selectedFilter),

                const SizedBox(height: 16),

                // Medication list
                Expanded(
                  child: medicationsAsync.when(
                    data: (medications) => _buildMedicationList(medications),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => _buildErrorWidget(error),
                  ),
                ),
              ],
            ),
          ),
          // Floating QR button - positioned bottom right, above navbar
          Positioned(
            right: 20,
            bottom: 100, // Above the bottom navbar
            child: FloatingActionButton(
              onPressed: () => context.push(AppRoutes.medicationScan),
              backgroundColor: AppColors.primary,
              elevation: 4,
              child: const Icon(Icons.qr_code_scanner, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF00695C),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 24,
            height: 24,
            child: Stack(
              children: [
                Icon(
                  Icons.notifications,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
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

  Widget _buildDateSelector(DateTime selectedDate) {
    final now = DateTime.now();
    // 5 days: 2 days before + today + 2 days after
    final dates = List.generate(5, (i) => now.add(Duration(days: i - 2)));

    return SizedBox(
      height: 84,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: dates.map((date) {
          final isSelected =
              date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;

          return GestureDetector(
            onTap: () {
              ref.read(selectedDateProvider.notifier).state = date;
            },
            child: Container(
              width: 64,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: isSelected
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 32,
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getMonthName(date.month),
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF24252C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: GoogleFonts.lexend(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF24252C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDayName(date.weekday),
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF24252C),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterTabs(MedicationFilter selectedFilter) {
    final medicationsAsync = ref.watch(medicationsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: MedicationFilter.values.map((filter) {
            final isSelected = filter == selectedFilter;
            final count =
                medicationsAsync.whenOrNull(
                  data: (meds) {
                    switch (filter) {
                      case MedicationFilter.all:
                        return meds.length;
                      case MedicationFilter.taken:
                        return meds
                            .where((m) => m.status == MedicationStatus.taken)
                            .length;
                      case MedicationFilter.missed:
                        return meds
                            .where((m) => m.status == MedicationStatus.missed)
                            .length;
                    }
                  },
                ) ??
                0;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(selectedFilterProvider.notifier).state = filter;
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        filter.displayText,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF353535),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0B2455)
                              : const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          count.toString(),
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF353535),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    final isPatientNotFound = error is PatientProfileNotFoundException;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPatientNotFound ? Icons.person_off : Icons.error_outline,
              size: 64,
              color: isPatientNotFound
                  ? AppColors.primary
                  : Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isPatientNotFound
                  ? 'Chưa có hồ sơ bệnh nhân'
                  : 'Không thể tải dữ liệu thuốc',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPatientNotFound
                  ? 'Vui lòng liên hệ bác sĩ để được tạo hồ sơ bệnh nhân và nhận lịch uống thuốc.'
                  : error.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (!isPatientNotFound)
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(medicationsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationList(List<Medication> medications) {
    if (medications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No medications found',
              style: GoogleFonts.lexend(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 160),
      itemCount: medications.length,
      itemBuilder: (context, index) {
        return _buildMedicationCard(medications[index]);
      },
    );
  }

  Widget _buildMedicationCard(Medication medication) {
    // Fallback pill images when API doesn't provide image
    final pillImages = [
      'assets/images/medication/pill_1.png',
      'assets/images/medication/pill_2.png',
      'assets/images/medication/pill_3.png',
    ];
    final imageIndex = medication.id.hashCode % pillImages.length;

    // Check if we have an image URL from API
    final hasApiImage = medication.imageUrl.isNotEmpty;
    final fullImageUrl = hasApiImage
        ? '${ApiConstants.baseUrl}${medication.imageUrl}'
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(27),
          bottomLeft: Radius.circular(27),
          topRight: Radius.circular(27),
          bottomRight: Radius.circular(27),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 24,
              top: 24,
              bottom: 24,
              right: 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Medication image - use API image if available, else fallback
                Container(
                  width: 100,
                  height: 85,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(27),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(27),
                    child: fullImageUrl != null
                        ? Image.network(
                            fullImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to asset image on network error
                              return Image.asset(
                                pillImages[imageIndex],
                                fit: BoxFit.contain,
                                errorBuilder: (ctx, err, st) {
                                  return const Icon(
                                    Icons.medication,
                                    size: 40,
                                    color: AppColors.primary,
                                  );
                                },
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            pillImages[imageIndex],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.medication,
                                size: 40,
                                color: AppColors.primary,
                              );
                            },
                          ),
                  ),
                ),

                const SizedBox(width: 22),

                // Medication info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        medication.name,
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        medication.dosage,
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            medication.time,
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF353535),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '|',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            medication.frequency,
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: const Color(0xFF353535),
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

          // Status badge (top right)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                left: 14,
                right: 16,
                top: 4,
                bottom: 4,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(medication.status),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(21),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (medication.remainingTime != null) ...[
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      medication.remainingTime!,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ] else
                    Text(
                      medication.status.displayText,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Action button (bottom right)
          Positioned(
            bottom: 6,
            right: 8,
            child: GestureDetector(
              onTap: medication.status == MedicationStatus.pending
                  ? () => _takeMedication(medication.id)
                  : null,
              child: Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: medication.status == MedicationStatus.pending
                      ? AppColors.primary
                      : _getStatusColor(medication.status),
                  borderRadius: BorderRadius.circular(27),
                ),
                child: Center(
                  child: Text(
                    medication.status == MedicationStatus.pending
                        ? 'Take'
                        : medication.status.displayText,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.pending:
        return AppColors.primary;
      case MedicationStatus.taken:
        return AppColors.primary;
      case MedicationStatus.missed:
        return const Color(0xFFD87659);
    }
  }

  void _takeMedication(String medicationId) {
    ref.read(medicationNotifierProvider.notifier).takeMedication(medicationId);
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
