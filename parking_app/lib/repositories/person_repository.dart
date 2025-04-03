import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/person.dart';

class PersonRepository {
  final String baseUrl;
  final http.Client client;

  PersonRepository({
    required this.baseUrl,
    required this.client,
  });

  Future<List<Person>> getAll() async {
    final response = await client.get(Uri.parse('$baseUrl/persons'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Person.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load persons');
    }
  }

  Future<Person?> getByPersonalNumber(String personalNumber) async {
    final response = await client.get(Uri.parse('$baseUrl/persons/$personalNumber'));
    if (response.statusCode == 200) {
      return Person.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load person');
    }
  }

  Future<void> create(Person person) async {
    final response = await client.post(
      Uri.parse('$baseUrl/persons'),
      body: jsonEncode(person.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create person');
    }
  }

  Future<void> update(String personalNumber, Person person) async {
    final response = await client.put(
      Uri.parse('$baseUrl/persons/$personalNumber'),
      body: jsonEncode(person.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update person');
    }
  }

  Future<void> delete(String personalNumber) async {
    final response = await client.delete(Uri.parse('$baseUrl/persons/$personalNumber'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete person');
    }
  }
}
