import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memotion/features/sos/data/sos_repository.dart';
import 'package:memotion/features/sos/models/sos_alert.dart';
import 'package:memotion/features/sos/providers/sos_controller.dart';
import 'package:memotion/features/sos/providers/sos_effects.dart';

void main() {
  group('SosAlert', () {
    test('parses the server response and derives support state', () {
      final alert = SosAlert.fromJson({
        'sos_id': 'sos-1',
        'patient_id': 'patient-1',
        'caretaker_id': 'caretaker-1',
        'status': 'ACTIVE',
        'trigger_source': 'HIDDEN_BUTTON',
        'message': null,
        'countdown_seconds': 10,
        'activate_at': '2026-07-28T10:15:40',
        'created_at': '2026-07-28T10:15:30',
        'remaining_seconds': 0,
      });

      expect(alert.id, 'sos-1');
      expect(alert.status, SosAlertStatus.active);
      expect(alert.needsSupport, isTrue);
      expect(alert.isOpen, isTrue);
      expect(alert.createdAt, DateTime(2026, 7, 28, 10, 15, 30));
    });
  });

  group('SosController', () {
    test('runs a local countdown and only sends the trigger at the end', () {
      fakeAsync((async) {
        final repository = _FakeSosRepository(
          activeResult: const SosActiveResult(
            needsSupport: false,
            alert: null,
            serverTime: null,
          ),
          triggerResult: SosTriggerResult(
            alert: _alert(status: SosAlertStatus.active),
            alreadyExists: false,
          ),
        );
        final controller = SosController(repository, _FakeSosEffects());

        controller.configureRole('PATIENT');
        async.flushMicrotasks();
        controller.triggerPatientAlert();
        async.flushMicrotasks();

        expect(controller.state.display, SosDisplay.patientCountdown);
        expect(controller.state.remainingSeconds, 10);
        expect(repository.triggerCalls, 0);

        async.elapse(const Duration(seconds: 4));
        expect(controller.state.remainingSeconds, 6);
        expect(repository.triggerCalls, 0);

        async.elapse(const Duration(seconds: 6));
        expect(repository.triggerCalls, 1);
        expect(repository.lastTriggerCountdown, 0);
        expect(controller.state.display, SosDisplay.patientNotified);

        controller.dispose();
      });
    });

    test('cancelling during the countdown never sends the request', () {
      fakeAsync((async) {
        final repository = _FakeSosRepository(
          activeResult: const SosActiveResult(
            needsSupport: false,
            alert: null,
            serverTime: null,
          ),
          triggerResult: SosTriggerResult(
            alert: _alert(status: SosAlertStatus.active),
            alreadyExists: false,
          ),
        );
        final controller = SosController(repository, _FakeSosEffects());

        controller.configureRole('PATIENT');
        async.flushMicrotasks();
        controller.triggerPatientAlert();
        async.elapse(const Duration(seconds: 5));

        controller.cancelPatientAlert();
        async.flushMicrotasks();
        expect(controller.state.display, SosDisplay.none);

        async.elapse(const Duration(seconds: 30));
        expect(repository.triggerCalls, 0);

        controller.dispose();
      });
    });

    test('shows and acknowledges a new caregiver alert', () async {
      final activeAlert = _alert(status: SosAlertStatus.active);
      final repository = _FakeSosRepository(
        activeResult: SosActiveResult(
          needsSupport: true,
          alert: activeAlert,
          serverTime: DateTime(2026, 7, 28, 10, 15, 45),
        ),
        triggerResult: SosTriggerResult(
          alert: activeAlert,
          alreadyExists: true,
        ),
      );
      final effects = _FakeSosEffects();
      final controller = SosController(repository, effects);
      addTearDown(controller.dispose);

      await controller.configureRole('CARETAKER');
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.display, SosDisplay.caregiverEmergency);
      expect(controller.state.alert?.status, SosAlertStatus.acknowledged);
      expect(repository.acknowledgedIds, ['sos-1']);
      expect(effects.caregiverAlarmCount, 1);
    });

    test('keeps the patient notification visible after returning home', () {
      fakeAsync((async) {
        final activeAlert = _alert(status: SosAlertStatus.active);
        final repository = _FakeSosRepository(
          activeResult: const SosActiveResult(
            needsSupport: false,
            alert: null,
            serverTime: null,
          ),
          triggerResult: SosTriggerResult(
            alert: activeAlert,
            alreadyExists: false,
          ),
        );
        final controller = SosController(repository, _FakeSosEffects());

        controller.configureRole('PATIENT');
        async.flushMicrotasks();
        controller.triggerPatientAlert();
        async.elapse(const Duration(seconds: 10));
        expect(controller.state.display, SosDisplay.patientNotified);

        controller.dismissPatientStatus();
        expect(controller.state.display, SosDisplay.patientBanner);

        controller.showPatientStatus();
        expect(controller.state.display, SosDisplay.patientNotified);

        controller.dispose();
      });
    });
  });
}

SosAlert _alert({required SosAlertStatus status, int remainingSeconds = 0}) {
  return SosAlert(
    id: 'sos-1',
    patientId: 'patient-1',
    caretakerId: 'caretaker-1',
    status: status,
    triggerSource: 'HIDDEN_BUTTON',
    countdownSeconds: 10,
    remainingSeconds: remainingSeconds,
    activateAt: DateTime(2026, 7, 28, 10, 15, 40),
    createdAt: DateTime(2026, 7, 28, 10, 15, 30),
  );
}

class _FakeSosRepository implements SosRepository {
  _FakeSosRepository({required this.activeResult, required this.triggerResult});

  SosActiveResult activeResult;
  SosTriggerResult triggerResult;
  int triggerCalls = 0;
  int? lastTriggerCountdown;
  final List<String> acknowledgedIds = [];

  @override
  Future<SosTriggerResult> trigger({
    String triggerSource = 'HIDDEN_BUTTON',
    String? message,
    int countdownSeconds = 10,
  }) async {
    triggerCalls++;
    lastTriggerCountdown = countdownSeconds;
    return triggerResult;
  }

  @override
  Future<SosActiveResult> getActive() async => activeResult;

  @override
  Future<SosAlert> acknowledge(String sosId) async {
    acknowledgedIds.add(sosId);
    return activeResult.alert!.copyWith(
      status: SosAlertStatus.acknowledged,
      acknowledgedAt: DateTime(2026, 7, 28, 10, 15, 46),
    );
  }

  @override
  Future<SosAlert> cancel(String sosId) async {
    return activeResult.alert?.copyWith(status: SosAlertStatus.cancelled) ??
        triggerResult.alert.copyWith(status: SosAlertStatus.cancelled);
  }

  @override
  Future<SosAlert> resolve(String sosId) async {
    return activeResult.alert!.copyWith(status: SosAlertStatus.resolved);
  }

  @override
  Future<List<SosAlert>> getHistory({int limit = 50}) async => const [];
}

class _FakeSosEffects implements SosEffects {
  int caregiverAlarmCount = 0;

  @override
  Future<void> playCaregiverAlarm() async {
    caregiverAlarmCount++;
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
