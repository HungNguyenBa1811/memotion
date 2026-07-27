import 'dart:math';

class PatientCreationPayload {
  final String patientFullName;
  final String patientEmail;
  final String patientPhone;

  const PatientCreationPayload({
    required this.patientFullName,
    required this.patientEmail,
    required this.patientPhone,
  });

  factory PatientCreationPayload.fromOnboarding({
    required String patientFullName,
    required String patientEmail,
    Random? random,
  }) {
    final fullName = patientFullName.trim();
    final email = patientEmail.trim();

    if (fullName.isEmpty) {
      throw const FormatException('Patient full name is required.');
    }
    if (!_isValidEmail(email)) {
      throw const FormatException('A valid patient email is required.');
    }

    return PatientCreationPayload(
      patientFullName: fullName,
      patientEmail: email,
      patientPhone: _randomVietnamesePhone(random ?? Random()),
    );
  }

  Map<String, dynamic> toJson() => {
    'patient_full_name': patientFullName,
    'patient_email': patientEmail,
    'patient_phone': patientPhone,
  };
}

bool _isValidEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
}

String _randomVietnamesePhone(Random random) {
  final buffer = StringBuffer('091');
  for (var index = 0; index < 7; index++) {
    buffer.write(random.nextInt(10));
  }
  return buffer.toString();
}
