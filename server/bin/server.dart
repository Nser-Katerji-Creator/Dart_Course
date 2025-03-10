import 'package:server/handlers/parking_handler.dart';
import 'package:server/handlers/parking_space_handler.dart';
import 'package:server/handlers/person_handler.dart';
import 'package:server/handlers/vehicle_handler.dart';
import 'package:server/repositories/in_memory_parking_repository.dart';
import 'package:server/repositories/in_memory_parking_space_repository.dart';
import 'package:server/repositories/in_memory_person_repository.dart';
import 'package:server/repositories/in_memory_vehicle_repository.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';


void main() async {
  final app = Router();

  final personRepository = InMemoryPersonRepository();
  final vehicleRepository = InMemoryVehicleRepository();
  final parkingSpaceRepository = InMemoryParkingSpaceRepository();
  final parkingRepository = InMemoryParkingRepository();

  app.mount('/persons', PersonHandler(personRepository).router.call);
  app.mount('/vehicles', VehicleHandler(vehicleRepository).router.call);
  app.mount('/parkingspaces', ParkingSpaceHandler(parkingSpaceRepository).router.call);
  app.mount('/parkings', ParkingHandler(parkingRepository).router.call);

  final server = await io.serve(app.call, 'localhost', 8080);
  print('Server running on localhost:${server.port}');
}