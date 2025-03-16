class Vehicle {
  //late final String id;
  final String? registreringsnummer;
  final String? type;
  final int ownerId;

  Vehicle({
   // required this.id,
    required this.registreringsnummer,
    required this.type,
    required this.ownerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'registreringsnummer': registreringsnummer,
      'type': type,
      'ownerId': ownerId,
    };
  }

  factory Vehicle.fromJson(Map<String?, dynamic> json) {
    return Vehicle(
      registreringsnummer: json['registreringsnummer'],
      type: json['type'],
      ownerId: json['ownerId'],
    );
  }
}