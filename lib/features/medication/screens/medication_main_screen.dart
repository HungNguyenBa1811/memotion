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
import '../data/medication_cache_store.dart';
import '../data/medication_sync_service.dart';
import '../../workout/widgets/calendar_day_picker.dart';
import '../../workout/models/workout_model.dart';

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
  int _selectedIndex = 0;
  bool _showDebug = false;
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

  void _resetSelection() {
    setState(() {
      _selectedIndex = 0;
    });
  }

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
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.contentMaxWidth(context),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.horizontalPadding(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                medicationsAsync.when(
                  data: (medications) => _buildMedicationList(medications),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => _buildErrorWidget(error),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => setState(() => _showDebug = !_showDebug),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _showDebug ? Icons.bug_report : Icons.bug_report_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showDebug ? 'Hide Debug' : 'Show Debug',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showDebug) ...[
                  const SizedBox(height: 12),
                  _buildDebugSection(context),
                ],
                SizedBox(height: ResponsiveUtils.bottomNavPadding(context) * 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(
    AsyncValue<List<Medication>> medicationsAsync,
    DateTime selectedDate,
    MedicationFilter selectedFilter,
    bool isOffline
  ) {
    final hPad = ResponsiveUtils.horizontalPadding(context);
    final isLarge = ResponsiveUtils.isLargeTablet(context);
    final scale = isLarge ? 2.3 : 2.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          if (isOffline) _buildOfflineBanner(),
          CalendarDayPicker(
            days: _calendarDays,
            scale: scale,
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
              data: (medications) => _buildMedicationList(medications, isTablet: true),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorWidget(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textScale = ResponsiveUtils.textScaleFactor(context);
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final isLarge = ResponsiveUtils.isLargeTablet(context);
    final fontScale = isLarge ? 2.3 : isTablet ? 2.0 : 1.0;
    final qrBoxSize = isLarge ? 92.0 : isTablet ? 80.0 : 40.0;
    final qrIconSize = isLarge ? 46.0 : isTablet ? 40.0 : 20.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
          Expanded(
            child: Center(
              child: Text(
                'Medications Schedule',
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


  Widget _buildFilterTabs(MedicationFilter selectedFilter) {
    final medicationsAsync = ref.watch(medicationsProvider);
    final isLarge = ResponsiveUtils.isLargeTablet(context);
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final tabHeight = isLarge ? 128.0 : isTablet ? 112.0 : 56.0;
    final fontScale = isLarge ? 2.3 : isTablet ? 2.0 : 1.0;

    return Container(
      height: tabHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * fontScale),
      ),
      child: Row(
        children: MedicationFilter.values.map((filter) {
          final isSelected = filter == selectedFilter;
          final count = medicationsAsync.whenOrNull(
            data: (meds) {
              switch (filter) {
                case MedicationFilter.all:
                  return meds.length;
                case MedicationFilter.taken:
                  return meds.where((m) => m.status == MedicationStatus.taken).length;
                case MedicationFilter.missed:
                  return meds.where((m) => m.status == MedicationStatus.missed).length;
              }
            },
          ) ?? 0;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(selectedFilterProvider.notifier).state = filter;
                _resetSelection();
              },
              child: Container(
                margin: EdgeInsets.all(8 * fontScale),
                padding: EdgeInsets.symmetric(vertical: 4 * fontScale),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12 * fontScale),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      filter.displayText,
                      style: GoogleFonts.lexend(
                        fontSize: 14 * fontScale,
                        color: isSelected ? Colors.white : const Color(0xFF353535),
                      ),
                    ),
                    SizedBox(width: 4 * fontScale),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4 * fontScale,
                        vertical: 0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0B2455) : const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(8 * fontScale),
                      ),
                      child: Text(
                        count.toString(),
                        style: GoogleFonts.lexend(
                          fontSize: 14 * fontScale,
                          color: isSelected ? Colors.white : const Color(0xFF353535),
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

  Widget _buildMedicationList(List<Medication> medications, {bool isTablet = false}) {
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

    if (isTablet) {
      final isLarge = ResponsiveUtils.isLargeTablet(context);
      final scale = isLarge ? 2.3 : 2.0;

      return ListView.builder(
        padding: EdgeInsets.only(bottom: ResponsiveUtils.bottomNavPadding(context) + 40),       
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedIndex;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = index);
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 12 * scale),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27 * scale),
                border: isSelected ? Border.all(color: AppColors.primary, width: 2 * scale) : Border.all(color: Colors.transparent, width: 2 * scale),
              ),
              child: MedicationTaskCard(medication: medications[index], scale: scale),
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: medications.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MedicationTaskCard(medication: medications[index]),
          );
        },
      );
    }
  }


  Widget _buildDebugSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Debug Tools',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          // Row 1: Clear Cache + Reload Cache
          Row(
            children: [
              Expanded(
                child: _debugButton(
                  icon: Icons.delete_outline,
                  label: 'Clear Cache',
                  color: Colors.red.shade400,
                  onTap: () async {
                    await MedicationCacheStore().clear();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cache cleared')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _debugButton(
                  icon: Icons.refresh,
                  label: 'Reload Cache',
                  color: AppColors.primary,
                  onTap: () async {
                    ref.invalidate(medicationsProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cache reloaded from API')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Schedule alarm buttons
          Text(
            'Schedule Test Alarm',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [1, 2, 3, 5, 10].map((minutes) {
              return _debugButton(
                icon: Icons.alarm_add,
                label: '${minutes}m',
                color: Colors.orange.shade600,
                onTap: () => _scheduleQuickAlarm(context, minutes),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _debugButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scheduleQuickAlarm(BuildContext context, int minutes) async {
    final dueDate = DateTime.now().add(Duration(minutes: minutes));
    // ignore: deprecated_member_use
    await MedicationScheduler.syncTasks({
      'code': '200',
      'data': [
        {
          'task_id': 'test-${dueDate.millisecondsSinceEpoch}',
          'task_duedate': dueDate.toIso8601String(),
          'medication_detail': {
            'name': 'Test Vitamin D3',
            'dosage': '1 viên',
            'notes': 'Test alarm — $minutes min delay',
            'image_path': null,
          },
        },
      ],
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alarm scheduled: $minutes min from now')),
      );
    }
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
