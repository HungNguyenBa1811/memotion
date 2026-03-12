import 'dart:convert';

/// Types of actions that can be queued for later sync.
enum PendingActionType {
  /// Mark medication task as taken/completed.
  complete,

  /// Mark medication task as skipped/missed.
  skip,
}

/// Represents a single medication action that was performed offline.
///
/// When the device is offline and the user marks a medication as taken or
/// skipped, the action is stored in this format and queued for later execution
/// when connectivity is restored.
class PendingAction {
  /// The task ID from the backend.
  final String taskId;

  /// What action was performed.
  final PendingActionType type;

  /// When the action was queued.
  final DateTime queuedAt;

  /// Optional: medication name for display purposes in UI/logs.
  final String? medicationName;

  const PendingAction({
    required this.taskId,
    required this.type,
    required this.queuedAt,
    this.medicationName,
  });

  Map<String, dynamic> toJson() => {
    'task_id': taskId,
    'type': type.name,
    'queued_at': queuedAt.toIso8601String(),
    'medication_name': medicationName,
  };

  factory PendingAction.fromJson(Map<String, dynamic> json) => PendingAction(
    taskId: json['task_id'] as String,
    type: PendingActionType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => PendingActionType.complete,
    ),
    queuedAt: DateTime.parse(json['queued_at'] as String),
    medicationName: json['medication_name'] as String?,
  );

  String toJsonString() => jsonEncode(toJson());

  factory PendingAction.fromJsonString(String source) =>
      PendingAction.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'PendingAction(taskId: $taskId, type: $type, queuedAt: $queuedAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingAction &&
          runtimeType == other.runtimeType &&
          taskId == other.taskId &&
          type == other.type;

  @override
  int get hashCode => taskId.hashCode ^ type.hashCode;
}
