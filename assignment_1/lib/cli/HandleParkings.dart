import 'dart:io';
import '../repositories/ParkingRepository.dart';
import '../models/Parking.dart';
import '../repositories/VehicleRepository.dart';
import '../repositories/ParkingSpaceRepository.dart';

void handleParkings(
    ParkingRepository parkingRepo, VehicleRepository vehicleRepo, ParkingSpaceRepository parkingSpaceRepo) {
  while (true) {
    print('Du har valt att hantera Parkeringar.');
    print('1. Skapa ny parkering');
    print('2. Visa alla parkeringar');
    print('3. Uppdatera parkering');
    print('4. Ta bort parkering');
    print('5. Gå tillbaka till huvudmenyn');
    stdout.write('Välj ett alternativ (1-5): ');

    var choice = stdin.readLineSync()?.trim();

    switch (choice) {
      case '1':
        try {
          print('Ange registreringsnummer för fordon:');
          var registreringsnummer = stdin.readLineSync()?.trim() ?? '';
          var selectedVehicle = vehicleRepo.getAll().firstWhere(
              (vehicle) => vehicle.registreringsnummer == registreringsnummer,
              orElse: () => throw Exception('Vehicle not found'));

          print('Ange ID för parkeringsplats:');
          var spaceId = stdin.readLineSync()?.trim() ?? '';
          var selectedSpace = parkingSpaceRepo.getAll().firstWhere(
              (space) => space.id == spaceId,
              orElse: () => throw Exception('ParkingSpace not found'));

          var starttid = DateTime.now();
          parkingRepo.add(Parking(
              fordon: selectedVehicle,
              parkeringsplats: selectedSpace,
              starttid: starttid,
              sluttid: null));
          print('Parkering skapad!');
        } catch (e) {
          print('Fel: ${e.toString()}');
        }
        break;
      case '2':
        for (var parking in parkingRepo.getAll()) {
          print(parking);
        }
        break;
      case '3':
        try {
          print('Ange ID för parkeringen som ska uppdateras:');
          var id = int.tryParse(stdin.readLineSync()?.trim() ?? '') ?? 0;
          if (id >= 0 && id < parkingRepo.getAll().length) {
            print('Ange nya registreringsnummer för fordon:');
            var registreringsnummer = stdin.readLineSync()?.trim() ?? '';
            var selectedVehicle = vehicleRepo.getAll().firstWhere(
                (vehicle) => vehicle.registreringsnummer == registreringsnummer,
                orElse: () => throw Exception('Vehicle not found'));

            print('Ange nytt ID för parkeringsplats:');
            var spaceId = stdin.readLineSync()?.trim() ?? '';
            var selectedSpace = parkingSpaceRepo.getAll().firstWhere(
                (space) => space.id == spaceId,
                orElse: () => throw Exception('ParkingSpace not found'));

            var updatedParking = Parking(
                fordon: selectedVehicle,
                parkeringsplats: selectedSpace,
                starttid: parkingRepo.getById(id).starttid,
                sluttid: parkingRepo.getById(id).sluttid);
            parkingRepo.update(updatedParking, id);
            print('Parkering uppdaterad!');
          } else {
            print('Ogiltigt ID.');
          }
        } catch (e) {
          print('Fel: ${e.toString()}');
        }
        break;
      case '4':
        try {
          print('Ange ID för parkeringen som ska tas bort:');
          var id = int.tryParse(stdin.readLineSync()?.trim() ?? '') ?? 0;
          if (id >= 0 && id < parkingRepo.getAll().length) {
            parkingRepo.delete(id);
            print('Parkering borttagen!');
          } else {
            print('Ogiltigt ID.');
          }
        } catch (e) {
          print('Fel: ${e.toString()}');
        }
        break;
      case '5':
        return;
      default:
        print('Ogiltigt val. Försök igen.');
    }
  }
}