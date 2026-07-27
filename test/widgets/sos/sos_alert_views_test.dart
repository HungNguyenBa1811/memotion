import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memotion/features/sos/models/sos_alert.dart';
import 'package:memotion/features/sos/screens/sos_alert_views.dart';

void main() {
  testWidgets('patient countdown exposes the server countdown and cancel', (
    tester,
  ) async {
    var cancelled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PatientSosAlertView(
          isNotified: false,
          remainingSeconds: 7,
          isBusy: false,
          isRetryingConnection: false,
          onCancel: () => cancelled = true,
          onDismiss: () {},
        ),
      ),
    );

    expect(find.text('We detected something unusual'), findsOneWidget);
    expect(find.byKey(const Key('sos-countdown')), findsOneWidget);
    expect(find.text('7'), findsOneWidget);

    final cancelButton = find.byKey(const Key('sos-cancel-button'));
    await tester.ensureVisible(cancelButton);
    await tester.tap(cancelButton);
    expect(cancelled, isTrue);
  });

  testWidgets('caregiver emergency exposes the required response actions', (
    tester,
  ) async {
    var resolved = false;
    var falseAlarm = false;
    await tester.pumpWidget(
      MaterialApp(
        home: CaregiverSosAlertView(
          alert: _activeAlert(),
          isBusy: false,
          onCallEmergencyServices: () {},
          onResolve: () => resolved = true,
          onFalseAlarm: () => falseAlarm = true,
          onMinimize: () {},
        ),
      ),
    );

    expect(find.text('Your care recipient needs help'), findsOneWidget);
    expect(find.text('Call emergency services (115)'), findsOneWidget);

    final resolveButton = find.byKey(const Key('sos-resolve-button'));
    await tester.ensureVisible(resolveButton);
    await tester.tap(resolveButton);
    final falseAlarmButton = find.byKey(const Key('sos-false-alarm-button'));
    await tester.ensureVisible(falseAlarmButton);
    await tester.tap(falseAlarmButton);
    expect(resolved, isTrue);
    expect(falseAlarm, isTrue);
  });

  testWidgets('patient SOS banner keeps caregiver notification visible', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: PatientSosStatusBanner(
              alert: _activeAlert(),
              isRetryingConnection: false,
              onOpen: () => opened = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Your caregiver has been notified'), findsOneWidget);
    await tester.tap(find.byKey(const Key('patient-sos-status-banner')));
    expect(opened, isTrue);
  });
}

SosAlert _activeAlert() {
  return SosAlert(
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
}
