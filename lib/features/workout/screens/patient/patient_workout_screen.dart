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

/// Workout screen for PATIENT (Elderly) role.
/// Displays one large vertical card per workout task in a PageView.
class PatientWorkoutScreenContent extends ConsumerStatefulWidget {
  const PatientWorkoutScreenContent({super.key});

  @override
  ConsumerState<PatientWorkoutScreenContent> createState() =>
      _PatientWorkoutScreenContentState();
}

class _PatientWorkoutScreenContentState
    extends ConsumerState<PatientWorkoutScreenContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
        dayOfWeek: _getDayOfWeek(date.weekday),
        month: _getMonthName(date.month),
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

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            CalendarDayPicker(
              days: _calendarDays,
              selectedIndex: _selectedDayIndex,
              onDaySelected: (index) {
                setState(() {
                  _selectedDayIndex = index;
                  _currentPage = 0;
                });
                _pageController.jumpToPage(0);
                ref
                    .read(workoutListProvider.notifier)
                    .selectDate(_calendarDays[index].date);
              },
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildContent(context, workoutState)),
          ],
        ),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF070707),
                ),
              ),
              Text(
                'Your workout plan',
                style: GoogleFonts.lexend(
                  fontSize: 12,
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

  Widget _buildContent(BuildContext context, WorkoutListState workoutState) {
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

    return _buildPagedCards(context, workoutState.workouts);
  }

  Widget _buildPagedCards(
      BuildContext context, List<WorkoutTask> workouts) {
    return Column(
      children: [
        // Counter
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_currentPage + 1}',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                ' / ${workouts.length}',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),

        // PageView
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: workouts.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
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
          ),
        ),

        // Dot indicators
        if (workouts.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                workouts.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
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
