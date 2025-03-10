class Vehicle {
  final String id;
  final String registrationNumber;
  final String type;
  final String ownerId;

  Vehicle({
    required this.id,
    required this.registrationNumber,
    required this.type,
    required this.ownerId,
  });

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
      id: json['id'],
      registrationNumber: json['registrationNumber'],
      type: json['type'],
      ownerId: json['ownerId'],
    );
  }
}