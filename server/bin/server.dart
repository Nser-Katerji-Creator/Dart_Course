import 'package:server/handlers/parking_handler.dart';
import 'package:server/handlers/parking_space_handler.dart';
import 'package:server/handlers/person_handler.dart';
import 'package:server/handlers/vehicle_handler.dart';
import 'package:server/repositories/sql_parking_repository.dart';
import 'package:server/repositories/sql_parking_space_repository.dart';
import 'package:server/repositories/sql_person_repository.dart';
import 'package:server/repositories/sql_vehicle_repository.dart';
import 'package:shelf/shelf.dart';
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

Response addCorsHeaders(Response response) {
  return response.change(headers: {
    'Access-Control-Allow-Origin': '*', // Allow all origins
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS', // Allowed methods
    'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token', // Allowed headers
    'Access-Control-Allow-Credentials': 'true', // Allow credentials (if needed)
  });
}

  // Middleware to add CORS headers
final handler = Pipeline()
    .addMiddleware((innerHandler) {
      return (request) async {
        if (request.method == 'OPTIONS') {
          // Respond to preflight OPTIONS request
          return Response.ok('', headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
            'Access-Control-Allow-Credentials': 'true',
          });
        }

        // Handle other requests
        final response = await innerHandler(request);
        return addCorsHeaders(response);
      };
    })
      .addHandler(app.call);
      
  final server = await io.serve(handler, 'localhost', 8080);
  print('Server running on localhost:${server.port}');
}