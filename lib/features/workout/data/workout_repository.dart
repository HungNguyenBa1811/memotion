import '../models/workout_model.dart';

/// Abstract repository interface for workout data
/// This allows for easy swapping between fake and real API implementations
abstract class WorkoutRepository {
  /// Get all workout tasks for a specific date
  Future<List<WorkoutTask>> getWorkoutsByDate(DateTime date);

  /// Get a single workout task by ID
  Future<WorkoutTask?> getWorkoutById(String id);

  /// Get workout tasks for a user
  Future<List<WorkoutTask>> getWorkoutsForUser(String userId);

  /// Mark a workout as completed
  Future<bool> markWorkoutCompleted(String workoutId);

  /// Create a new workout task
  Future<WorkoutTask> createWorkout(WorkoutTask workout);

  /// Update an existing workout task
  Future<WorkoutTask> updateWorkout(WorkoutTask workout);

  /// Delete a workout task
  Future<bool> deleteWorkout(String workoutId);
}

/// Fake implementation of WorkoutRepository for development/testing
/// TODO: Replace with real API implementation later
class FakeWorkoutRepository implements WorkoutRepository {
  // Simulated network delay
  final Duration _networkDelay = const Duration(milliseconds: 500);

  // Fake data store
  final List<WorkoutTask> _fakeWorkouts = [
    WorkoutTask(
      id: '1',
      title: 'Gentle Yoga',
      time: '10:00 AM',
      scheduledDate: DateTime.now(),
      type: WorkoutType.yoga,
      imageAsset: 'assets/images/yoga_pose.png',
      description:
          'A gentle yoga session to support relaxation and emotional well-being.',
      steps: [
        'Warm up with gentle stretches',
        'Move through basic yoga poses at a comfortable pace',
        'Focus on steady breathing',
        'Finish with a short relaxation',
      ],
      durationMinutes: 30,
      caloriesBurn: 95,
    ),
    WorkoutTask(
      id: '2',
      title: 'Lunch',
      time: '12:30 PM',
      scheduledDate: DateTime.now(),
      type: WorkoutType.meal,
      description: 'A balanced lunch with vegetables and protein.',
      steps: [
        'Prepare fresh ingredients',
        'Follow the healthy recipe',
        'Eat slowly and enjoy your meal',
      ],
      durationMinutes: 45,
      caloriesBurn: 0,
    ),
    WorkoutTask(
      id: '3',
      title: 'Take Medication',
      time: '4:50 PM',
      scheduledDate: DateTime.now(),
      type: WorkoutType.medicine,
      description: 'Take your medication as directed by your doctor.',
      steps: [
        'Check the medication and dose',
        'Take it with water',
        'Record the time it was taken',
      ],
      durationMinutes: 5,
      caloriesBurn: 0,
    ),
    // Yesterday's workouts
    WorkoutTask(
      id: '4',
      title: 'Morning Walk',
      time: '7:00 AM',
      scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
      type: WorkoutType.exercise,
      isCompleted: true,
      description: 'Take a gentle walk in the park at a comfortable pace.',
      durationMinutes: 30,
      caloriesBurn: 120,
    ),
    // Tomorrow's workouts
    WorkoutTask(
      id: '5',
      title: 'Health Checkup',
      time: '9:00 AM',
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      type: WorkoutType.other,
      description: 'Attend your routine health checkup at the clinic.',
      durationMinutes: 60,
      caloriesBurn: 0,
    ),
  ];

  @override
  Future<List<WorkoutTask>> getWorkoutsByDate(DateTime date) async {
    await Future.delayed(_networkDelay);

    return _fakeWorkouts.where((workout) {
      return workout.scheduledDate.year == date.year &&
          workout.scheduledDate.month == date.month &&
          workout.scheduledDate.day == date.day;
    }).toList();
  }

  @override
  Future<WorkoutTask?> getWorkoutById(String id) async {
    await Future.delayed(_networkDelay);

    try {
      return _fakeWorkouts.firstWhere((workout) => workout.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<WorkoutTask>> getWorkoutsForUser(String userId) async {
    await Future.delayed(_networkDelay);
    // In a real implementation, filter by userId
    return _fakeWorkouts;
  }

  @override
  Future<bool> markWorkoutCompleted(String workoutId) async {
    await Future.delayed(_networkDelay);

    final index = _fakeWorkouts.indexWhere((w) => w.id == workoutId);
    if (index != -1) {
      _fakeWorkouts[index] = _fakeWorkouts[index].copyWith(isCompleted: true);
      return true;
    }
    return false;
  }

  @override
  Future<WorkoutTask> createWorkout(WorkoutTask workout) async {
    await Future.delayed(_networkDelay);

    final newWorkout = workout.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _fakeWorkouts.add(newWorkout);
    return newWorkout;
  }

  @override
  Future<WorkoutTask> updateWorkout(WorkoutTask workout) async {
    await Future.delayed(_networkDelay);

    final index = _fakeWorkouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      _fakeWorkouts[index] = workout;
      return workout;
    }
    throw Exception('Workout not found');
  }

  @override
  Future<bool> deleteWorkout(String workoutId) async {
    await Future.delayed(_networkDelay);

    final index = _fakeWorkouts.indexWhere((w) => w.id == workoutId);
    if (index != -1) {
      _fakeWorkouts.removeAt(index);
      return true;
    }
    return false;
  }
}
