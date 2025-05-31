import 'package:cloud_firestore/cloud_firestore.dart';

class Parking {
  final String id;
  final String vehicleId;
  final String parkingSpaceId;
  final DateTime startTime;
  final DateTime? endTime;
  
  Parking({
    required this.id,
    required this.vehicleId,
    required this.parkingSpaceId,
    required this.startTime,
    this.endTime,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'parkingSpaceId': parkingSpaceId,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
  
  // Convert to Firestore-compatible format
  Map<String, dynamic> toFirestore() {
    return {
      // 'id' is typically the document ID in Firestore
      'vehicleId': vehicleId,
      'parkingSpaceId': parkingSpaceId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
    };
  }
  
  factory Parking.fromJson(Map<String, dynamic> json) {
    // Handle both String ISO dates and Firestore Timestamps
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      }
      return DateTime.now();
    }
    
    return Parking(
      id: json['id'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      parkingSpaceId: json['parkingSpaceId'] ?? json['parkingspaceId'] ?? '',
      startTime: json['startTime'] != null ? parseDateTime(json['startTime']) : DateTime.now(),
      endTime: json['endTime'] != null ? parseDateTime(json['endTime']) : null,
    );
  }
  
  // Create a copy of this Parking with the given field values updated
  Parking copyWith({
    String? id,
    String? vehicleId,
    String? parkingSpaceId,
    DateTime? startTime,
    DateTime? endTime,
    bool clearEndTime = false,
  }) {
    return Parking(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      parkingSpaceId: parkingSpaceId ?? this.parkingSpaceId,
      startTime: startTime ?? this.startTime,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
    );
  }
}
