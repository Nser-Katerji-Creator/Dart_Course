import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String? registrationNumber;
  final String? type;
  final String ownerId;

  Vehicle({
    required this.id,
    this.registrationNumber,
    this.type,
    required this.ownerId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Vehicle) return false;
    return registrationNumber == other.registrationNumber;
  }

  @override
  int get hashCode => registrationNumber.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registrationNumber': registrationNumber,
      'type': type,
      'ownerId': ownerId,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      registrationNumber: json['registrationNumber'] as String?,
      type: json['type'] as String?,
      ownerId: json['ownerId'] as String,
    );
  }

  // Create a copy of this Vehicle with the given field values updated
  Vehicle copyWith({
    String? id,
    String? registrationNumber,
    String? type,
    String? ownerId,
  }) {
    return Vehicle(
      id: id ?? this.id,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      type: type ?? this.type,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
