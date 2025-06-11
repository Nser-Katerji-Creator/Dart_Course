import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';
import 'dart:convert';

class HttpParkingSpaceRepository implements ParkingSpaceRepository {
  final http.Client client;

  HttpParkingSpaceRepository(this.client);

  @override
  Future<void> create(ParkingSpace parkingSpace) async {
    final response = await client.post(
      Uri.parse('http://localhost:8080/parkingspaces'),
      body: jsonEncode(parkingSpace.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create parking space');
    }
  }

  @override
  Future<List<ParkingSpace>> getAll() async {
    final response = await client.get(Uri.parse('http://localhost:8080/parkingspaces'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ParkingSpace.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load parking spaces');
    }
  }

  @override
  Future<ParkingSpace?> getById(String id) async {
    final response = await client.get(Uri.parse('http://localhost:8080/parkingspaces/$id'));
    if (response.statusCode == 200) {
      return ParkingSpace.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load parking space');
    }
  }

  @override
  Future<void> update(String id, ParkingSpace parkingSpace) async {
    final response = await client.put(
      Uri.parse('http://localhost:8080/parkingspaces/$id'),
      body: jsonEncode(parkingSpace.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update parking space');
    }
  }

  @override
  Future<void> delete(String id) async {
    final response = await client.delete(Uri.parse('http://localhost:8080/parkingspaces/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete parking space');
    }
  }
  
  @override
  Future<ParkingSpace?> getBypersonalNumber(String personalNumber) {
    // TODO: implement getBypersonalNumber
    throw UnimplementedError();
  }
  
  @override
  Future<void> updateBypersonalNumber(String personalNumber, ParkingSpace item) {
    // TODO: implement updateBypersonalNumber
    throw UnimplementedError();
  }
}