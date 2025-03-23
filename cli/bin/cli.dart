import 'dart:io';
//import 'package:cli/cli.dart';
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';
import 'package:cli/repositories/http_parking_repository.dart';
import 'package:cli/repositories/http_parking_space_repository.dart';
import 'package:cli/repositories/http_person_repository.dart';
import 'package:cli/repositories/http_vehicle_repository.dart';

void main() async {
  
  final client = http.Client();
  final personRepository = HttpPersonRepository(client);
  final vehicleRepository = HttpVehicleRepository(client);
  final parkingSpaceRepository = HttpParkingSpaceRepository(client);
  final parkingRepository = HttpParkingRepository(client);
  
  while (true) {
    print('Welcome to the Parking App!');
    print('What would you like to manage?');
    print('1. Persons');
    print('2. Vehicles');
    print('3. Parking Spaces');
    print('4. Parkings');
    print('5. Exit');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await managePersons(personRepository);
        break;
      case '2':
        await manageVehicles(vehicleRepository);
        break;
      case '3':
        await manageParkingSpaces(parkingSpaceRepository);
        break;
      case '4':
        await manageParkings(parkingRepository);
        break;
      case '5':
        exit(0);
      default:
        print('Invalid choice. Please try again.');
    }
  }
}

Future<void> managePersons(PersonRepository repository) async {
  while (true) {
    print('What would you like to do with Persons?');
    print('1. Create a new person');
    print('2. List all persons');
    print('3. Update a person');
    print('4. Delete a person');
    print('5. Go back');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await createPerson(repository);
        break;
      case '2':
        await listPersons(repository);
        break;
      case '3':
        await updatePersonByPersonnummer(repository);
        break;
      case '4':
        await deletePerson(repository);
        break;
      case '5':
        return;
      default:
        print('Invalid choice. Please try again.');
    }
  }
}

Future<void> createPerson(PersonRepository repository) async {
  print('Enter name:');
  final name = stdin.readLineSync();
  print('Enter personal number:');
  final personalNumber = stdin.readLineSync();
  final person = Person( name: name!, personalNumber: personalNumber!);
  await repository.create(person);
  print('Person created successfully.');
}

Future<void> listPersons(PersonRepository repository) async {
  final persons = await repository.getAll();
  for (var person in persons) {
    print('Name: ${person.name}, Personal Number: ${person.personalNumber}');
  }
}

Future<void> updatePersonByPersonnummer(PersonRepository repository) async {
  // Prompt the user for the personalNumber of the person to update
  print('Enter the personalNumber of the person to update:');
  final personalNumber = stdin.readLineSync()!;

  // Find the person by personalNumber (optional, to show current details)
  final person = await repository.getBypersonalNumber(personalNumber);
  print('Person found: $person');
  if (person == null) {
    print('No person found with personalNumber: $personalNumber');
    return;
  }

  print('Current details:');
  print('Name: ${person.name}, personalNumber: ${person.personalNumber}');

  // Prompt the user for the updated data
  print('Enter the new name (leave blank to keep current):');
  final name = stdin.readLineSync();
  //print('Enter the new personalNumber (leave blank to keep current):');
  //final newPersonalNumber = stdin.readLineSync();

  // Create the updated person object
  final updatedPerson = Person(
    name: name?.isNotEmpty == true ? name! : person.name,
    personalNumber: personalNumber.isNotEmpty == true ? personalNumber : person.personalNumber,
  );

  // Send the update request to the repository
  await repository.updateBypersonalNumber(personalNumber, updatedPerson);
  print('Person updated successfully.');
}

Future<void> updatePerson(PersonRepository repository) async {
  print('Enter the personal number of the person to update:');
  final personalNumber = stdin.readLineSync();
  print('Enter new name:');
  final name = stdin.readLineSync();
  //print('Enter new id number:');
  //final id = stdin.readLineSync();
  final person = Person(name: name!, personalNumber: personalNumber!);
  await repository.updateBypersonalNumber(personalNumber, person);
  print('Person updated successfully.');
}

Future<void> deletePerson(PersonRepository repository) async {
  print('Enter the Personal Number of the person to delete:');
  final personalNumber = stdin.readLineSync();
  await repository.delete(personalNumber!);
  print('Person deleted successfully.');
}

Future<void> manageVehicles(VehicleRepository repository) async {
  while (true) {
    print('What would you like to do with Vehicles?');
    print('1. Create a new vehicle');
    print('2. List all vehicles');
    print('3. Update a vehicle');
    print('4. Delete a vehicle');
    print('5. Go back');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await createVehicle(repository);
        break;
      case '2':
        await listVehicles(repository);
        break;
      case '3':
        await updateVehicle(repository);
        break;
      case '4':
        await deleteVehicle(repository);
        break;
      case '5':
        return;
      default:
        print('Invalid choice. Please try again.');
    }
  }
}

Future<void> createVehicle(VehicleRepository repository) async {
  print('Enter registration number:');
  final registreringsnummer = stdin.readLineSync();
  print('Enter vehicle type:');
  final type = stdin.readLineSync();
  print('Enter owner ID:');
  final ownerId = stdin.readLineSync();
  final vehicle = Vehicle(
    registreringsnummer: registreringsnummer!,
    type: type!,
    ownerId: int.parse(ownerId!),
  );
  await repository.create(vehicle);
  print('Vehicle created successfully.');
}

Future<void> listVehicles(VehicleRepository repository) async {
  final vehicles = await repository.getAll();
  for (var vehicle in vehicles) {
    print('Registration Number: ${vehicle.registreringsnummer}, Type: ${vehicle.type}, Owner ID: ${vehicle.ownerId}');
  }
}

