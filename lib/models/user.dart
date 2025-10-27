import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final String avatarUrl;
  final String password;
  final String bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isBlocked;
  final DateTime? deletedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.password,
    required this.bio,
    required this.createdAt,
    required this.updatedAt,
    required this.isBlocked,
    this.deletedAt,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? password,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isBlocked,
    DateTime? deletedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      password: password ?? this.password,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isBlocked: isBlocked ?? this.isBlocked,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'password': password,
      'bio': bio,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isBlocked': isBlocked,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      avatarUrl: map['avatarUrl'] as String,
      password: map['password'] as String,
      bio: map['bio'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      isBlocked: map['isBlocked'] as bool,
      deletedAt: map['deletedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deletedAt'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, avatarUrl: $avatarUrl, password: $password, bio: $bio, createdAt: $createdAt, updatedAt: $updatedAt, isBlocked: $isBlocked, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.username == username &&
        other.email == email &&
        other.avatarUrl == avatarUrl &&
        other.password == password &&
        other.bio == bio &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isBlocked == isBlocked &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        avatarUrl.hashCode ^
        password.hashCode ^
        bio.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isBlocked.hashCode ^
        deletedAt.hashCode;
  }
}
