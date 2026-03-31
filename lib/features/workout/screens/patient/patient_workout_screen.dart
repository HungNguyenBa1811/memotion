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
/// Displays one large vertical card per workout task in a horizontal PageView (slideshow).
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
            // Header + Title + Calendar (constrained width on tablet)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet
                    ? ResponsiveUtils.horizontalPadding(context)
                    : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  _buildTitleSection(context),
                  const SizedBox(height: 16),
                  CalendarDayPicker(
                    days: _calendarDays,
                    scale: calendarScale,
                    selectedIndex: _selectedDayIndex,
                    onDaySelected: (index) {
                      setState(() => _selectedDayIndex = index);
                      _resetSelection();
                      ref
                          .read(workoutListProvider.notifier)
                          .selectDate(_calendarDays[index].date);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: isTablet ? 40 * calendarScale : 20),
            // PageView slideshow — same on both mobile and tablet
            Expanded(
              child: _buildContent(
                context, 
                workoutState, 
                cardScale: cardScale
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isTabletMode = ResponsiveUtils.isTabletOrLarger(context);
    final iconSize = isTabletMode ? 32.0 : 24.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 16,
        horizontal: isTabletMode ? 0 : 20,
      ),
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

  Widget _buildTitleSection(BuildContext context) {
    final textScale = ResponsiveUtils.textScaleFactor(context);
    final isTabletMode = ResponsiveUtils.isTabletOrLarger(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTabletMode ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Tasks',
            style: GoogleFonts.lexend(
              fontSize: 24 * textScale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF070707),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Your workout plan',
            style: GoogleFonts.lexend(
              fontSize: 14 * textScale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF070707).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WorkoutListState workoutState, {required double cardScale}) {
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
            const Icon(Icons.event_available_outlined,
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

    return _buildPagedCards(context, workoutState.workouts, cardScale: cardScale);
  }

  Widget _buildPagedCards(BuildContext context, List<WorkoutTask> workouts, {required double cardScale}) {
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
            ResponsiveUtils.bottomNavPadding(context) + 20,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 650 * cardScale),
              child: WorkoutVerticalCard(
                workout: workout,
                scale: cardScale,
                onStart: () => context.push(
                  '/workout-detail',
                  extra: {'workoutId': workout.id},
                ),
              ),
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
