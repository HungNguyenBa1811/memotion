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
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final role = profileViewModel.userDetails?.role.toUpperCase() ?? 'PATIENT';

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
                _buildTitleSection(),
                const SizedBox(height: 16),
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
                _buildContent(context, workoutState, isTablet: false),
                SizedBox(
                  height: ResponsiveUtils.bottomNavPadding(context) * 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(WorkoutListState workoutState) {
    final hPad = ResponsiveUtils.horizontalPadding(context);
    final isLarge = ResponsiveUtils.isLargeTablet(context);
    final scale = isLarge ? 2.3 : 2.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, isTablet: true),
          _buildTitleSection(isTablet: true),
          const SizedBox(height: 16),
          CalendarDayPicker(
            days: _calendarDays,
            scale: scale,
            selectedIndex: _selectedDayIndex,
            onDaySelected: (index) {
              setState(() => _selectedDayIndex = index);
              ref
                  .read(workoutListProvider.notifier)
                  .selectDate(_calendarDays[index].date);
            },
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildContent(context, workoutState, isTablet: true)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {bool isTablet = false}) {
    final isTabletMode = ResponsiveUtils.isTabletOrLarger(context);
    final iconSize = isTabletMode ? 32.0 : 24.0;
    final textScale = ResponsiveUtils.textScaleFactor(context);

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
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: Stack(
              children: [
                Icon(
                  Icons.notifications,
                  color: AppColors.textPrimary,
                  size: iconSize,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
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

  Widget _buildTitleSection({bool isTablet = false}) {
    final isLarge = ResponsiveUtils.isLargeTablet(context);
    final isTabletMode = ResponsiveUtils.isTabletOrLarger(context);
    final fontScale = isLarge
        ? 2.3
        : isTabletMode
        ? 2.0
        : 1.0;

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Tasks',
            style: GoogleFonts.lexend(
              fontSize: 24 * fontScale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF070707),
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 2 * fontScale),
          Text(
            'Care Recipient',
            style: GoogleFonts.lexend(
              fontSize: 14 * fontScale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF070707).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WorkoutListState workoutState, {
    required bool isTablet,
  }) {
    if (workoutState.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
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
                    ? 'No care profile yet'
                    : 'We could not load the exercise plan',
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
                    ? 'Please ask the doctor or care team to create a care profile and exercise plan.'
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
                'No exercises scheduled for this day',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gentle movement supports well-being',
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

    return _buildTaskList(context, workoutState.workouts, isTablet: isTablet);
  }

  Widget _buildTaskList(
    BuildContext context,
    List<WorkoutTask> workouts, {
    required bool isTablet,
  }) {
    if (isTablet) {
      final isLarge = ResponsiveUtils.isLargeTablet(context);
      final scale = isLarge ? 2.3 : 2.0;

      return ListView.builder(
        padding: EdgeInsets.only(
          bottom: ResponsiveUtils.bottomNavPadding(context) * 20,
        ),
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 17 * scale),
            child: WorkoutTaskCard(
              workout: workouts[index],
              scale: scale,
              onTap: () => context.push(
                '/workout-detail',
                extra: {'workoutId': workouts[index].id},
              ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 17),
          child: WorkoutTaskCard(
            workout: workouts[index],
            onTap: () {
              context.push(
                '/workout-detail',
                extra: {'workoutId': workouts[index].id},
              );
            },
          ),
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

  String _getDayOfWeek(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
