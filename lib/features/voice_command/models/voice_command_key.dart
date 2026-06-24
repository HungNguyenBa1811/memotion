enum VoiceCommandKey {
  home('HOME'),
  medication('MEDICATION'),
  medicationDetail('MEDICATION_DETAIL'),
  physical('PHYSICAL'),
  nutrition('NUTRITION'),
  startPhysical('START_PHYSICAL'),
  unknown('UNKNOWN');

  const VoiceCommandKey(this.rawValue);

  final String rawValue;

  static VoiceCommandKey fromString(String? key) {
    if (key == null || key.trim().isEmpty) {
      return VoiceCommandKey.unknown;
    }

    final normalizedKey = key.trim().toUpperCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');

    return VoiceCommandKey.values.firstWhere(
      (value) => value.rawValue == normalizedKey,
      orElse: () => VoiceCommandKey.unknown,
    );
  }
}
