import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';
import 'dart:convert';

class HttpPersonRepository implements PersonRepository {
  final http.Client client;

  HttpPersonRepository(this.client);

  @override
  Future<void> create(Person person) async {
    final response = await client.post(
      Uri.parse('http://localhost:8080/persons'),
      body: jsonEncode(person.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create person');
    }
  }

  @override
  Future<List<Person>> getAll() async {
    final response = await client.get(Uri.parse('http://localhost:8080/persons'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Person.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load persons');
    }
  }

  @override
  Future<Person?> getById(String id) async {
    final response = await client.get(Uri.parse('http://localhost:8080/persons/$id'));
    if (response.statusCode == 200) {
      return Person.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load person');
    }
  }

  @override
  Future<void> update(String id, Person person) async {
    final response = await client.put(
      Uri.parse('http://localhost:8080/persons/$id'),
      body: jsonEncode(person.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update person');
    }
  }

  @override
  Future<void> delete(String id) async {
    final response = await client.delete(Uri.parse('http://localhost:8080/persons/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete person');
    }
  }
}