import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_data.freezed.dart';
part 'home_data.g.dart';

/// Model for upcoming medication data
@freezed
class UpcomingMedication with _$UpcomingMedication {
  const factory UpcomingMedication({
    required String id,
    required String name,
    required String dosage,
    required String time,
    String? imageUrl,
  }) = _UpcomingMedication;

  factory UpcomingMedication.fromJson(Map<String, dynamic> json) =>
      _$UpcomingMedicationFromJson(json);
}

/// Model for health vitals data
@freezed
class HealthVitals with _$HealthVitals {
  const factory HealthVitals({
    required String heartRate,
    required String bloodPressure,
    required String steps,
    String? temperature,
    String? bloodSugar,
  }) = _HealthVitals;

  factory HealthVitals.fromJson(Map<String, dynamic> json) =>
      _$HealthVitalsFromJson(json);
}

/// Model for home dashboard data
@freezed
class HomeDashboardData with _$HomeDashboardData {
  const factory HomeDashboardData({
    required String userName,
    required String greeting,
    String? avatarUrl,
    UpcomingMedication? upcomingMedication,
    HealthVitals? healthVitals,
  }) = _HomeDashboardData;

  factory HomeDashboardData.fromJson(Map<String, dynamic> json) =>
      _$HomeDashboardDataFromJson(json);
}
