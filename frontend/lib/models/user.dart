// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class User {
    final int id;
    final String email;
    final String username;
  User({
    required this.id,
    required this.email,
    required this.username,
  });

  User copyWith({
    int? id,
    String? email,
    String? username,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'username': username,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      email: map['email'] as String,
      username: map['username'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'User(id: $id, email: $email, username: $username)';

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.email == email &&
      other.username == username;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ username.hashCode;
}
