// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TournamentPermissions {
  final bool isReferee;
  TournamentPermissions({
    required this.isReferee,
  });

  TournamentPermissions copyWith({
    bool? isReferee,
  }) {
    return TournamentPermissions(
      isReferee: isReferee ?? this.isReferee,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'is_referee': isReferee,
    };
  }

  factory TournamentPermissions.fromMap(Map<String, dynamic> map) {
    return TournamentPermissions(
      isReferee: map['is_referee'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory TournamentPermissions.fromJson(String source) => TournamentPermissions.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'TournamentPermissions(isReferee: $isReferee)';

  @override
  bool operator ==(covariant TournamentPermissions other) {
    if (identical(this, other)) return true;
  
    return 
      other.isReferee == isReferee;
  }

  @override
  int get hashCode => isReferee.hashCode;

  factory TournamentPermissions.none() {
    return TournamentPermissions(isReferee: false);
  }
}
