import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../models/medication.dart';
import '../../providers/medication_provider.dart';
import '../../widgets/medication_vertical_card.dart';
import '../../widgets/medication_task_card.dart';
import '../../../workout/widgets/calendar_day_picker.dart';
import '../../../workout/models/workout_model.dart';

/// Medication screen for PATIENT (Elderly) role.
/// Displays one large vertical card per medication in a PageView (Mobile)
/// or a Split-Pane Master-Detail layout (Tablet).
class PatientMedicationScreenContent extends ConsumerStatefulWidget {
  const PatientMedicationScreenContent({super.key});

  @override
  ConsumerState<PatientMedicationScreenContent> createState() =>
      _PatientMedicationScreenContentState();
}

class _PatientMedicationScreenContentState
    extends ConsumerState<PatientMedicationScreenContent> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  late int _selectedDayIndex;
  late List<CalendarDay> _calendarDays;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuildCalendarDays();
  }

  void _rebuildCalendarDays() {
    final dayCount = ResponsiveUtils.dateSelectorDays(context);
    final offset = dayCount ~/ 2;
    final now = DateTime.now();
    _calendarDays = List.generate(dayCount, (i) {
      final date = now.add(Duration(days: i - offset));
      return CalendarDay(date: date, dayOfWeek: '', month: '', isSelected: i == offset);
    });
    _selectedDayIndex = offset;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _resetSelection() {
    setState(() {
      _selectedIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
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
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: isTablet
            ? _buildTabletLayout(medicationsAsync, selectedDate, selectedFilter, isOffline)
            : _buildMobileLayout(medicationsAsync, selectedDate, selectedFilter, isOffline),
      ),
    );
  }

  Widget _buildMobileLayout(
    AsyncValue<List<Medication>> medicationsAsync, 
    DateTime selectedDate, 
    MedicationFilter selectedFilter, 
    bool isOffline
  ) {
    return Column(
      children: [
        _buildHeader(context),
        if (isOffline) _buildOfflineBanner(),
        CalendarDayPicker(
          days: _calendarDays,
          selectedIndex: _selectedDayIndex,
          onDaySelected: (index) {
            setState(() => _selectedDayIndex = index);
            ref.read(selectedDateProvider.notifier).state =
                _calendarDays[index].date;
            _resetSelection();
          },
        ),
        const SizedBox(height: 16),
        _buildFilterTabs(selectedFilter),
        const SizedBox(height: 16),
        Expanded(
          child: medicationsAsync.when(
            data: (medications) => _buildPagedCards(medications),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildErrorWidget(error),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    AsyncValue<List<Medication>> medicationsAsync, 
    DateTime selectedDate, 
    MedicationFilter selectedFilter, 
    bool isOffline
  ) {
    final hPad = ResponsiveUtils.horizontalPadding(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Pane: Master List
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, isTablet: true),
                if (isOffline) _buildOfflineBanner(),
                CalendarDayPicker(
          days: _calendarDays,
          selectedIndex: _selectedDayIndex,
          onDaySelected: (index) {
            setState(() => _selectedDayIndex = index);
            ref.read(selectedDateProvider.notifier).state =
                _calendarDays[index].date;
            _resetSelection();
          },
        ),
                const SizedBox(height: 16),
                _buildFilterTabs(selectedFilter),
                const SizedBox(height: 16),
                Expanded(
                  child: medicationsAsync.when(
                    data: (medications) => _buildTabletList(medications),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => _buildErrorWidget(error),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Pane: Detail View
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16 + (isOffline ? 40 : 0)),
                Expanded(
                  child: medicationsAsync.when(
                    data: (medications) {
                      if (medications.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final validIndex = _selectedIndex < medications.length ? _selectedIndex : 0;
                      return Padding(
                        padding: EdgeInsets.only(bottom: ResponsiveUtils.bottomNavPadding(context) + 16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 560),
                          child: MedicationVerticalCard(
                            medication: medications[validIndex],
                            onTaken: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Marked as taken!'),
                                backgroundColor: AppColors.primary,
                              ),
                            ),
                            onSkip: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Dose skipped.'),
                                backgroundColor: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletList(List<Medication> medications) {
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
      padding: EdgeInsets.only(bottom: ResponsiveUtils.bottomNavPadding(context) + 16),
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final isSelected = index == _selectedIndex;
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              border: isSelected ? Border.all(color: AppColors.primary, width: 2) : Border.all(color: Colors.transparent, width: 2),
            ),
            child: MedicationTaskCard(medication: medications[index]),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, {bool isTablet = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.go(AppRoutes.home),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF00695C),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          Text(
            'My Medications',
            style: GoogleFonts.lexend(
              fontSize: 18 * ResponsiveUtils.textScaleFactor(context),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          GestureDetector(
            onTap: () => context.push(AppRoutes.medicationScan),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFilterTabs(MedicationFilter selectedFilter) {
    final medicationsAsync = ref.watch(medicationsProvider);
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : 20),
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
                  _resetSelection();
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
                            horizontal: 4, vertical: 0),
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

  Widget _buildPagedCards(List<Medication> medications) {
    if (medications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No medications found',
              style: GoogleFonts.lexend(
                  fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: medications.length,
      onPageChanged: (index) {
        setState(() => _selectedIndex = index);
      },
      itemBuilder: (context, index) {
        final medication = medications[index];
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            ResponsiveUtils.bottomNavPadding(context) + 16,
          ),
          child: MedicationVerticalCard(
            medication: medication,
            onTaken: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Marked as taken!'),
                backgroundColor: AppColors.primary,
              ),
            ),
            onSkip: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dose skipped.'),
                backgroundColor: Color(0xFF6B7280),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Unable to load medication data',
              style: GoogleFonts.lexend(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