Future<void> updateVehicle(VehicleRepository repository) async {
  print('Enter new registration number:');
  final registreringsnummer = stdin.readLineSync();
  print('Enter new vehicle type:');
  final type = stdin.readLineSync();
  print('Enter new owner ID:');
  final ownerId = stdin.readLineSync();
  final vehicle = Vehicle(
    registreringsnummer: registreringsnummer!,
    type: type!,
    ownerId: int.parse(ownerId!),
  );
  await repository.update(registreringsnummer, vehicle);
  print('Vehicle updated successfully.');
}

Future<void> deleteVehicle(VehicleRepository repository) async {
  print('Enter the Registering Number of the vehicle to delete:');
  final registreringsnummer = stdin.readLineSync();
  await repository.delete(registreringsnummer!);
  print('Vehicle deleted successfully.');
}

Future<void> manageParkingSpaces(ParkingSpaceRepository repository) async {
  while (true) {
    print('What would you like to do with Parking Spaces?');
    print('1. Create a new parking space');
    print('2. List all parking spaces');
    print('3. Update a parking space');
    print('4. Delete a parking space');
    print('5. Go back');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await createParkingSpace(repository);
        break;
      case '2':
        await listParkingSpaces(repository);
        break;
      case '3':
        await updateParkingSpace(repository);
        break;
      case '4':
        await deleteParkingSpace(repository);
        break;
      case '5':
        return;
      default:
        print('Invalid choice. Please try again.');
    }
  }
}

Future<void> createParkingSpace(ParkingSpaceRepository repository) async {
  print('Enter address:');
  final address = stdin.readLineSync();
  print('Enter price per hour:');
  final pricePerHour = double.parse(stdin.readLineSync()!);
  final parkingSpace = ParkingSpace(
    id: Uuid().v4(),
    address: address!,
    pricePerHour: pricePerHour,
  );
  await repository.create(parkingSpace);
  print('Parking space created successfully.');
}

Future<void> listParkingSpaces(ParkingSpaceRepository repository) async {
  final parkingSpaces = await repository.getAll();
  for (var parkingSpace in parkingSpaces) {
    print('ID: ${parkingSpace.id}, Address: ${parkingSpace.address}, Price Per Hour: ${parkingSpace.pricePerHour}');
  }
}

Future<void> updateParkingSpace(ParkingSpaceRepository repository) async {
  print('Enter the ID of the parking space to update:');
  final id = stdin.readLineSync();
  print('Enter new address:');
  final address = stdin.readLineSync();
  print('Enter new price per hour:');
  final pricePerHour = double.parse(stdin.readLineSync()!);
  final parkingSpace = ParkingSpace(
    id: id!,
    address: address!,
    pricePerHour: pricePerHour,
  );
  await repository.update(id, parkingSpace);
  print('Parking space updated successfully.');
}

Future<void> deleteParkingSpace(ParkingSpaceRepository repository) async {
  print('Enter the ID of the parking space to delete:');
  final id = stdin.readLineSync();
  await repository.delete(id!);
  print('Parking space deleted successfully.');
}

Future<void> manageParkings(ParkingRepository repository) async {
  while (true) {
    print('What would you like to do with Parkings?');
    print('1. Create a new parking');
    print('2. List all parkings');
    print('3. Update a parking');
    print('4. Delete a parking');
    print('5. Go back');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await createParking(repository);
        break;
      case '2':
        await listParkings(repository);
        break;
      case '3':
        await updateParking(repository);
        break;
      case '4':
        await deleteParking(repository);
        break;
      case '5':
        return;
      default:
        print('Invalid choice. Please try again.');
    }
  }
}

Future<void> createParking(ParkingRepository repository) async {
  print('Enter vehicle ID:');
  final vehicleId = stdin.readLineSync();
  print('Enter parking space ID:');
  final parkingSpaceId = stdin.readLineSync();
  final parking = Parking(
    id: Uuid().v4(),
    vehicleId: int.parse(vehicleId!),
    parkingSpaceId: parkingSpaceId.toString(),
    startTime: DateTime.now(),
  );
  await repository.create(parking);
  print('Parking created successfully.');
}

Future<void> listParkings(ParkingRepository repository) async {
  final parkings = await repository.getAll();
  for (var parking in parkings) {
    print('ID: ${parking.id}, Vehicle ID: ${parking.vehicleId}, Parking Space ID: ${parking.parkingSpaceId}, Start Time: ${parking.startTime}, End Time: ${parking.endTime}');
  }
}

Future<void> updateParking(ParkingRepository repository) async {
  print('Enter the ID of the parking to update:');
  final id = stdin.readLineSync();
  print('Enter new vehicle ID:');
  final vehicleId = stdin.readLineSync();
  print('Enter new parking space ID:');
  final parkingSpaceId = stdin.readLineSync();
  print('Enter new end time (optional, leave blank if ongoing):');
  final endTimeInput = stdin.readLineSync();
  final endTime = endTimeInput?.isNotEmpty == true ? DateTime.parse(endTimeInput!) : null;
  final parking = Parking(
    id: id!,
    vehicleId: int.parse(vehicleId!),
    parkingSpaceId: parkingSpaceId.toString(),
    startTime: DateTime.now(),
    endTime: endTime,
  );
  await repository.update(id, parking);
  print('Parking updated successfully.');
}

Future<void> deleteParking(ParkingRepository repository) async {
  print('Enter the ID of the parking to delete:');
  final id = stdin.readLineSync();
  await repository.delete(id!);
  print('Parking deleted successfully.');
}