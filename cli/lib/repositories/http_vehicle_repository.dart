import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';
import 'dart:convert';

class HttpVehicleRepository implements VehicleRepository {
  final http.Client client;

  HttpVehicleRepository(this.client);

  @override
  Future<void> create(Vehicle vehicle) async {
    final response = await client.post(
      Uri.parse('http://localhost:8080/vehicles'),
      body: jsonEncode(vehicle.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create vehicle');
    }
  }

  @override
  Future<List<Vehicle>> getAll() async {
    final response = await client.get(Uri.parse('http://localhost:8080/vehicles'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Vehicle.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load vehicles');
    }
  }

  @override
  Future<Vehicle?> getById(String id) async {
    final response = await client.get(Uri.parse('http://localhost:8080/vehicles/$id'));
    if (response.statusCode == 200) {
      return Vehicle.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load vehicle');
    }
  }

  @override
  Future<void> update(String id, Vehicle vehicle) async {
    final response = await client.put(
      Uri.parse('http://localhost:8080/vehicles/$id'),
      body: jsonEncode(vehicle.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update vehicle');
    }
  }

  @override
  Future<void> delete(String id) async {
    final response = await client.delete(Uri.parse('http://localhost:8080/vehicles/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete vehicle');
    }
  }
}