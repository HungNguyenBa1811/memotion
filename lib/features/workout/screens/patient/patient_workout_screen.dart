import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../models/workout_model.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/calendar_day_picker.dart';
import '../../widgets/workout_vertical_card.dart';
import '../../widgets/workout_task_card.dart';

/// Workout screen for PATIENT (Elderly) role.
/// Displays one large vertical card per workout task in a PageView (Mobile)
/// or a Split-Pane Master-Detail layout (Tablet).
class PatientWorkoutScreenContent extends ConsumerStatefulWidget {
  const PatientWorkoutScreenContent({super.key});

  @override
  ConsumerState<PatientWorkoutScreenContent> createState() =>
      _PatientWorkoutScreenContentState();
}

class _PatientWorkoutScreenContentState
    extends ConsumerState<PatientWorkoutScreenContent> {
  final PageController _pageController = PageController();

  late int _selectedDayIndex;
  late List<CalendarDay> _calendarDays;
  int _selectedIndex = 0;

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
        dayOfWeek: _getDayOfWeek(date.weekday),
        month: _getMonthName(date.month),
        isSelected: i == offset,
      );
    });
    _selectedDayIndex = offset;
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutListProvider);
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: isTablet
            ? _buildTabletLayout(workoutState)
            : _buildMobileLayout(workoutState),
      ),
    );
  }

  Widget _buildMobileLayout(WorkoutListState workoutState) {
    return Column(
      children: [
        _buildHeader(context),
        const SizedBox(height: 12),
        CalendarDayPicker(
          days: _calendarDays,
          selectedIndex: _selectedDayIndex,
          onDaySelected: (index) {
            setState(() => _selectedDayIndex = index);
            _resetSelection();
            ref
                .read(workoutListProvider.notifier)
                .selectDate(_calendarDays[index].date);
          },
        ),
        const SizedBox(height: 20),
        Expanded(child: _buildContent(context, workoutState, isTablet: false)),
      ],
    );
  }

  Widget _buildTabletLayout(WorkoutListState workoutState) {
    final hPad = ResponsiveUtils.horizontalPadding(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Pane: Master List
          Expanded(
            flex: 4,
            child: Column(
              children: [
                _buildHeader(context, isTablet: true),
                const SizedBox(height: 12),
                CalendarDayPicker(
                  days: _calendarDays,
                  selectedIndex: _selectedDayIndex,
                  onDaySelected: (index) {
                    setState(() => _selectedDayIndex = index);
                    _resetSelection();
                    ref
                        .read(workoutListProvider.notifier)
                        .selectDate(_calendarDays[index].date);
                  },
                ),
                const SizedBox(height: 20),
                Expanded(child: _buildContent(context, workoutState, isTablet: true)),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Right Pane: Detail View
          Expanded(
            flex: 6,
            child: Column(
              children: [
                const SizedBox(height: 32), // Top spacing alignment
                Expanded(
                  child: workoutState.isLoading || workoutState.error != null || workoutState.workouts.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(bottom: ResponsiveUtils.bottomNavPadding(context) + 16),
                          child: WorkoutVerticalCard(
                            workout: workoutState.workouts[
                                _selectedIndex < workoutState.workouts.length ? _selectedIndex : 0],
                            onStart: () => context.push(
                              '/workout-detail',
                              extra: {
                                'workoutId': workoutState.workouts[
                                    _selectedIndex < workoutState.workouts.length ? _selectedIndex : 0].id
                              },
                            ),
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

  Widget _buildHeader(BuildContext context, {bool isTablet = false}) {
    final textScale = ResponsiveUtils.textScaleFactor(context);
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
                child: Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                'Daily Tasks',
                style: GoogleFonts.lexend(
                  fontSize: 18 * textScale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF070707),
                ),
              ),
              Text(
                'Your workout plan',
                style: GoogleFonts.lexend(
                  fontSize: 12 * textScale,
                  color: const Color(0xFF070707).withOpacity(0.5),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WorkoutListState workoutState, {required bool isTablet}) {
    if (workoutState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (workoutState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                workoutState.isPatientProfileNotFound
                    ? Icons.person_off
                    : Icons.error_outline,
                size: 64,
                color: workoutState.isPatientProfileNotFound
                    ? AppColors.primary
                    : Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                workoutState.isPatientProfileNotFound
                    ? 'No patient profile yet'
                    : 'Unable to load tasks',
                style: GoogleFonts.lexend(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                workoutState.isPatientProfileNotFound
                    ? 'Please contact your doctor to set up your workout plan.'
                    : workoutState.error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                    fontSize: 14, color: Colors.grey[600]),
              ),
              if (!workoutState.isPatientProfileNotFound) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref
                      .read(workoutListProvider.notifier)
                      .loadWorkoutsForDate(workoutState.selectedDate),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Try again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (workoutState.workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_outlined,
                size: 72, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No tasks for this day',
              style: GoogleFonts.lexend(
                  fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Stay active!',
              style: GoogleFonts.lexend(
                  fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return isTablet
        ? _buildTabletList(workoutState.workouts)
        : _buildPagedCards(context, workoutState.workouts);
  }

  Widget _buildTabletList(List<WorkoutTask> workouts) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.bottomNavPadding(context) + 16),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final isSelected = index == _selectedIndex;
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
            ),
            child: WorkoutTaskCard(
              workout: workouts[index],
              onTap: () => setState(() => _selectedIndex = index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPagedCards(
      BuildContext context, List<WorkoutTask> workouts) {
    return PageView.builder(
      controller: _pageController,
      itemCount: workouts.length,
      onPageChanged: (index) {
        setState(() => _selectedIndex = index);
      },
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            ResponsiveUtils.bottomNavPadding(context) + 16,
          ),
          child: WorkoutVerticalCard(
            workout: workout,
            onStart: () => context.push(
              '/workout-detail',
              extra: {'workoutId': workout.id},
            ),
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  String _getDayOfWeek(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
