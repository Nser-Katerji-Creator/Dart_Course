import 'package:shared/shared.dart';
// ignore: implementation_imports
import 'package:sqlite3/src/ffi/api.dart';
import '../database.dart';

class SqliteParkingSpaceRepository implements ParkingSpaceRepository {
  final DatabaseHelper dbHelper;

  SqliteParkingSpaceRepository(this.dbHelper);

  @override
  Future<int> create(ParkingSpace parkingSpace) async {
    final db = dbHelper.database;
    final result = await db.insert('parkingspaces', {
      'address': parkingSpace.address,
      'pricePerHour': parkingSpace.pricePerHour,
    });

    return result;
  }

  @override
  Future<List<ParkingSpace>> getAll() async {
    final db = dbHelper.database;
    final result = db.select('SELECT * FROM parkingspaces;');
    return result.map((row) => ParkingSpace.fromJson(row)).toList();
  }

  @override
  Future<ParkingSpace?> getById(String id) async {
    final db = dbHelper.database;
    final result = db.select('SELECT * FROM parkingspaces WHERE id = ?;', [id]);
    if (result.isNotEmpty) {
      return ParkingSpace.fromJson(result.first);
    }
    return null;
  }

  @override
  Future<void> update(String id, ParkingSpace parkingSpace) async {
    final db = dbHelper.database;
    db.execute('''
      UPDATE parkingspaces
      SET address = ?, pricePerHour = ?
      WHERE id = ?;
    ''', [parkingSpace.address, parkingSpace.pricePerHour, int.parse(id)]);
  }

  @override
  Future<void> delete(String id) async {
    final db = dbHelper.database;
    db.execute('DELETE FROM parkingspaces WHERE id = ?;', [int.parse(id)]);
  }
}

extension on Database {
  insert(String s, Map<String, Object> map) {}
}