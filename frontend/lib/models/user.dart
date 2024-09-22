// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class User {
    final int id;
    final String username;
    final String? email;
  User({
    required this.id,
    required this.username,
    this.email,
  });

  User copyWith({
    int? id,
    String? username,
    String? email,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'email': email,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      username: map['username'] as String,
      email: map['email'] != null ? map['email'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'User(id: $id, username: $username, email: $email)';

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.username == username &&
      other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ email.hashCode;
}
