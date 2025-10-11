// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Topic {
  final String id;
  final String name;

  Topic({required this.id, required this.name});

  Topic copyWith({String? id, String? name}) {
    return Topic(id: id ?? this.id, name: name ?? this.name);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name};
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(id: map['id'] as String, name: map['name'] as String);
  }

  String toJson() => json.encode(toMap());

  factory Topic.fromJson(String source) =>
      Topic.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Topic(id: $id, name: $name)';

  @override
  bool operator ==(covariant Topic other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
