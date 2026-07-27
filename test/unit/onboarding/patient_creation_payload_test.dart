import 'package:flutter_test/flutter_test.dart';
import 'package:memotion/features/onboarding/models/patient_creation_payload.dart';

void main() {
  group('PatientCreationPayload', () {
    test(
      'uses a unique caretaker email alias and keeps phone fields separate',
      () {
        final payload = PatientCreationPayload.fromCaretaker(
          patientFullName: '  Mai Nguyen  ',
          patientPhone: ' 0912 345 679 ',
          caretakerEmail: 'caregiver@example.com',
        );

        expect(payload.toJson(), {
          'patient_full_name': 'Mai Nguyen',
          'patient_email': 'caregiver+patient-0912345679@example.com',
          'patient_phone': '0912 345 679',
        });
      },
    );

    test('rejects a missing caretaker email instead of sending the phone', () {
      expect(
        () => PatientCreationPayload.fromCaretaker(
          patientFullName: 'Mai Nguyen',
          patientPhone: '0912345679',
          caretakerEmail: '',
        ),
        throwsFormatException,
      );
    });
  });
}
