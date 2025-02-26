import '../models/ParkingSpace.dart';
import 'repository.dart';

class ParkingSpaceRepository extends Repository<ParkingSpace> {
  final List<ParkingSpace> _parkingSpaces = [];
  static final ParkingSpaceRepository _instance = ParkingSpaceRepository._internal();

  factory ParkingSpaceRepository() {
    return _instance;
  }

  ParkingSpaceRepository._internal();

  @override
  void add(ParkingSpace parkingSpace) {
    if (parkingSpace.isValid()) {
      _parkingSpaces.add(parkingSpace);
    } else {
      throw Exception('Invalid parking space data.');
    }
  }

  @override
  List<ParkingSpace> getAll() {
    return _parkingSpaces;
  }

  @override
  ParkingSpace getById(int id) {
    return _parkingSpaces.firstWhere((ps) => ps.id == id,
        orElse: () => throw Exception('Parking space not found.'));
  }

  @override
  void update(ParkingSpace updatedParkingSpace, int id) {
    if (updatedParkingSpace.isValid()) {
      _parkingSpaces[id] = updatedParkingSpace;
    } else {
      throw Exception('Invalid parking space data.');
    }
  }

  @override
  void delete(int id) {
    _parkingSpaces.removeAt(id);
  }
}