import 'package:shared/shared.dart';


class InMemoryParkingSpaceRepository implements ParkingSpaceRepository {
  final Map<String, ParkingSpace> _parkingSpaces = {};

  @override
  Future<void> create(ParkingSpace parkingSpace) async {
    _parkingSpaces[parkingSpace.id] = parkingSpace;
  }

  @override
  Future<List<ParkingSpace>> getAll() async {
    return _parkingSpaces.values.toList();
  }

  @override
  Future<ParkingSpace?> getById(String id) async {
    return _parkingSpaces[id];
  }

  @override
  Future<void> update(String id, ParkingSpace parkingSpace) async {
    if (_parkingSpaces.containsKey(id)) {
      _parkingSpaces[id] = parkingSpace;
    } else {
      throw Exception('Parking space not found');
    }
  }

  @override
  Future<void> delete(String id) async {
    _parkingSpaces.remove(id);
  }
}