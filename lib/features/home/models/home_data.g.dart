// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpcomingMedicationImpl _$$UpcomingMedicationImplFromJson(
  Map<String, dynamic> json,
) => _$UpcomingMedicationImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  dosage: json['dosage'] as String,
  time: json['time'] as String,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$$UpcomingMedicationImplToJson(
  _$UpcomingMedicationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'dosage': instance.dosage,
  'time': instance.time,
  'imageUrl': instance.imageUrl,
};

_$HealthVitalsImpl _$$HealthVitalsImplFromJson(Map<String, dynamic> json) =>
    _$HealthVitalsImpl(
      heartRate: json['heartRate'] as String,
      bloodPressure: json['bloodPressure'] as String,
      steps: json['steps'] as String,
      temperature: json['temperature'] as String?,
      bloodSugar: json['bloodSugar'] as String?,
    );

Map<String, dynamic> _$$HealthVitalsImplToJson(_$HealthVitalsImpl instance) =>
    <String, dynamic>{
      'heartRate': instance.heartRate,
      'bloodPressure': instance.bloodPressure,
      'steps': instance.steps,
      'temperature': instance.temperature,
      'bloodSugar': instance.bloodSugar,
    };

_$HomeDashboardDataImpl _$$HomeDashboardDataImplFromJson(
  Map<String, dynamic> json,
) => _$HomeDashboardDataImpl(
  userName: json['userName'] as String,
  greeting: json['greeting'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  upcomingMedication: json['upcomingMedication'] == null
      ? null
      : UpcomingMedication.fromJson(
          json['upcomingMedication'] as Map<String, dynamic>,
        ),
  healthVitals: json['healthVitals'] == null
      ? null
      : HealthVitals.fromJson(json['healthVitals'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$HomeDashboardDataImplToJson(
  _$HomeDashboardDataImpl instance,
) => <String, dynamic>{
  'userName': instance.userName,
  'greeting': instance.greeting,
  'avatarUrl': instance.avatarUrl,
  'upcomingMedication': instance.upcomingMedication,
  'healthVitals': instance.healthVitals,
};
