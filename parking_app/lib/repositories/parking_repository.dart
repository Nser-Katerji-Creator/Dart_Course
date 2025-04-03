import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parking.dart';

class ParkingRepository {
  final String baseUrl;
  final http.Client client;

  ParkingRepository({
    required this.baseUrl,
    required this.client,
  });

  Future<List<Parking>> getAll() async {
    final response = await client.get(Uri.parse('$baseUrl/parkings'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Parking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load parkings');
    }
  }

  Future<List<Parking>> getByVehicleId(String vehicleId) async {
    final allParkings = await getAll();
    return allParkings.where((parking) => parking.vehicleId == vehicleId).toList();
  }

  Future<Parking?> getById(String id) async {
    final response = await client.get(Uri.parse('$baseUrl/parkings/$id'));
    if (response.statusCode == 200) {
      return Parking.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load parking');
    }
  }

  Future<void> create(Parking parking) async {
    final response = await client.post(
      Uri.parse('$baseUrl/parkings'),
      body: jsonEncode(parking.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create parking');
    }
  }

  Future<void> update(String id, Parking parking) async {
    final response = await client.put(
      Uri.parse('$baseUrl/parkings/$id'),
      body: jsonEncode(parking.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update parking');
    }
  }

  Future<void> endParking(String id) async {
    final parking = await getById(id);
    if (parking == null) {
      throw Exception('Parking not found');
    }
    
    final updatedParking = Parking(
      id: parking.id,
      vehicleId: parking.vehicleId,
      parkingSpaceId: parking.parkingSpaceId,
      startTime: parking.startTime,
      endTime: DateTime.now(),
    );
    
    await update(id, updatedParking);
  }

  Future<List<Parking>> getActiveParking() async {
    final allParkings = await getAll();
    return allParkings.where((parking) => parking.endTime == null).toList();
  }

  Future<List<Parking>> getParkingHistory() async {
    final allParkings = await getAll();
    return allParkings.where((parking) => parking.endTime != null).toList();
  }

  Future<List<Parking>> sortByStartTime(List<Parking> parkings, {bool ascending = true}) {
    parkings.sort((a, b) => ascending 
      ? a.startTime.compareTo(b.startTime)
      : b.startTime.compareTo(a.startTime));
    return Future.value(parkings);
  }
}
