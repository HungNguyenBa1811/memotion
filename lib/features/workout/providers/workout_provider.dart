import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../data/workout_repository.dart';
import '../data/api_workout_repository.dart';
import '../models/workout_model.dart';

/// Provider for the workout repository
/// Using real API implementation
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return ApiWorkoutRepository();
});

/// State class for workout list
class WorkoutListState {
  final List<WorkoutTask> workouts;
  final bool isLoading;
  final String? error;
  final DateTime selectedDate;
  final bool isPatientProfileNotFound;

  const WorkoutListState({
    this.workouts = const [],
    this.isLoading = false,
    this.error,
    DateTime? selectedDate,
    this.isPatientProfileNotFound = false,
  }) : selectedDate = selectedDate ?? const _DefaultDate();

  WorkoutListState copyWith({
    List<WorkoutTask>? workouts,
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
    bool? isPatientProfileNotFound,
  }) {
    return WorkoutListState(
      workouts: workouts ?? this.workouts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
      isPatientProfileNotFound:
          isPatientProfileNotFound ?? this.isPatientProfileNotFound,
    );
  }
}

// Helper class for default date
class _DefaultDate implements DateTime {
  const _DefaultDate();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return DateTime.now().noSuchMethod(invocation);
  }

  @override
  int get day => DateTime.now().day;

  @override
  int get month => DateTime.now().month;

  @override
  int get year => DateTime.now().year;

  @override
  int get weekday => DateTime.now().weekday;

  @override
  DateTime add(Duration duration) => DateTime.now().add(duration);

  @override
  DateTime subtract(Duration duration) => DateTime.now().subtract(duration);

  @override
  bool isAfter(DateTime other) => DateTime.now().isAfter(other);

  @override
  bool isBefore(DateTime other) => DateTime.now().isBefore(other);

  @override
  bool isAtSameMomentAs(DateTime other) =>
      DateTime.now().isAtSameMomentAs(other);

  @override
  int compareTo(DateTime other) => DateTime.now().compareTo(other);

  @override
  int get millisecondsSinceEpoch => DateTime.now().millisecondsSinceEpoch;

  @override
  int get microsecondsSinceEpoch => DateTime.now().microsecondsSinceEpoch;

  @override
  String toIso8601String() => DateTime.now().toIso8601String();

  @override
  String toString() => DateTime.now().toString();
}

/// Notifier for managing workout list state
class WorkoutListNotifier extends StateNotifier<WorkoutListState> {
  final WorkoutRepository _repository;

  WorkoutListNotifier(this._repository, {bool autoLoad = true})
    : super(const WorkoutListState()) {
    if (autoLoad) loadWorkoutsForDate(DateTime.now());
  }

  /// Load workouts for a specific date
  Future<void> loadWorkoutsForDate(DateTime date) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedDate: date,
      isPatientProfileNotFound: false,
    );

    try {
      final workouts = await _repository.getWorkoutsByDate(date);
      state = state.copyWith(
        workouts: workouts,
        isLoading: false,
        selectedDate: date,
        isPatientProfileNotFound: false,
      );
    } on PatientProfileNotFoundException catch (e) {
      // Handle patient profile not found - show friendly message
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        isPatientProfileNotFound: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'We could not load the exercise plan. Please try again.',
        isPatientProfileNotFound: false,
      );
    }
  }

  /// Mark a workout as completed
  Future<void> markCompleted(String workoutId) async {
    try {
      await _repository.markWorkoutCompleted(workoutId);
      // Reload the list
      await loadWorkoutsForDate(state.selectedDate);
    } catch (e) {
      state = state.copyWith(
        error: 'We could not update this exercise. Please try again.',
        isPatientProfileNotFound: false,
      );
    }
  }

  /// Change selected date
  void selectDate(DateTime date) {
    loadWorkoutsForDate(date);
  }
}

/// Provider for workout list state
final workoutListProvider =
    StateNotifierProvider<WorkoutListNotifier, WorkoutListState>((ref) {
      final authState = ref.watch(authProvider);
      final repository = ref.watch(workoutRepositoryProvider);
      return WorkoutListNotifier(
        repository,
        autoLoad: authState.status == AuthStatus.authenticated,
      );
    });

/// State class for workout detail
class WorkoutDetailState {
  final WorkoutTask? workout;
  final bool isLoading;
  final String? error;

  const WorkoutDetailState({this.workout, this.isLoading = false, this.error});

  WorkoutDetailState copyWith({
    WorkoutTask? workout,
    bool? isLoading,
    String? error,
  }) {
    return WorkoutDetailState(
      workout: workout ?? this.workout,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing workout detail state
class WorkoutDetailNotifier extends StateNotifier<WorkoutDetailState> {
  final WorkoutRepository _repository;

  WorkoutDetailNotifier(this._repository) : super(const WorkoutDetailState());

  /// Load workout detail by ID
  Future<void> loadWorkout(String workoutId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final workout = await _repository.getWorkoutById(workoutId);
      if (workout != null) {
        state = state.copyWith(workout: workout, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'We could not find this exercise.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'We could not load this exercise. Please try again.',
      );
    }
  }

  /// Mark workout as completed
  Future<void> markCompleted() async {
    if (state.workout == null) return;

    try {
      await _repository.markWorkoutCompleted(state.workout!.id);
      state = state.copyWith(
        workout: state.workout!.copyWith(isCompleted: true),
      );
    } catch (e) {
      state = state.copyWith(
        error: 'We could not update this exercise. Please try again.',
      );
    }
  }
}

/// Provider for workout detail state
final workoutDetailProvider =
    StateNotifierProvider<WorkoutDetailNotifier, WorkoutDetailState>((ref) {
      final repository = ref.watch(workoutRepositoryProvider);
      return WorkoutDetailNotifier(repository);
    });

/// Provider for calendar days (5 days centered on today)
final calendarDaysProvider = Provider<List<CalendarDay>>((ref) {
  final now = DateTime.now();
  final days = <CalendarDay>[];

  // Generate 5 days: 2 before today, today, 2 after today
  for (int i = -2; i <= 2; i++) {
    final date = now.add(Duration(days: i));
    days.add(
      CalendarDay(
        date: date,
        dayOfWeek: _getDayOfWeek(date.weekday),
        month: _getMonth(date.month),
        isSelected: i == 0, // Today is selected by default
      ),
    );
  }

  return days;
});

/// Helper function to get day of week abbreviation
String _getDayOfWeek(int weekday) {
  switch (weekday) {
    case 1:
      return 'Mon';
    case 2:
      return 'Tue';
    case 3:
      return 'Wed';
    case 4:
      return 'Thu';
    case 5:
      return 'Fri';
    case 6:
      return 'Sat';
    case 7:
      return 'Sun';
    default:
      return '';
  }
}

/// Helper function to get month abbreviation
String _getMonth(int month) {
  switch (month) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Aug';
    case 9:
      return 'Sep';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
    default:
      return '';
  }
}
