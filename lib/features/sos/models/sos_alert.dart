enum SosAlertStatus {
  pending,
  active,
  acknowledged,
  resolved,
  cancelled,
  unknown;

  factory SosAlertStatus.fromWireValue(Object? value) {
    return switch (value?.toString().toUpperCase()) {
      'PENDING' => SosAlertStatus.pending,
      'ACTIVE' => SosAlertStatus.active,
      'ACKNOWLEDGED' => SosAlertStatus.acknowledged,
      'RESOLVED' => SosAlertStatus.resolved,
      'CANCELLED' => SosAlertStatus.cancelled,
      _ => SosAlertStatus.unknown,
    };
  }

  String get wireValue => name.toUpperCase();
}

class SosAlert {
  const SosAlert({
    required this.id,
    required this.patientId,
    required this.status,
    required this.triggerSource,
    required this.countdownSeconds,
    required this.remainingSeconds,
    required this.activateAt,
    required this.createdAt,
    this.caretakerId,
    this.message,
    this.activatedAt,
    this.cancelledAt,
    this.cancelledBy,
    this.acknowledgedAt,
    this.resolvedAt,
  });

  final String id;
  final String patientId;
  final String? caretakerId;
  final SosAlertStatus status;
  final String triggerSource;
  final String? message;
  final int countdownSeconds;
  final DateTime? activateAt;
  final DateTime? activatedAt;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;
  final DateTime? createdAt;
  final int remainingSeconds;

  bool get needsSupport =>
      status == SosAlertStatus.active || status == SosAlertStatus.acknowledged;

  bool get isOpen =>
      status == SosAlertStatus.pending ||
      status == SosAlertStatus.active ||
      status == SosAlertStatus.acknowledged;

  factory SosAlert.fromJson(Map<String, dynamic> json) {
    return SosAlert(
      id: _asString(json['sos_id']),
      patientId: _asString(json['patient_id']),
      caretakerId: _asNullableString(json['caretaker_id']),
      status: SosAlertStatus.fromWireValue(json['status']),
      triggerSource: _asString(json['trigger_source']),
      message: _asNullableString(json['message']),
      countdownSeconds: _asInt(json['countdown_seconds']),
      activateAt: _asDateTime(json['activate_at']),
      activatedAt: _asDateTime(json['activated_at']),
      cancelledAt: _asDateTime(json['cancelled_at']),
      cancelledBy: _asNullableString(json['cancelled_by']),
      acknowledgedAt: _asDateTime(json['acknowledged_at']),
      resolvedAt: _asDateTime(json['resolved_at']),
      createdAt: _asDateTime(json['created_at']),
      remainingSeconds: _asInt(json['remaining_seconds']),
    );
  }

  SosAlert copyWith({
    SosAlertStatus? status,
    int? remainingSeconds,
    DateTime? activatedAt,
    DateTime? acknowledgedAt,
  }) {
    return SosAlert(
      id: id,
      patientId: patientId,
      caretakerId: caretakerId,
      status: status ?? this.status,
      triggerSource: triggerSource,
      message: message,
      countdownSeconds: countdownSeconds,
      activateAt: activateAt,
      activatedAt: activatedAt ?? this.activatedAt,
      cancelledAt: cancelledAt,
      cancelledBy: cancelledBy,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      resolvedAt: resolvedAt,
      createdAt: createdAt,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  static String _asString(Object? value) => value?.toString() ?? '';

  static String? _asNullableString(Object? value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }

  static int _asInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _asDateTime(Object? value) {
    final text = value?.toString();
    return text == null ? null : DateTime.tryParse(text);
  }
}

class SosTriggerResult {
  const SosTriggerResult({required this.alert, required this.alreadyExists});

  final SosAlert alert;
  final bool alreadyExists;
}

class SosActiveResult {
  const SosActiveResult({
    required this.needsSupport,
    required this.alert,
    required this.serverTime,
  });

  final bool needsSupport;
  final SosAlert? alert;
  final DateTime? serverTime;
}
