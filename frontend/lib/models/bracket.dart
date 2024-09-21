// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Bracket {
    final int id;
    final int tournament_id;
    final int? player1_id;
    final int? player2_id;
    final int? ref_id;
    final int? next_match_id;

    final int score_1;
    final int score_2;
  Bracket({
    required this.id,
    required this.tournament_id,
    required this.player1_id,
    required this.player2_id,
    required this.ref_id,
    required this.next_match_id,
    required this.score_1,
    required this.score_2,
  });

  Bracket copyWith({
    int? id,
    int? tournament_id,
    int? player1_id,
    int? player2_id,
    int? ref_id,
    int? next_match_id,
    int? score_1,
    int? score_2,
  }) {
    return Bracket(
      id: id ?? this.id,
      tournament_id: tournament_id ?? this.tournament_id,
      player1_id: player1_id ?? this.player1_id,
      player2_id: player2_id ?? this.player2_id,
      ref_id: ref_id ?? this.ref_id,
      next_match_id: next_match_id ?? this.next_match_id,
      score_1: score_1 ?? this.score_1,
      score_2: score_2 ?? this.score_2,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'tournament_id': tournament_id,
      'player1_id': player1_id,
      'player2_id': player2_id,
      'ref_id': ref_id,
      'next_match_id': next_match_id,
      'score_1': score_1,
      'score_2': score_2,
    };
  }

  factory Bracket.fromMap(Map<String, dynamic> map) {
    return Bracket(
      id: map['id'] as int,
      tournament_id: map['tournament_id'] as int,
      player1_id: map['player1_id'] != null ? map['player1_id'] as int : null,
      player2_id: map['player2_id'] != null ? map['player2_id'] as int : null,
      ref_id: map['ref_id'] != null ? map['ref_id'] as int : null,
      next_match_id: map['next_match_id'] != null ? map['next_match_id'] as int : null,
      score_1: map['score_1'] as int,
      score_2: map['score_2'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Bracket.fromJson(String source) => Bracket.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Bracket(id: $id, tournament_id: $tournament_id, player1_id: $player1_id, player2_id: $player2_id, ref_id: $ref_id, next_match_id: $next_match_id, score_1: $score_1, score_2: $score_2)';
  }

  @override
  bool operator ==(covariant Bracket other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.tournament_id == tournament_id &&
      other.player1_id == player1_id &&
      other.player2_id == player2_id &&
      other.ref_id == ref_id &&
      other.next_match_id == next_match_id &&
      other.score_1 == score_1 &&
      other.score_2 == score_2;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      tournament_id.hashCode ^
      player1_id.hashCode ^
      player2_id.hashCode ^
      ref_id.hashCode ^
      next_match_id.hashCode ^
      score_1.hashCode ^
      score_2.hashCode;
  }
}
