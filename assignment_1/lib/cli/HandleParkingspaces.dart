import 'dart:io';
import '../repositories/ParkingSpaceRepository.dart';
import '../models/ParkingSpace.dart';

void handleParkingSpaces(ParkingSpaceRepository repo) {
  
  while (true) {
    print('Du har valt att hantera Parkeringsplatser.');
    print('1. Skapa ny parkeringsplats');
    print('2. Visa alla parkeringsplatser');
    print('3. Uppdatera parkeringsplats');
    print('4. Ta bort parkeringsplats');
    print('5. Gå tillbaka till huvudmenyn');
    stdout.write('Välj ett alternativ (1-5): ');

    var choice = stdin.readLineSync()?.trim();

    switch (choice) {
      case '1':
        print('Ange ID:');
        var id = stdin.readLineSync()?.trim() ?? '';
        print('Ange adress:');
        var adress = stdin.readLineSync()?.trim() ?? '';
        print('Ange pris per timme:');
        var prisPerTimme = double.tryParse(stdin.readLineSync()?.trim() ?? '') ?? 0.0;
        var parkingSpace = ParkingSpace(id: id, adress: adress, prisPerTimme: prisPerTimme);
        if (parkingSpace.isValid()) {
        repo.add(ParkingSpace(id: id, adress: adress, prisPerTimme: prisPerTimme));
        print('Parkeringsplats skapad!');
        } else {
          print('Ogiltig parkeringsplats.');
        }
        break;
      case '2':
        for (var space in repo.getAll()) {
          print(space);
        }
        break;
      case '3':
        print('Ange ID för parkeringsplatsen som ska uppdateras:');
        var id = int.tryParse(stdin.readLineSync()?.trim() ?? '') ?? 0;
        if (id >= 0 && id < repo.getAll().length) {
          print('Ange nytt ID:');
          var newId = stdin.readLineSync()?.trim() ?? '';
          print('Ange ny adress:');
          var adress = stdin.readLineSync()?.trim() ?? '';
          print('Ange nytt pris per timme:');
          var prisPerTimme = double.tryParse(stdin.readLineSync()?.trim() ?? '') ?? 0.0;
          repo.update(
              ParkingSpace(id: newId, adress: adress, prisPerTimme: prisPerTimme), id);
          print('Parkeringsplats uppdaterad!');
        } else {
          print('Ogiltigt ID.');
        }
        break;
      case '4':
        print('Ange ID för parkeringsplatsen som ska tas bort:');
        var id = int.tryParse(stdin.readLineSync()?.trim() ?? '') ?? 0;
        if (id >= 0 && id < repo.getAll().length) {
          repo.delete(id);
          print('Parkeringsplats borttagen!');
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