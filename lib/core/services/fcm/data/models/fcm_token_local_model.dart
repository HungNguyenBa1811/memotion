/// Local model for FCM token storage
class FcmTokenLocalModel {
  final String token;
  final DateTime lastUpdated;
  final bool isSynced;

  const FcmTokenLocalModel({
    required this.token,
    required this.lastUpdated,
    required this.isSynced,
  });

  factory FcmTokenLocalModel.fromJson(Map<String, dynamic> json) {
    return FcmTokenLocalModel(
      token: json['token'] as String,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      isSynced: json['is_synced'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'last_updated': lastUpdated.toIso8601String(),
      'is_synced': isSynced,
    };
  }

  FcmTokenLocalModel copyWith({
    String? token,
    DateTime? lastUpdated,
    bool? isSynced,
  }) {
    return FcmTokenLocalModel(
      token: token ?? this.token,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  /// Check if token is expiring soon (>200 days old)
  bool isExpiringSoon() {
    final daysSinceUpdate = DateTime.now().difference(lastUpdated).inDays;
    return daysSinceUpdate > 200;
  }
}
