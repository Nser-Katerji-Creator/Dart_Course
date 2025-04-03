import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';

class VehicleRepository {
  final String baseUrl;
  final http.Client client;

  VehicleRepository({
    required this.baseUrl,
    required this.client,
  });

  Future<List<Vehicle>> getAll() async {
    final response = await client.get(Uri.parse('$baseUrl/vehicles'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Vehicle.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load vehicles');
    }
  }

  Future<List<Vehicle>> getByOwnerId(String ownerId) async {
    final allVehicles = await getAll();
    return allVehicles.where((vehicle) => vehicle.ownerId == ownerId).toList();
  }

  Future<Vehicle?> getByRegistrationNumber(String registrationNumber) async {
    final response = await client.get(Uri.parse('$baseUrl/vehicles/$registrationNumber'));
    if (response.statusCode == 200) {
      return Vehicle.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load vehicle');
    }
  }

  Future<void> create(Vehicle vehicle) async {
    final response = await client.post(
      Uri.parse('$baseUrl/vehicles'),
      body: jsonEncode(vehicle.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create vehicle');
    }
  }

  Future<void> update(String registrationNumber, Vehicle vehicle) async {
    final response = await client.put(
      Uri.parse('$baseUrl/vehicles/$registrationNumber'),
      body: jsonEncode(vehicle.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update vehicle');
    }
  }

  Future<void> delete(String registrationNumber) async {
    final response = await client.delete(Uri.parse('$baseUrl/vehicles/$registrationNumber'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete vehicle');
    }
  }
}
