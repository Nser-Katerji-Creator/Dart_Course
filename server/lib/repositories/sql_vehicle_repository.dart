import 'package:shared/shared.dart';
import '../database.dart';

class SqliteVehicleRepository implements VehicleRepository {
  final DatabaseHelper dbHelper;

  SqliteVehicleRepository(this.dbHelper);

  @override
  Future<int> create(Vehicle vehicle) async {

    final result = await dbHelper.insertVehicle({
      'registreringsnummer': vehicle.registrationNumber,
      'type': vehicle.type,
      'ownerId': vehicle.ownerId,
    } as Vehicle);

    return result;
  }

  @override
  Future<List<Vehicle>> getAll() async {
    final db = dbHelper.database;
    final result = db.select('SELECT * FROM vehicles;');
    return result.map((row) => Vehicle.fromJson(row)).toList();
  }

  @override
  Future<Vehicle?> getById(String id) async {
    final db = dbHelper.database;
    final result = db.select('SELECT * FROM vehicles WHERE id = ?;', [id]);
    if (result.isNotEmpty) {
      return Vehicle.fromJson(result.first);
    }
    return null;
  }

  @override
  Future<void> update(String id, Vehicle vehicle) async {
    final db = dbHelper.database;
    db.execute('''
      UPDATE vehicles
      SET registreringsnummer = ?, type = ?, ownerId = ?
      WHERE id = ?;
    ''', [vehicle.registrationNumber, vehicle.type, vehicle.ownerId, id]);
  }

  @override
  Future<void> delete(String id) async {
    final db = dbHelper.database;
    db.execute('DELETE FROM vehicles WHERE id = ?;', [id]);
  }
}