import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shared/shared.dart';

class ParkingHandler {
  final ParkingRepository repository;

  ParkingHandler(this.repository);

  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      final parkings = await repository.getAll();
      final jsonResponse = jsonEncode(parkings.map((p) => p.toJson()).toList());
      return Response.ok(jsonResponse, headers: {'Content-Type': 'application/json'});
    });

    router.get('/<id>', (Request request, String id) async {
      final parking = await repository.getById(id);
      if (parking != null) {
        return Response.ok(jsonEncode(parking.toJson()), headers: {'Content-Type': 'application/json'});
      } else {
        return Response.notFound('Parking not found');
      }
    });

    router.post('/', (Request request) async {
      final body = await request.readAsString();
      final json = jsonDecode(body);
      final parking = Parking.fromJson(json);
      await repository.create(parking);
      return Response.ok('Parking created', headers: {'Content-Type': 'application/json'});
    });

    router.put('/<id>', (Request request, String id) async {
      final body = await request.readAsString();
      final json = jsonDecode(body);
      final parking = Parking.fromJson(json);
      try {
        await repository.update(id, parking);
        return Response.ok('Parking updated', headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.notFound('Parking not found');
      }
    });

    router.delete('/<id>', (Request request, String id) async {
      await repository.delete(id);
      return Response.ok('Parking deleted', headers: {'Content-Type': 'application/json'});
    });

    return router;
  }
}