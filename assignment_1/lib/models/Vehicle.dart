import 'Person.dart';

class Vehicle extends Person {
  String registreringsnummer;
  String typ;
  Person owner;

  Vehicle({
    required this.registreringsnummer,
    required this.typ,
    required this.owner,
  }) : super(namn: owner.namn, personnummer: owner.personnummer);
  
  
  @override
  bool isValid() {
    // validation: registration number should not be empty
    return registreringsnummer.isNotEmpty && (typ == "bil" || typ == "motorcykel")&& owner.isValid();
  }

  @override
  Map<String, dynamic> toJson() => {
        'registrationNumber': registreringsnummer,
        'type': typ,
        'owner': owner.toJson(),
      };

  static Vehicle fromJson(Map<String, dynamic> json) => Vehicle(
        registreringsnummer: json['registrationNumber'],
        typ: json['type'],
        owner: Person.fromJson(json['owner']),
      );
  @override
  String toString() =>
      'Vehicle(registreringsnummer: $registreringsnummer, typ: $typ, owner: ${owner.namn})';
}