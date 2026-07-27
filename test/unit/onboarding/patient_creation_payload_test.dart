import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memotion/features/onboarding/models/patient_creation_payload.dart';

void main() {
  group('PatientCreationPayload', () {
    test('uses the entered email and generates a valid phone number', () {
      final payload = PatientCreationPayload.fromOnboarding(
        patientFullName: '  Mai Nguyen  ',
        patientEmail: '  patient@example.com ',
        random: Random(42),
      );

      expect(payload.patientFullName, 'Mai Nguyen');
      expect(payload.patientEmail, 'patient@example.com');
      expect(payload.patientPhone, matches(RegExp(r'^091\d{7}$')));
      expect(payload.toJson(), {
        'patient_full_name': payload.patientFullName,
        'patient_email': payload.patientEmail,
        'patient_phone': payload.patientPhone,
      });
    });

    test('uses the supplied random source for deterministic generation', () {
      final first = PatientCreationPayload.fromOnboarding(
        patientFullName: 'Mai Nguyen',
        patientEmail: 'patient@example.com',
        random: Random(7),
      );
      final second = PatientCreationPayload.fromOnboarding(
        patientFullName: 'Mai Nguyen',
        patientEmail: 'patient@example.com',
        random: Random(7),
      );

      expect(first.patientPhone, second.patientPhone);
    });

    test('rejects an invalid patient email', () {
      expect(
        () => PatientCreationPayload.fromOnboarding(
          patientFullName: 'Mai Nguyen',
          patientEmail: 'not-an-email',
        ),
        throwsFormatException,
      );
    });
  });
}
