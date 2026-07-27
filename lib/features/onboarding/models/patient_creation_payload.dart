class PatientCreationPayload {
  final String patientFullName;
  final String patientEmail;
  final String patientPhone;

  const PatientCreationPayload({
    required this.patientFullName,
    required this.patientEmail,
    required this.patientPhone,
  });

  factory PatientCreationPayload.fromCaretaker({
    required String patientFullName,
    required String patientPhone,
    required String caretakerEmail,
  }) {
    final fullName = patientFullName.trim();
    final phone = patientPhone.trim();

    if (fullName.isEmpty) {
      throw const FormatException('Patient full name is required.');
    }
    if (phone.isEmpty) {
      throw const FormatException('Patient phone number is required.');
    }

    return PatientCreationPayload(
      patientFullName: fullName,
      patientEmail: _patientEmailAlias(caretakerEmail, phone),
      patientPhone: phone,
    );
  }

  Map<String, dynamic> toJson() => {
    'patient_full_name': patientFullName,
    'patient_email': patientEmail,
    'patient_phone': patientPhone,
  };
}

String _patientEmailAlias(String caretakerEmail, String patientPhone) {
  final email = caretakerEmail.trim();
  final separator = email.lastIndexOf('@');
  if (separator <= 0 || separator == email.length - 1) {
    throw const FormatException('A valid caretaker email is required.');
  }

  final localPart = email.substring(0, separator);
  final domain = email.substring(separator + 1);
  final patientToken = patientPhone.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  if (patientToken.isEmpty) {
    throw const FormatException('Patient phone number is invalid.');
  }

  return '$localPart+patient-$patientToken@$domain';
}
