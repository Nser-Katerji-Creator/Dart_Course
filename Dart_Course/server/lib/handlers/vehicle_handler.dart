import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shared/shared.dart';

class VehicleHandler {
  final VehicleRepository repository;

  VehicleHandler(this.repository);

  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      final vehicles = await repository.getAll();
      final jsonResponse = jsonEncode(vehicles.map((v) => v.toJson()).toList());
      return Response.ok(jsonResponse, headers: {'Content-Type': 'application/json'});
    });

    router.get('/<registreringsnummer>', (Request request, String registreringsnummer) async {
      final vehicle = await repository.getById(registreringsnummer);
      if (vehicle != null) {
        return Response.ok(jsonEncode(vehicle.toJson()), headers: {'Content-Type': 'application/json'});
      } else {
        return Response.notFound('Vehicle not found');
      }
    });

    router.post('/', (Request request) async {
      final body = await request.readAsString();
      final json = jsonDecode(body);
      final vehicle = Vehicle.fromJson(json);
      await repository.create(vehicle);
      return Response.ok('Vehicle created', headers: {'Content-Type': 'application/json'});
    });

    router.put('/<registreringsnummer>', (Request request, String registreringsnummer) async {
      final body = await request.readAsString();
      final json = jsonDecode(body);
      final vehicle = Vehicle.fromJson(json);
      try {
        await repository.update(registreringsnummer, vehicle);
        return Response.ok('Vehicle updated', headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.notFound('Vehicle not found');
      }
    });

    router.delete('/<registreringsnummer>', (Request request, String registreringsnummer) async {
      await repository.delete(registreringsnummer);
      return Response.ok('Vehicle deleted', headers: {'Content-Type': 'application/json'});
    });

    return router;
  }
}