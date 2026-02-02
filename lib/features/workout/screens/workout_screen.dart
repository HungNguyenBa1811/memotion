import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../providers/workout_provider.dart';
import '../widgets/calendar_day_picker.dart';
import '../widgets/workout_task_card.dart';

/// Original screen - kept for backwards compatibility
class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const WorkoutScreenContent();
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
  int _selectedDayIndex = 2; // Today is at index 2 (center of 5 days)

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutListProvider);
    final calendarDays = ref.watch(calendarDaysProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back and notification
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button - circular with teal color (matching nutrition)
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
                    // Notification icon
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
                          // Notification dot
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
              ),
              const SizedBox(height: 12),

              // Title section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 19),
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
              const SizedBox(height: 24),

              // Calendar day picker
              CalendarDayPicker(
                days: calendarDays,
                selectedIndex: _selectedDayIndex,
                onDaySelected: (index) {
                  setState(() {
                    _selectedDayIndex = index;
                  });
                  ref
                      .read(workoutListProvider.notifier)
                      .selectDate(calendarDays[index].date);
                },
              ),
              const SizedBox(height: 30),

              // Workout tasks list
              if (workoutState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (workoutState.error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
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
                )
              else if (workoutState.workouts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
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
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: workoutState.workouts.map((workout) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 17),
                        child: WorkoutTaskCard(
                          workout: workout,
                          onTap: () {
                            context.push(
                              '/workout-detail',
                              extra: {'workoutId': workout.id},
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}