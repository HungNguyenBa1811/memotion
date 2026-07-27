import '../models/sos_alert.dart';
import 'sos_api_service.dart';

abstract interface class SosRepository {
  Future<SosTriggerResult> trigger({
    String triggerSource = 'HIDDEN_BUTTON',
    String? message,
    int countdownSeconds = 10,
  });

  Future<SosActiveResult> getActive();
  Future<SosAlert> cancel(String sosId);
  Future<SosAlert> acknowledge(String sosId);
  Future<SosAlert> resolve(String sosId);
  Future<List<SosAlert>> getHistory({int limit = 50});
}

class ApiSosRepository implements SosRepository {
  ApiSosRepository(this._apiService);

  final SosApiService _apiService;

  @override
  Future<SosTriggerResult> trigger({
    String triggerSource = 'HIDDEN_BUTTON',
    String? message,
    int countdownSeconds = 10,
  }) {
    return _apiService.trigger(
      triggerSource: triggerSource,
      message: message,
      countdownSeconds: countdownSeconds,
    );
  }

  @override
  Future<SosActiveResult> getActive() => _apiService.getActive();

  @override
  Future<SosAlert> cancel(String sosId) => _apiService.cancel(sosId);

  @override
  Future<SosAlert> acknowledge(String sosId) => _apiService.acknowledge(sosId);

  @override
  Future<SosAlert> resolve(String sosId) => _apiService.resolve(sosId);

  @override
  Future<List<SosAlert>> getHistory({int limit = 50}) =>
      _apiService.getHistory(limit: limit);
}
