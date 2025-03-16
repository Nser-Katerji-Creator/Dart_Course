import 'package:shared/shared.dart';

class InMemoryVehicleRepository implements VehicleRepository {
  final Map<String?, Vehicle> _vehicles = {};

  @override
  Future<void> create(Vehicle vehicle) async {
    _vehicles[vehicle.registreringsnummer] = vehicle;
  }

  @override
  Future<List<Vehicle>> getAll() async {
    return _vehicles.values.toList();
  }

  @override
  Future<Vehicle?> getById(String id) async {
    return _vehicles[id];
  }

  @override
  Future<void> update(String id, Vehicle vehicle) async {
    if (_vehicles.containsKey(id)) {
      _vehicles[id] = vehicle;
    } else {
      throw Exception('Vehicle not found');
    }
  }

  @override
  Future<void> delete(String id) async {
    _vehicles.remove(id);
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