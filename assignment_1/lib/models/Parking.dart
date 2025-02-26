import 'ParkingSpace.dart';
import 'Vehicle.dart';

class Parking {
  Vehicle fordon;
  ParkingSpace parkeringsplats;
  DateTime starttid;
  DateTime? sluttid;

  Parking({
    required this.fordon,
    required this.parkeringsplats,
    required this.starttid,
    this.sluttid,
  });

  double calculateCost() {
    if (sluttid == null) return 0.0;
    final duration = sluttid!.difference(starttid);
    return duration.inHours * parkeringsplats.prisPerTimme;
  }
  @override
  String toString() {
    return 'Parking(fordon: ${fordon.registreringsnummer}, parkeringsplats: ${parkeringsplats.id}, '
        'starttid: $starttid, sluttid: $sluttid, cost: ${calculateCost()} SEK)';
  }
}
