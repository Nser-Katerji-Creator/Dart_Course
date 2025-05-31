import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSpace {
  final String id;
  final String address;
  final double pricePerHour;
  final bool isOccupied;

  ParkingSpace({
    required this.id,
    required this.address,
    required this.pricePerHour,
    this.isOccupied = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'pricePerHour': pricePerHour,
      'isOccupied': isOccupied,
    };
  }

  // Convert to Firestore-compatible format
  Map<String, dynamic> toFirestore() {
    return {
      // 'id' is typically the document ID in Firestore
      'address': address,
      'pricePerHour': pricePerHour,
      'isOccupied': isOccupied,
    };
  }

  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json['id'] as String,
      address: json['address'] as String,
      pricePerHour: (json['pricePerHour'] is int) 
          ? (json['pricePerHour'] as int).toDouble() 
          : json['pricePerHour'] as double,
      isOccupied: json['isOccupied'] as bool? ?? false,
    );
  }

  // Create a copy of this ParkingSpace with the given field values updated
  ParkingSpace copyWith({
    String? id,
    String? address,
    double? pricePerHour,
    bool? isOccupied,
  }) {
    return ParkingSpace(
      id: id ?? this.id,
      address: address ?? this.address,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      isOccupied: isOccupied ?? this.isOccupied,
    );
  }
}
