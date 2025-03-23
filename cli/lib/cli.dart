/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';

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
  Future<Person?> getBypersonalNumber(String personalNumber) async {
    final response = await client.get(Uri.parse('http://localhost:8080/persons/$personalNumber'));
    print(response.body);
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
      throw Exception('Failed to update person: ${response.body}');
    }
  }

  @override
  Future<void> updateBypersonalNumber(String personalNumber, Person item) async {
    final response = await client.put(
      Uri.parse('http://localhost:8080/persons/$personalNumber'),
      body: jsonEncode(item.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    print(response.body);
    if (response.statusCode != 200) {
      throw Exception('CLI Failed to update person');
    }
  }

  @override
  Future<void> delete(String personalNumber) async {
    final response = await client.delete(Uri.parse('http://localhost:8080/persons/$personalNumber'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete person');
    }
  }
}

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
  Future<Vehicle?> getById(String registreringsnummer) async {
    final response = await client.get(Uri.parse('http://localhost:8080/vehicles/$registreringsnummer'));
    if (response.statusCode == 200) {
      return Vehicle.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load vehicle');
    }
  }

  @override
  Future<void> update(String registreringsnummer, Vehicle vehicle) async {
    final response = await client.put(
      Uri.parse('http://localhost:8080/vehicles/$registreringsnummer'),
      body: jsonEncode(vehicle.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update vehicle');
    }
  }

  @override
  Future<void> delete(String registreringsnummer) async {
    final response = await client.delete(Uri.parse('http://localhost:8080/vehicles/$registreringsnummer'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete vehicle');
    }
  }
  
  @override
  Future<Vehicle?> getBypersonalNumber(String personalNumber) {
    // TODO: implement getBypersonalNumber
    throw UnimplementedError();
  }
  
  @override
  Future<void> updateBypersonalNumber(String personalNumber, Vehicle item) {
    // TODO: implement updateBypersonalNumber
    throw UnimplementedError();
  }
  
}

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
      print(response.body);
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
    //print(response.body);
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
  
  @override
  Future<Parking?> getBypersonalNumber(String personalNumber) {
    // TODO: implement getBypersonalNumber
    throw UnimplementedError();
  }
  
  @override
  Future<void> updateBypersonalNumber(String personalNumber, Parking item) {
    // TODO: implement updateBypersonalNumber
    throw UnimplementedError();
  }
  
}*/
