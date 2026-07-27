import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memotion/features/auth/providers/auth_provider.dart';
import 'package:memotion/features/sos/data/sos_repository.dart';
import 'package:memotion/features/sos/models/sos_alert.dart';
import 'package:memotion/features/sos/providers/sos_controller.dart';
import 'package:memotion/features/sos/providers/sos_effects.dart';
import 'package:memotion/features/sos/screens/sos_alert_views.dart';
import 'package:memotion/features/sos/widgets/sos_coordinator.dart';

// End-to-end wiring test: authenticated CARETAKER role must make the
// SosCoordinator start the poll loop and surface a later ACTIVE alert.
void main() {
  testWidgets('caretaker session polls and shows a later SOS alert', (
    tester,
  ) async {
    final repository = _FakeSosRepository();
    final effects = _FakeSosEffects();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            (ref) => _StubAuthNotifier(
              const AuthState(
                status: AuthStatus.authenticated,
                role: 'CARETAKER',
              ),
            ),
          ),
          sosRepositoryProvider.overrideWithValue(repository),
          sosEffectsProvider.overrideWithValue(effects),
        ],
        child: const MaterialApp(
          home: SosCoordinator(child: SizedBox.shrink()),
        ),
      ),
    );

    // Post-frame callback fires configureRole -> first poll (no alert).
    await tester.pump();
    await tester.pump();
    expect(repository.getActiveCalls, greaterThanOrEqualTo(1));
    expect(find.byType(CaregiverSosAlertView), findsNothing);

    // Patient's alert becomes ACTIVE on the server; next 5s poll finds it.
    repository.activeResult = SosActiveResult(
      needsSupport: true,
      alert: SosAlert(
        id: 'sos-1',
        patientId: 'patient-1',
        caretakerId: 'caretaker-1',
        status: SosAlertStatus.active,
        triggerSource: 'HIDDEN_BUTTON',
        countdownSeconds: 10,
        remainingSeconds: 0,
        activateAt: DateTime(2026, 7, 28, 10, 15, 40),
        createdAt: DateTime(2026, 7, 28, 10, 15, 30),
      ),
      serverTime: null,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();

    expect(find.byType(CaregiverSosAlertView), findsOneWidget);
    expect(repository.acknowledgedIds, ['sos-1']);
  });
}

class _StubAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _StubAuthNotifier(super.state);

  @override
  Future<bool> login(String email, String password) async => true;

  @override
  Future<bool> register(String nickname, String email, String password) async =>
      true;

  @override
  Future<void> logout() async {}

  @override
  void clearError() {}

  @override
  void markOnboardingComplete() {}
}

class _FakeSosRepository implements SosRepository {
  SosActiveResult activeResult = const SosActiveResult(
    needsSupport: false,
    alert: null,
    serverTime: null,
  );
  int getActiveCalls = 0;
  final List<String> acknowledgedIds = [];

  @override
  Future<SosActiveResult> getActive() async {
    getActiveCalls++;
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
