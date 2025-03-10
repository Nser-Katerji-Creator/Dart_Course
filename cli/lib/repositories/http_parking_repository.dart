import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';
import 'dart:convert';

class HttpParkingRepository implements ParkingRepository {
  final http.Client client;

  HttpParkingRepository(this.client);

  @override
  Future<void> create(Parking parking) async {
    final response = await client.post(
      Uri.parse('http://localhost:8080/parkings'),
      body: jsonEncode(parking.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create parking');
    }
  }

  @override
  Future<List<Parking>> getAll() async {
    final response = await client.get(Uri.parse('http://localhost:8080/parkings'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Parking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load parkings');
    }
  }

  @override
  Future<Parking?> getById(String id) async {
    final response = await client.get(Uri.parse('http://localhost:8080/parkings/$id'));
    if (response.statusCode == 200) {
      return Parking.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load parking');
    }
  }

  @override
  Future<void> update(String id, Parking parking) async {
    final response = await client.put(
      Uri.parse('http://localhost:8080/parkings/$id'),
      body: jsonEncode(parking.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update parking');
    }
  }

  @override
  Future<void> delete(String id) async {
    final response = await client.delete(Uri.parse('http://localhost:8080/parkings/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete parking');
    }
  }
}