// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class Topic {
  final String id;
  final String name;
  final DateTime created;
  final DateTime updated;

  Topic({
    required this.id,
    required this.name,
    required this.created,
    required this.updated,
  });

  Topic copyWith({
    String? id,
    String? name,
    DateTime? created,
    DateTime? updated,
  }) {
    return Topic(
      id: id ?? this.id,
      name: name ?? this.name,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'] as String,
      name: map['name'] as String,
      created: DateTime.parse(map['created'] as String),
      updated: DateTime.parse(map['updated'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory Topic.fromJson(String source) =>
      Topic.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Topic(id: $id, name: $name, created: $created, updated: $updated)';
  }

  @override
  bool operator ==(covariant Topic other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.created == created &&
        other.updated == updated;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ created.hashCode ^ updated.hashCode;
  }

  factory Topic.fromPocketbase(RecordModel record) {
    return Topic(
      id: record.id,
      name: record.getStringValue('name'),
      created: DateTime.parse(record.getStringValue('created')),
      updated: DateTime.parse(record.getStringValue('updated')),
    );
  }
}
