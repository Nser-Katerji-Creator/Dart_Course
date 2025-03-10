import 'package:shared/shared.dart';


class InMemoryParkingRepository implements ParkingRepository {
  final Map<String, Parking> _parkings = {};

  @override
  Future<void> create(Parking parking) async {
    _parkings[parking.id] = parking;
  }

  @override
  Future<List<Parking>> getAll() async {
    return _parkings.values.toList();
  }

  @override
  Future<Parking?> getById(String id) async {
    return _parkings[id];
  }

  @override
  Future<void> update(String id, Parking parking) async {
    if (_parkings.containsKey(id)) {
      _parkings[id] = parking;
    } else {
      throw Exception('Parking not found');
    }
  }

  @override
  Future<void> delete(String id) async {
    _parkings.remove(id);
  }
}