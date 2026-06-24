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
      title: 'Tập Yoga',
      time: '10:00 AM',
      scheduledDate: DateTime.now(),
      type: WorkoutType.yoga,
      imageAsset: 'assets/images/yoga_pose.png',
      description:
          'Buổi tập yoga giúp thư giãn và cải thiện sức khỏe tinh thần.',
      steps: [
        'Khởi động với các động tác căng cơ nhẹ',
        'Thực hiện các tư thế yoga cơ bản',
        'Tập trung vào hơi thở và thiền định',
        'Kết thúc với các động tác thư giãn',
      ],
      durationMinutes: 30,
      caloriesBurn: 95,
    ),
    WorkoutTask(
      id: '2',
      title: 'Ăn trưa',
      time: '12:30 PM',
      scheduledDate: DateTime.now(),
      type: WorkoutType.meal,
      description: 'Bữa trưa đầy đủ dinh dưỡng với rau xanh và protein.',
      steps: [
        'Chuẩn bị nguyên liệu tươi ngon',
        'Nấu ăn theo công thức sức khỏe',
        'Ăn chậm và thưởng thức',
      ],
      durationMinutes: 45,
      caloriesBurn: 0,
    ),
    WorkoutTask(
      id: '3',
      title: 'Uống thuốc',
      time: '16:50 PM',
      scheduledDate: DateTime.now(),
      type: WorkoutType.medicine,
      description: 'Uống thuốc theo chỉ định của bác sĩ.',
      steps: [
        'Kiểm tra liều lượng thuốc',
        'Uống thuốc với nước',
        'Ghi nhận thời gian uống thuốc',
      ],
      durationMinutes: 5,
      caloriesBurn: 0,
    ),
    // Yesterday's workouts
    WorkoutTask(
      id: '4',
      title: 'Đi bộ buổi sáng',
      time: '07:00 AM',
      scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
      type: WorkoutType.exercise,
      isCompleted: true,
      description: 'Đi bộ nhẹ nhàng trong công viên.',
      durationMinutes: 30,
      caloriesBurn: 120,
    ),
    // Tomorrow's workouts
    WorkoutTask(
      id: '5',
      title: 'Khám sức khỏe',
      time: '09:00 AM',
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      type: WorkoutType.other,
      description: 'Khám sức khỏe định kỳ tại phòng khám.',
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
