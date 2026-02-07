class HealthData {
  final int steps;
  final int heartRate;
  final double calories;

  const HealthData({
    this.steps = 0,
    this.heartRate = 0,
    this.calories = 0,
  });

  HealthData copyWith({
    int? steps,
    int? heartRate,
    double? calories,
  }) {
    return HealthData(
      steps: steps ?? this.steps,
      heartRate: heartRate ?? this.heartRate,
      calories: calories ?? this.calories,
    );
  }
}
