import 'dart:io';
import 'package:assignment_1/repositories/PersonRepository.dart';
import 'package:assignment_1/repositories/VehicleRepository.dart';
import 'package:assignment_1/repositories/ParkingSpaceRepository.dart';
import 'package:assignment_1/repositories/ParkingRepository.dart';
import 'package:assignment_1/cli/HandlePersons.dart';
import 'package:assignment_1/cli/HandleVehicles.dart';
import 'package:assignment_1/cli/HandleParkingspaces.dart';
import 'package:assignment_1/cli/HandleParkings.dart';


void main() {
  var personRepo = PersonRepository();
  var vehicleRepo = VehicleRepository();
  var parkingSpaceRepo = ParkingSpaceRepository();
  var parkingRepo = ParkingRepository();

  while (true) {
    print('Välkommen till Parkeringsappen!');
    print('Vad vill du hantera?');
    print('1. Personer');
    print('2. Fordon');
    print('3. Parkeringsplatser');
    print('4. Parkeringar');
    print('5. Avsluta');
    stdout.write('Välj ett alternativ (1-5): ');

    var choice = stdin.readLineSync()?.trim();

    switch (choice) {
      case '1':
        handlePersons(personRepo);
        break;
      case '2':
        handleVehicles(vehicleRepo);
        break;
      case '3':
        handleParkingSpaces(parkingSpaceRepo);
        break;
      case '4':
        handleParkings(parkingRepo, vehicleRepo, parkingSpaceRepo);
        break;
      case '5':
        print('Avslutar programmet...');
        return;
      default:
        print('Ogiltigt val. Försök igen.');
    }
  }
}

