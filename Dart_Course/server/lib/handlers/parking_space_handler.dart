import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shared/shared.dart';

class ParkingSpaceHandler {
  final ParkingSpaceRepository repository;

  ParkingSpaceHandler(this.repository);

  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      final parkingSpaces = await repository.getAll();
      final jsonResponse = jsonEncode(parkingSpaces.map((ps) => ps.toJson()).toList());
      return Response.ok(jsonResponse, headers: {'Content-Type': 'application/json'});
    });

    router.get('/<id>', (Request request, String id) async {
      final parkingSpace = await repository.getById(id);
      if (parkingSpace != null) {
        return Response.ok(jsonEncode(parkingSpace.toJson()), headers: {'Content-Type': 'application/json'});
      } else {
        return Response.notFound('Parking space not found');
      }
    });

    router.post('/', (Request request) async {
      final body = await request.readAsString();
      final json = jsonDecode(body);
      final parkingSpace = ParkingSpace.fromJson(json);
      await repository.create(parkingSpace);
      return Response.ok('Parking space created', headers: {'Content-Type': 'application/json'});
    });

    router.put('/<id>', (Request request, String id) async {
      final body = await request.readAsString();
      final json = jsonDecode(body);
      final parkingSpace = ParkingSpace.fromJson(json);
      try {
        await repository.update(id, parkingSpace);
        return Response.ok('Parking space updated', headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.notFound('Parking space not found');
      }
    });

    router.delete('/<id>', (Request request, String id) async {
      await repository.delete(id);
      return Response.ok('Parking space deleted', headers: {'Content-Type': 'application/json'});
    });

    return router;
  }
}