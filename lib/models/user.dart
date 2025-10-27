import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final dynamic avatarUrl;
  final DateTime created;
  final DateTime updated;
  final DateTime? deletedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.created,
    required this.updated,
    this.deletedAt,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    dynamic avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      created: createdAt ?? created,
      updated: updatedAt ?? updated,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      created: DateTime.parse(map['created'] as String),
      updated: DateTime.parse(map['updated'] as String),
      deletedAt:
          (map['deletedAt'] != null && (map['deletedAt'] as String).isNotEmpty)
          ? DateTime.parse(map['deletedAt'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, createdAt: $created, updatedAt: $updated, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.username == username &&
        other.email == email &&
        other.created == created &&
        other.updated == updated &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        created.hashCode ^
        updated.hashCode ^
        deletedAt.hashCode;
  }
}
