// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:frontend/models/user.dart';
import 'package:intl/intl.dart';

class Tournament {
  final int id;
  final String name;
  final DateTime date;
  final int slots;
  final User? owner;

  Tournament(
    this.id,
    this.name,
    this.date,
    this.slots,
    this.owner,
  );

  Tournament copyWith({
    int? id,
    String? name,
    DateTime? date,
    int? slots,
    User? owner,
  }) {
    return Tournament(
      id ?? this.id,
      name ?? this.name,
      date ?? this.date,
      slots ?? this.slots,
      owner ?? this.owner,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'date': date.millisecondsSinceEpoch,
      'slots': slots,
      'owner': owner?.toMap(),
    };
  }

  factory Tournament.fromMap(Map<String, dynamic> map) {
    return Tournament(
      map['id'] as int,
      map['name'] as String,
      DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      map['slots'] as int,
      User.fromMap(map['owner'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory Tournament.fromJson(String source) =>
      Tournament.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Tournament(id: $id, name: $name, date: $date, slots: $slots, owner: $owner)';
  }

  @override
  bool operator ==(covariant Tournament other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.date == date &&
        other.slots == slots &&
        other.owner == owner;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        date.hashCode ^
        slots.hashCode ^
        owner.hashCode;
  }

  factory Tournament.fromRocket(List<dynamic> items) {
    final tournament_list = items[0];
    final user_items = items[1];
    return Tournament(
      tournament_list["id"],
      tournament_list["name"],
      tournament_list["start_datetime"] != null ? DateFormat("yyyy-MM-dd'T'hh:mm:ss").parse(tournament_list["start_datetime"]) : DateTime.now(),
      tournament_list["slots"],
      user_items != null ? User.fromMap(user_items) : null,
    );
  }
}
