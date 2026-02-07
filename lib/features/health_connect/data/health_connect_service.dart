import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/health_data.dart';

class HealthConnectService {
  final Health _health = Health();

  static final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  static final List<HealthDataAccess> _permissions =
      _types.map((_) => HealthDataAccess.READ).toList();

  /// Check Health Connect SDK status on this device.
  Future<HealthConnectSdkStatus?> getSdkStatus() async {
    try {
      final status = await _health.getHealthConnectSdkStatus();
      debugPrint('[HealthConnect] SDK status: $status');
      return status;
    } catch (e) {
      debugPrint('[HealthConnect] getSdkStatus error: $e');
      return null;
    }
  }

  /// Prompts user to install/update Health Connect from Play Store.
  Future<void> installHealthConnect() async {
    await _health.installHealthConnect();
  }

  Future<bool> requestAuthorization() async {
    try {
      // Step 1: Request ACTIVITY_RECOGNITION runtime permission first
      final activityStatus = await Permission.activityRecognition.request();
      debugPrint('[HealthConnect] ACTIVITY_RECOGNITION: $activityStatus');
      if (!activityStatus.isGranted) {
        debugPrint('[HealthConnect] ACTIVITY_RECOGNITION denied');
        return false;
      }

      // Step 2: Check Health Connect availability
      final status = await getSdkStatus();

      switch (status) {
        case HealthConnectSdkStatus.sdkAvailable:
          break; // good to go
        case HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired:
          debugPrint('[HealthConnect] Provider update required, prompting...');
          await installHealthConnect();
          return false;
        case HealthConnectSdkStatus.sdkUnavailable:
          debugPrint('[HealthConnect] Not installed, prompting install...');
          await installHealthConnect();
          return false;
        default:
          debugPrint('[HealthConnect] Unknown status: $status');
          return false;
      }

      // Step 3: Request Health Connect permissions
      final hasPerms = await _health.hasPermissions(_types, permissions: _permissions);
      debugPrint('[HealthConnect] Already has permissions: $hasPerms');

      if (hasPerms == true) return true;

      final granted = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      debugPrint('[HealthConnect] requestAuthorization result: $granted');
      return granted;
    } catch (e) {
      debugPrint('[HealthConnect] Authorization error: $e');
      return false;
    }
  }

  Future<HealthData> fetchHealthData() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      debugPrint('[HealthConnect] Time range: $startOfDay → $now');

      final dataPoints = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: startOfDay,
        endTime: now,
      );

      debugPrint('[HealthConnect] Raw data points: ${dataPoints.length}');
      for (final p in dataPoints) {
        debugPrint('[HealthConnect]   ${p.type} = ${p.value} (${p.dateFrom} → ${p.dateTo}) source: ${p.sourceName}');
      }

      // Remove duplicates
      final cleaned = _health.removeDuplicates(dataPoints);
      debugPrint('[HealthConnect] After dedup: ${cleaned.length}');

      int totalSteps = 0;
      double totalCalories = 0;
      int latestHeartRate = 0;
      DateTime? latestHrTime;

      for (final point in cleaned) {
        final numValue = (point.value as NumericHealthValue).numericValue;

        switch (point.type) {
          case HealthDataType.STEPS:
            totalSteps += numValue.toInt();
            break;
          case HealthDataType.ACTIVE_ENERGY_BURNED:
            totalCalories += numValue.toDouble();
            break;
          case HealthDataType.HEART_RATE:
            if (latestHrTime == null || point.dateFrom.isAfter(latestHrTime)) {
              latestHrTime = point.dateFrom;
              latestHeartRate = numValue.toInt();
            }
            break;
          default:
            break;
        }
      }

      debugPrint('[HealthConnect] Steps: $totalSteps');
      debugPrint('[HealthConnect] Heart Rate: $latestHeartRate bpm');
      debugPrint('[HealthConnect] Calories: $totalCalories kcal');

      return HealthData(
        steps: totalSteps,
        heartRate: latestHeartRate,
        calories: totalCalories,
      );
    } catch (e) {
      debugPrint('[HealthConnect] fetchHealthData error: $e');
      return const HealthData();
    }
  }
}
