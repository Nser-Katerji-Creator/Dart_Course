import 'dart:io';
import '../repositories/VehicleRepository.dart';
import '../models/Person.dart';
import '../models/Vehicle.dart';

void handleVehicles(VehicleRepository repo) {
  while (true) {
    print('Du har valt att hantera Fordon.');
    print('1. Skapa nytt fordon');
    print('2. Visa alla fordons');
    print('3. Uppdatera fordon');
    print('4. Ta bort fordon');
    print('5. Gå tillbaka till huvudmenyn');
    stdout.write('Välj ett alternativ (1-5): ');

    var choice = stdin.readLineSync()?.trim();

    switch (choice) {
      case '1':
        print('Ange registreringsnummer:');
        var registreringsnummer = stdin.readLineSync()?.trim() ?? '';
        print('Ange typ (t.ex., bil, motorcykel):');
        var typ = stdin.readLineSync()?.trim() ?? '';
        print('Ange owners namn:');
        var ownerNamn = stdin.readLineSync()?.trim() ?? '';
        print('Ange ownerns personnummer:');
        var ownerPersonnummer = stdin.readLineSync()?.trim() ?? '';
        var owner = Person(namn: ownerNamn, personnummer: ownerPersonnummer);
        var vehicle = Vehicle(
            registreringsnummer: registreringsnummer, typ: typ, owner: owner);
        if(vehicle.isValid()){
          repo.add(vehicle);
          print('Fordon skapat!');
        } else {
          print('Ogiltigt fordon.');
        }
        break;
      case '2':
        for (var vehicle in repo.getAll()) {
          print(vehicle);
        }
        break;
      case '3':
        print('Ange ID för fordonet som ska uppdateras:');
        var id = int.tryParse(stdin.readLineSync()?.trim() ?? '') ?? 0;
        if (id >= 0 && id < repo.getAll().length) {
          print('Ange nytt registreringsnummer:');
          var registreringsnummer = stdin.readLineSync()?.trim() ?? '';
          print('Ange ny typ:');
          var typ = stdin.readLineSync()?.trim() ?? '';
          print('Ange ownerns namn:');
          var ownerNamn = stdin.readLineSync()?.trim() ?? '';
          print('Ange ownerns personnummer:');
          var ownerPersonnummer = stdin.readLineSync()?.trim() ?? '';
          var owner = Person(namn: ownerNamn, personnummer: ownerPersonnummer);
          repo.update(
              Vehicle(
                  registreringsnummer: registreringsnummer,
                  typ: typ,
                  owner: owner),
              id);
          print('Fordon uppdaterat!');
        } else {
          print('Ogiltigt ID.');
        }
        break;
      case '4':
        print('Ange ID för fordonet som ska tas bort:');
        var id = int.tryParse(stdin.readLineSync()?.trim() ?? '') ?? 0;
        if (id >= 0 && id < repo.getAll().length) {
          repo.delete(id);
          print('Fordon borttaget!');
        } else {
          print('Ogiltigt ID.');
        }
        break;
      case '5':
        return;
      default:
        print('Ogiltigt val. Försök igen.');
    }
  }
}