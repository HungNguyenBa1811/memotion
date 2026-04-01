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
import '../../../workout/widgets/calendar_day_picker.dart';
import '../../../workout/models/workout_model.dart';
import '../../../voice_command/widgets/voice_command_fab.dart';

/// Medication screen for PATIENT (Elderly) role.
/// No filter tabs. Uses vertical card in a horizontal PageView (slideshow).
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
      return CalendarDay(
        date: date,
        dayOfWeek: '',
        month: '',
        isSelected: i == offset,
      );
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
    final medicationsAsync = ref.watch(
      filteredMedicationsProvider(MedicationFilter.all),
    );
    final selectedDate = ref.watch(selectedDateProvider);
    final isOffline = ref.watch(isOfflineProvider).valueOrNull ?? false;
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final isLarge = ResponsiveUtils.isLargeTablet(context);
    final calendarScale = isLarge ? 2.3 : isTablet ? 2.0 : 1.0;
    final cardScale = isLarge ? 1.5 : isTablet ? 1.3 : 1.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header + Calendar (constrained width on tablet)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.horizontalPadding(context),
              ),
              child: Column(
                children: [
                  _buildHeader(context),
                  if (isOffline) _buildOfflineBanner(),
                  CalendarDayPicker(
                    days: _calendarDays,
                    scale: calendarScale,
                    selectedIndex: _selectedDayIndex,
                    onDaySelected: (index) {
                      setState(() => _selectedDayIndex = index);
                      ref.read(selectedDateProvider.notifier).state =
                          _calendarDays[index].date;
                      _resetSelection();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: isTablet ? 40 * calendarScale : 4),
            // PageView slideshow — same on both mobile and tablet
            Expanded(
              child: medicationsAsync.when(
                data: (medications) =>
                    _buildPagedCards(medications, cardScale: cardScale),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => _buildErrorWidget(error),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const VoiceCommandFAB(),
    );
  }

  // ─── Header (synced with medication_main_screen.dart) ─────────────────────
  Widget _buildHeader(BuildContext context) {
    final textScale = ResponsiveUtils.textScaleFactor(context);
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final isLarge = ResponsiveUtils.isLargeTablet(context);
    final fontScale = isLarge ? 2.3 : isTablet ? 2.0 : 1.0;
    final qrBoxSize = isLarge ? 92.0 : isTablet ? 80.0 : 40.0;
    final qrIconSize = isLarge ? 46.0 : isTablet ? 40.0 : 20.0;
    final backBoxSize = isLarge ? 92.0 : isTablet ? 80.0 : 40.0;
    final backIconSize = isLarge ? 36.0 : isTablet ? 32.0 : 18.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.go(AppRoutes.home),
            child: Container(
              width: backBoxSize,
              height: backBoxSize,
              decoration: const BoxDecoration(
                color: Color(0xFF00695C),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: backIconSize,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'My Medications',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 18 * textScale * fontScale * 0.7,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.push(AppRoutes.medicationScan),
            child: Container(
              width: qrBoxSize,
              height: qrBoxSize,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.primary,
                  size: qrIconSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PageView Slideshow (shared for mobile & tablet) ──────────────────────
  Widget _buildPagedCards(List<Medication> medications,
      {double cardScale = 1.0}) {
    if (medications.isEmpty) {
      return _buildEmptyState();
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
            ResponsiveUtils.horizontalPadding(context),
            0,
            ResponsiveUtils.horizontalPadding(context),
            ResponsiveUtils.bottomNavPadding(context) + 20,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 650 * cardScale),
              child: MedicationVerticalCard(
                medication: medication,
                scale: cardScale,
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
          ),
        );
      },
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final isLarge = ResponsiveUtils.isLargeTablet(context);
    final scale = isLarge ? 2.3 : isTablet ? 2.0 : 1.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 64 * scale, color: Colors.grey[400]),
          SizedBox(height: 16 * scale),
          Text(
            'No medications found',
            style: GoogleFonts.lexend(fontSize: 16 * scale, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ─── Error Widget ─────────────────────────────────────────────────────────
  Widget _buildErrorWidget(Object error) {
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final isLarge = ResponsiveUtils.isLargeTablet(context);
    final scale = isLarge ? 2.3 : isTablet ? 2.0 : 1.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(20 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64 * scale, color: Colors.red.shade300),
            SizedBox(height: 16 * scale),
            Text(
              'Unable to load medication data',
              style: GoogleFonts.lexend(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(fontSize: 14 * scale, color: Colors.grey),
            ),
            SizedBox(height: 20 * scale),
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

  // ─── Offline Banner ───────────────────────────────────────────────────────
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
