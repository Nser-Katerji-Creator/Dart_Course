import 'package:cloud_firestore/cloud_firestore.dart';

class Parking {
  final String id;
  final String vehicleId;
  final String parkingSpaceId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? plannedDuration; // Store planned parking duration
  
  Parking({
    required this.id,
    required this.vehicleId,
    required this.parkingSpaceId,
    required this.startTime,
    this.endTime,
    this.plannedDuration,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'parkingSpaceId': parkingSpaceId,
      'startTime': startTime,
      'endTime': endTime,
      'plannedDurationMinutes': plannedDuration?.inMinutes,
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
      'plannedDurationMinutes': plannedDuration?.inMinutes,
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
      plannedDuration: json['plannedDurationMinutes'] != null 
          ? Duration(minutes: json['plannedDurationMinutes'] as int)
          : null,
    );
  }
  
  // Create a copy of this Parking with the given field values updated
  Parking copyWith({
    String? id,
    String? vehicleId,
    String? parkingSpaceId,
    DateTime? startTime,
    DateTime? endTime,
    Duration? plannedDuration,
    bool clearEndTime = false,
    bool clearPlannedDuration = false,
  }) {
    return Parking(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      parkingSpaceId: parkingSpaceId ?? this.parkingSpaceId,
      startTime: startTime ?? this.startTime,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      plannedDuration: clearPlannedDuration ? null : (plannedDuration ?? this.plannedDuration),
    );
  }

  // Helper method to get the planned end time (for notifications, etc.)
  DateTime? get plannedEndTime {
    if (plannedDuration != null) {
      return startTime.add(plannedDuration!);
    }
    return null;
  }
}
