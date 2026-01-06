/// Medication model representing a medication item
class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String time;
  final String imageUrl;
  final MedicationStatus status;
  final DateTime? scheduledDate;
  final String? remainingTime;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.time,
    this.imageUrl = '',
    this.status = MedicationStatus.pending,
    this.scheduledDate,
    this.remainingTime,
  });

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    String? time,
    String? imageUrl,
    MedicationStatus? status,
    DateTime? scheduledDate,
    String? remainingTime,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      time: time ?? this.time,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      time: json['time'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      status: MedicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MedicationStatus.pending,
      ),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
      remainingTime: json['remainingTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'time': time,
      'imageUrl': imageUrl,
      'status': status.name,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'remainingTime': remainingTime,
    };
  }
}

/// Status of a medication dose
enum MedicationStatus { pending, taken, missed }

/// Extension for MedicationStatus to get display text
extension MedicationStatusExtension on MedicationStatus {
  String get displayText {
    switch (this) {
      case MedicationStatus.pending:
        return 'Pending';
      case MedicationStatus.taken:
        return 'Taken';
      case MedicationStatus.missed:
        return 'Missed';
    }
  }
}
