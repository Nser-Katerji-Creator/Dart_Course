class ParkingSpace {
  late final String id;
  final String address;
  final double pricePerHour;

  ParkingSpace({
    required this.id,
    required this.address,
    required this.pricePerHour,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'pricePerHour': pricePerHour,
    };
  }

  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json['id'],
      address: json['address'],
      pricePerHour: json['pricePerHour'],
    );
  }
}