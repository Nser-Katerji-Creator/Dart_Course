import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shared/shared.dart';

class PersonHandler {
  final PersonRepository repository;

  PersonHandler(this.repository);

  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      final persons = await repository.getAll();
      final jsonResponse = jsonEncode(persons.map((p) => p.toJson()).toList());
      return Response.ok(jsonResponse, headers: {'Content-Type': 'application/json'});
    });

    router.get('/<id>', (Request request, String id) async {
      final person = await repository.getById(id);
      if (person != null) {
        return Response.ok(jsonEncode(person.toJson()), headers: {'Content-Type': 'application/json'});
      } else {
        return Response.notFound('Person not found');
      }
    });

    router.post('/', (Request request) async {
      final body = await request.readAsString();
      final json = jsonDecode(body);
      final person = Person.fromJson(json);
      await repository.create(person);
      return Response.ok('Person created', headers: {'Content-Type': 'application/json'});
    });

    router.put('/<id>', (Request request, String id) async {
      try{
        print('Updating person with id: $id'); // Debugging line
        final body = await request.readAsString();
        final json = jsonDecode(body);
        final person = Person.fromJson(json);
        await repository.update(id, person);
        return Response.ok('Person updated', headers: {'Content-Type': 'application/json'});
      } catch (e) {
        print('Error updating person: $e'); // Debugging line
        return Response.notFound('Person not found');
      }
     });

    router.delete('/<id>', (Request request, String id) async {
      await repository.delete(id);
      return Response.ok('Person deleted', headers: {'Content-Type': 'application/json'});
    });

    return router;
  }
}