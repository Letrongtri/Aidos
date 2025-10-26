import 'dart:convert';

class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String password;
  final String bio;
  final String? link;
  final String avatarUrl;
  final int followerCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isblock;
  final bool isPrivate;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.bio,
    required this.link,
    required this.avatarUrl,
    required this.followerCount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isblock,
    required this.isPrivate,
  });

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? password,
    String? bio,
    String? link,
    String? avatarUrl,
    int? followerCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isBlocked,
    bool? isPrivate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      bio: bio ?? this.bio,
      link: link ?? this.link,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      followerCount: followerCount ?? this.followerCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isblock: isBlocked ?? isblock,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'bio': bio,
      'link': link,
      'avatarUrl': avatarUrl,
      'followerCount': followerCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
      'isBlocked': isblock,
      'isPrivate': isPrivate,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      bio: map['bio'] as String,
      link: map['link'] as String,
      avatarUrl: map['avatarUrl'] as String,
      followerCount: map['followerCount'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      deletedAt: map['deletedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deletedAt'] as int)
          : null,
      isblock: map['isBlocked'] as bool,
      isPrivate: map['isPrivate'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, name: $name, username: $username, email: $email, password: $password, bio: $bio, link: $link, avatarUrl: $avatarUrl, followerCount: $followerCount, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, isBlocked: $isblock, isPrivate: $isPrivate)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.username == username &&
        other.email == email &&
        other.password == password &&
        other.bio == bio &&
        other.link == link &&
        other.avatarUrl == avatarUrl &&
        other.followerCount == followerCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt &&
        other.isblock == isblock &&
        other.isPrivate == isPrivate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        username.hashCode ^
        email.hashCode ^
        password.hashCode ^
        bio.hashCode ^
        link.hashCode ^
        avatarUrl.hashCode ^
        followerCount.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode ^
        isblock.hashCode ^
        isPrivate.hashCode;
  }
}
