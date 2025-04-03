import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parking_space.dart';

class ParkingSpaceRepository {
  final String baseUrl;
  final http.Client client;

  ParkingSpaceRepository({
    required this.baseUrl,
    required this.client,
  });

  Future<List<ParkingSpace>> getAll() async {
    final response = await client.get(Uri.parse('$baseUrl/parkingspaces'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ParkingSpace.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load parking spaces');
    }
  }

  Future<ParkingSpace?> getById(String id) async {
    final response = await client.get(Uri.parse('$baseUrl/parkingspaces/$id'));
    if (response.statusCode == 200) {
      return ParkingSpace.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load parking space');
    }
  }

  Future<List<ParkingSpace>> search(String query) async {
    final allSpaces = await getAll();
    if (query.isEmpty) return allSpaces;
    
    query = query.toLowerCase();
    return allSpaces.where((space) => 
      space.address.toLowerCase().contains(query) || 
      space.id.toLowerCase().contains(query)
    ).toList();
  }
}
