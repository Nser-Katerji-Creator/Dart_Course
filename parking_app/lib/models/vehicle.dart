class Vehicle {
  final String id;
  final String? registreringsnummer;
  final String? type;
  final String ownerId;

  Vehicle({
    required this.id,
    required this.registreringsnummer,
    required this.type,
    required this.ownerId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Vehicle) return false;
    return registreringsnummer == other.registreringsnummer;
  }

  @override
  int get hashCode => registreringsnummer.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registreringsnummer': registreringsnummer,
      'type': type,
      'ownerId': ownerId,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      registreringsnummer: json['registreringsnummer'],
      type: json['type'],
      ownerId: json['ownerId'],
    );
  }
}
