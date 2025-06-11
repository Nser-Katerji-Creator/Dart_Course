class Parking {
  final String id;
  final String vehicleId;
  final String parkingSpaceId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? plannedDuration;

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
      'parkingspaceId': parkingSpaceId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'plannedDurationMinutes': plannedDuration?.inMinutes,
    };
  }

  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      parkingSpaceId: json['parkingspaceId'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      plannedDuration: json['plannedDurationMinutes'] != null 
          ? Duration(minutes: json['plannedDurationMinutes'] as int)
          : null,
    );
  }
}