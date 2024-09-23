// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:frontend/models/user.dart';

class Referee {
  final int id;
  final int tournament_id;
  final int user_id;
  final User user;
  Referee({
    required this.id,
    required this.tournament_id,
    required this.user_id,
    required this.user,
  });

  Referee copyWith({
    int? id,
    int? tournament_id,
    int? user_id,
    User? user,
  }) {
    return Referee(
      id: id ?? this.id,
      tournament_id: tournament_id ?? this.tournament_id,
      user_id: user_id ?? this.user_id,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'tournament_id': tournament_id,
      'user_id': user_id,
      'user': user.toMap(),
    };
  }

  factory Referee.fromMap(Map<String, dynamic> map) {
    return Referee(
      id: map['id'] as int,
      tournament_id: map['tournament_id'] as int,
      user_id: map['user_id'] as int,
      user: User.fromMap(map['user'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory Referee.fromJson(String source) =>
      Referee.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Referee(id: $id, tournament_id: $tournament_id, user_id: $user_id, user: $user)';
  }

  @override
  bool operator ==(covariant Referee other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.tournament_id == tournament_id &&
        other.user_id == user_id &&
        other.user == user;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tournament_id.hashCode ^
        user_id.hashCode ^
        user.hashCode;
  }

  factory Referee.fromRocket(List<dynamic> list) {
    Map<String, dynamic> referee_raw = list[0];
    Map<String, dynamic> user_raw = list[1];
    return Referee(
      id: referee_raw["id"],
      tournament_id: referee_raw["tournament_id"],
      user_id: referee_raw["user_id"],
      user: User.fromMap(user_raw),
    );
  }
}
