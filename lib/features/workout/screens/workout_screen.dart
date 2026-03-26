import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../models/workout_model.dart';
import '../providers/workout_provider.dart';
import '../widgets/calendar_day_picker.dart';
import '../widgets/workout_task_card.dart';
import '../../../features/profile/providers/profile_provider.dart';
import 'patient/patient_workout_screen.dart';

/// Role-aware entry point: CARETAKER → WorkoutScreenContent, PATIENT → PatientWorkoutScreenContent
class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileViewModel = ref.watch(profileViewModelProvider);

    if (profileViewModel.isLoadingUserDetails) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final role =
        profileViewModel.userDetails?.role.toUpperCase() ?? 'PATIENT';

    if (role == 'CARETAKER') {
      return const WorkoutScreenContent();
    } else {
      return const PatientWorkoutScreenContent();
    }
  }
}

/// Content version without bottom nav - used inside MainShell
class WorkoutScreenContent extends ConsumerStatefulWidget {
  const WorkoutScreenContent({super.key});

  @override
  ConsumerState<WorkoutScreenContent> createState() =>
      _WorkoutScreenContentState();
}

class _WorkoutScreenContentState extends ConsumerState<WorkoutScreenContent> {
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
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Title section
            _buildTitleSection(),

            const SizedBox(height: 16),

            // Date selector
            CalendarDayPicker(
              days: _calendarDays,
              selectedIndex: _selectedDayIndex,
              onDaySelected: (index) {
                setState(() => _selectedDayIndex = index);
                ref
                    .read(workoutListProvider.notifier)
                    .selectDate(_calendarDays[index].date);
              },
            ),

            const SizedBox(height: 30),

            // Task list fills remaining space
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
                  top: 0,
                  right: 0,
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

  Widget _buildTitleSection() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.horizontalPadding(context),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Tasks',
              style: GoogleFonts.lexend(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF070707),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Patient Name',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF070707).withOpacity(0.7),
              ),
            ),
          ],
        ),
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
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                workoutState.isPatientProfileNotFound
                    ? Icons.person_off
                    : Icons.error_outline,
                size: 48,
                color: workoutState.isPatientProfileNotFound
                    ? AppColors.primary
                    : AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                workoutState.isPatientProfileNotFound
                    ? 'No patient profile yet'
                    : 'Unable to load data',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                workoutState.isPatientProfileNotFound
                    ? 'Please contact your doctor to create a patient profile and receive a workout plan.'
                    : workoutState.error!,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (!workoutState.isPatientProfileNotFound) ...[
                const SizedBox(height: 16),
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
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No tasks available',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Stay active',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildTaskList(context, workoutState.workouts);
  }

  Widget _buildTaskList(BuildContext context, List<WorkoutTask> workouts) {
    final hPad = ResponsiveUtils.horizontalPadding(context);
    final bottomPad = ResponsiveUtils.bottomNavPadding(context) + 16;
    final cols = ResponsiveUtils.listColumns(context);

    if (cols > 1) {
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(hPad, 0, hPad, bottomPad),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.6,
        ),
        itemCount: workouts.length,
        itemBuilder: (context, index) => WorkoutTaskCard(
          workout: workouts[index],
          onTap: () => context.push(
            '/workout-detail',
            extra: {'workoutId': workouts[index].id},
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, bottomPad),
      itemCount: workouts.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 17),
        child: WorkoutTaskCard(
          workout: workouts[index],
          onTap: () => context.push(
            '/workout-detail',
            extra: {'workoutId': workouts[index].id},
          ),
        ),
      ),
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
