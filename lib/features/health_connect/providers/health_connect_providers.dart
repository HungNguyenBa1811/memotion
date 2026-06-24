import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_connect_service.dart';
import '../models/health_data.dart';

final healthConnectServiceProvider = Provider<HealthConnectService>((ref) {
  return HealthConnectService();
});

final healthDataProvider =
    StateNotifierProvider<HealthDataNotifier, AsyncValue<HealthData>>((ref) {
  final service = ref.watch(healthConnectServiceProvider);
  return HealthDataNotifier(service);
});

class HealthDataNotifier extends StateNotifier<AsyncValue<HealthData>> {
  final HealthConnectService _service;

  HealthDataNotifier(this._service) : super(const AsyncValue.data(HealthData()));

  Future<void> fetch() async {
    debugPrint('[HealthConnect] fetch() called');
    state = const AsyncValue.loading();
    try {
      debugPrint('[HealthConnect] Requesting authorization...');
      final authorized = await _service.requestAuthorization();
      debugPrint('[HealthConnect] Authorization result: $authorized');
      if (!authorized) {
        debugPrint('[HealthConnect] Authorization denied, returning empty data');
        state = const AsyncValue.data(HealthData());
        return;
      }
      debugPrint('[HealthConnect] Fetching health data...');
      final data = await _service.fetchHealthData();
      debugPrint('[HealthConnect] Data fetched: steps=${data.steps}, hr=${data.heartRate}, cal=${data.calories}');
      state = AsyncValue.data(data);
    } catch (e, st) {
      debugPrint('[HealthConnect] ERROR: $e');
      state = AsyncValue.error(e, st);
    }
  }
}
