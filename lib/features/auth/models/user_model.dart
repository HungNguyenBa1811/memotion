class User {
  final String id;
  final String email;
  final String nickname;
  final String? avatarUrl;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.nickname,
    this.avatarUrl,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? nickname,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
