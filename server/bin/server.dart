import 'package:server/handlers/parking_handler.dart';
import 'package:server/handlers/parking_space_handler.dart';
import 'package:server/handlers/person_handler.dart';
import 'package:server/handlers/vehicle_handler.dart';
import 'package:server/repositories/in_memory_parking_repository.dart';
import 'package:server/repositories/in_memory_parking_space_repository.dart';
import 'package:server/repositories/in_memory_person_repository.dart';
import 'package:server/repositories/in_memory_vehicle_repository.dart';
import 'package:server/repositories/sql_parking_repository.dart';
import 'package:server/repositories/sql_parking_space_repository.dart';
import 'package:server/repositories/sql_person_repository.dart';
import 'package:server/repositories/sql_vehicle_repository.dart';
import 'package:shared/src/repositories/parking_repository.dart';
import 'package:shared/src/repositories/parking_space_repository.dart';
import 'package:shared/src/repositories/person_repository.dart';
import 'package:shared/src/repositories/vehicle_repository.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:server/database.dart';


void main() async {
  final app = Router();
  final dbHelper = DatabaseHelper();

  final personRepository = SqlitePersonRepository(dbHelper);
  final vehicleRepository = SqliteVehicleRepository(dbHelper);
  final parkingSpaceRepository = SqliteParkingSpaceRepository(dbHelper);
  final parkingRepository = SqliteParkingRepository(dbHelper);

  app.mount('/persons', PersonHandler(personRepository).router.call);
  app.mount('/vehicles', VehicleHandler(vehicleRepository).router.call);
  app.mount('/parkingspaces', ParkingSpaceHandler(parkingSpaceRepository).router.call);
  app.mount('/parkings', ParkingHandler(parkingRepository).router.call);

  final server = await io.serve(app.call, 'localhost', 8080);
  print('Server running on localhost:${server.port}');
}