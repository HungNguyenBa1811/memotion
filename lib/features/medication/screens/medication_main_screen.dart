import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/router/app_router.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../providers/medication_provider.dart';
import '../models/medication.dart';
import '../widgets/medication_task_card.dart';
import '../data/medication_scheduler.dart';

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
  // TEST: tap chuông → nhập số phút → schedule alarm. Xóa method này khi xong test.
  Future<void> _scheduleTestAlarm(BuildContext context) async {
    final controller = TextEditingController(text: '2');
    final minutes = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Test alarm'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Delay (phút)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, int.tryParse(controller.text) ?? 1),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
    if (minutes == null || !context.mounted) return;
    final dueDate = DateTime.now().add(Duration(minutes: minutes));
    await MedicationScheduler.syncTasks({
      'code': '200',
      'data': [
        {
          'task_id': 'test-${dueDate.millisecondsSinceEpoch}',
          'task_duedate': dueDate.toIso8601String(),
          'medication_detail': {
            'name': 'Vitamin D3 1000IU',
            'dosage': '1 viên',
            'notes': 'Uống sau ăn tối',
            'image_path': null,
          },
        },
      ],
    });
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Alarm set: $minutes phút nữa')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(selectedFilterProvider);
    final medicationsAsync = ref.watch(
      filteredMedicationsProvider(selectedFilter),
    );
    final selectedDate = ref.watch(selectedDateProvider);
    final isOffline = ref.watch(isOfflineProvider).valueOrNull ?? false;

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

                // Offline indicator — visible only when network is absent
                if (isOffline) _buildOfflineBanner(),

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
            right: 30,
            bottom: ResponsiveUtils.bottomNavPadding(context),
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
            onTap: () => context.go(AppRoutes.home),
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
          GestureDetector(
            onTap: () => _scheduleTestAlarm(context),
            child: SizedBox(
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
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(DateTime selectedDate) {
    final now = DateTime.now();
    final dayCount = ResponsiveUtils.dateSelectorDays(context);
    final offset = dayCount ~/ 2;
    final dates = List.generate(dayCount, (i) => now.add(Duration(days: i - offset)));

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
                  padding: const EdgeInsets.symmetric(vertical: 4),
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
                          vertical: 0,
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
                  ? 'No patient profile yet'
                  : 'Unable to load medication data',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPatientNotFound
                  ? 'Please contact your doctor to create a patient profile and receive a medication schedule.'
                  : error.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (!isPatientNotFound)
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(medicationsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
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

    final hPad = ResponsiveUtils.horizontalPadding(context);
    final cols = ResponsiveUtils.listColumns(context);
    if (cols > 1) {
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(hPad, 0, hPad, ResponsiveUtils.bottomNavPadding(context) + 40),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.8,
        ),
        itemCount: medications.length,
        itemBuilder: (context, index) =>
            MedicationTaskCard(medication: medications[index]),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, ResponsiveUtils.bottomNavPadding(context) + 40),
      itemCount: medications.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MedicationTaskCard(medication: medications[index]),
        );
      },
    );
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

  Widget _buildOfflineBanner() {
    final pendingCount =
        ref.watch(pendingActionsCountProvider).valueOrNull ?? 0;

    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF3E0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 14, color: Color(0xFFE65100)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              pendingCount > 0
                  ? 'Offline — $pendingCount action${pendingCount > 1 ? 's' : ''} pending sync'
                  : 'Offline — showing cached data',
              style: GoogleFonts.lexend(
                fontSize: 12,
                color: const Color(0xFFE65100),
              ),
            ),
          ),
          if (pendingCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE65100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$pendingCount',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
