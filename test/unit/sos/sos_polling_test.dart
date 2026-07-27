import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memotion/features/sos/data/sos_repository.dart';
import 'package:memotion/features/sos/models/sos_alert.dart';
import 'package:memotion/features/sos/providers/sos_controller.dart';
import 'package:memotion/features/sos/providers/sos_effects.dart';

// Reproduces the live demo timeline: the caregiver app is already open and
// idle when the patient triggers an alert, so the alert only appears on a
// later poll cycle — not on the initial configureRole refresh.
void main() {
  const emptyResult = SosActiveResult(
    needsSupport: false,
    alert: null,
    serverTime: null,
  );

  SosAlert activeAlert() => SosAlert(
    id: 'sos-1',
    patientId: 'patient-1',
    caretakerId: 'caretaker-1',
    status: SosAlertStatus.active,
    triggerSource: 'HIDDEN_BUTTON',
    countdownSeconds: 10,
    remainingSeconds: 0,
    activateAt: DateTime(2026, 7, 28, 10, 15, 40),
    createdAt: DateTime(2026, 7, 28, 10, 15, 30),
  );

  test('caregiver poll loop picks up an alert that activates later', () {
    fakeAsync((async) {
      final repository = _FakeSosRepository(activeResult: emptyResult);
      final controller = SosController(repository, _FakeSosEffects());

      controller.configureRole('CARETAKER');
      async.flushMicrotasks();
      expect(controller.state.display, SosDisplay.none);
      expect(repository.getActiveCalls, 1);

      // A few idle poll cycles pass with no alert.
      async.elapse(const Duration(seconds: 15));
      expect(repository.getActiveCalls, greaterThanOrEqualTo(3));
      expect(controller.state.display, SosDisplay.none);

      // The patient's alert becomes ACTIVE on the server.
      repository.activeResult = SosActiveResult(
        needsSupport: true,
        alert: activeAlert(),
        serverTime: null,
      );
      async.elapse(const Duration(seconds: 6));

      expect(controller.state.display, SosDisplay.caregiverEmergency);
      expect(repository.acknowledgedIds, ['sos-1']);

      controller.dispose();
    });
  });

  test('caregiver poll loop survives request failures with backoff', () {
    fakeAsync((async) {
      final repository = _FakeSosRepository(activeResult: emptyResult);
      final controller = SosController(repository, _FakeSosEffects());

      controller.configureRole('CARETAKER');
      async.flushMicrotasks();

      repository.shouldFail = true;
      async.elapse(const Duration(minutes: 2));

      repository.shouldFail = false;
      repository.activeResult = SosActiveResult(
        needsSupport: true,
        alert: activeAlert(),
        serverTime: null,
      );
      async.elapse(const Duration(seconds: 31));

      expect(controller.state.display, SosDisplay.caregiverEmergency);

      controller.dispose();
    });
  });

  test('caregiver poll loop keeps polling while backgrounded', () {
    fakeAsync((async) {
      final repository = _FakeSosRepository(activeResult: emptyResult);
      final controller = SosController(repository, _FakeSosEffects());

      controller.configureRole('CARETAKER');
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 10));

      controller.setForeground(false);
      final callsBeforeBackground = repository.getActiveCalls;
      async.elapse(const Duration(seconds: 30));
      expect(repository.getActiveCalls, greaterThan(callsBeforeBackground));

      // An SOS arriving while the app is backgrounded is still picked up.
      repository.activeResult = SosActiveResult(
        needsSupport: true,
        alert: activeAlert(),
        serverTime: null,
      );
      async.elapse(const Duration(seconds: 6));
      expect(controller.state.display, SosDisplay.caregiverEmergency);
      expect(repository.acknowledgedIds, ['sos-1']);

      controller.dispose();
    });
  });
}

class _FakeSosRepository implements SosRepository {
  _FakeSosRepository({required this.activeResult});

  SosActiveResult activeResult;
  bool shouldFail = false;
  int getActiveCalls = 0;
  final List<String> acknowledgedIds = [];

  @override
  Future<SosActiveResult> getActive() async {
    getActiveCalls++;
    if (shouldFail) throw Exception('network down');
    return activeResult;
  }

  @override
  Future<SosAlert> acknowledge(String sosId) async {
    acknowledgedIds.add(sosId);
    return activeResult.alert!.copyWith(
      status: SosAlertStatus.acknowledged,
      acknowledgedAt: DateTime(2026, 7, 28, 10, 15, 46),
    );
  }

  @override
  Future<SosAlert> cancel(String sosId) async =>
      activeResult.alert!.copyWith(status: SosAlertStatus.cancelled);

  @override
  Future<SosAlert> resolve(String sosId) async =>
      activeResult.alert!.copyWith(status: SosAlertStatus.resolved);

  @override
  Future<SosTriggerResult> trigger({
    String triggerSource = 'HIDDEN_BUTTON',
    String? message,
    int countdownSeconds = 10,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<SosAlert>> getHistory({int limit = 50}) async => const [];
}

class _FakeSosEffects implements SosEffects {
  @override
  Future<void> playCaregiverAlarm() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
