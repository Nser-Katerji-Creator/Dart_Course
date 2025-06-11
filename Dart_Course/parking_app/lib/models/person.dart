import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  final String id;
  final String? name;
  final String? personalNumber;
  final String? email;
  final String? uid; // Firebase Auth UID

  Person({
    required this.id, 
    this.name, 
    this.personalNumber, 
    this.email,
    this.uid,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'personalNumber': personalNumber,
      'email': email,
      'uid': uid,
    };
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as String,
      name: json['name'] as String?,
      personalNumber: json['personalNumber'] as String?,
      email: json['email'] as String?,
      uid: json['uid'] as String?,
    );
  }

  // Create a copy of this Person with the given field values updated
  Person copyWith({
    String? id,
    String? name,
    String? personalNumber,
    String? email,
    String? uid,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      personalNumber: personalNumber ?? this.personalNumber,
      email: email ?? this.email,
      uid: uid ?? this.uid,
    );
  }
}
