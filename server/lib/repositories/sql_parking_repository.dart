import 'package:shared/shared.dart';
// ignore: implementation_imports
import 'package:sqlite3/src/ffi/api.dart';
import '../database.dart';


class SqliteParkingRepository implements ParkingRepository {
  final DatabaseHelper dbHelper;

  SqliteParkingRepository(this.dbHelper);

  @override
  Future<int> create(Parking parking) async {
    final db = dbHelper.database;
    final result = await db.insert('parkings', {
      'vehicleId': parking.vehicleId,
      'parkingspaceId': parking.parkingSpaceId,
      'startTime': parking.startTime,
      'endTime': parking.endTime,
    });

    return result;
  }

  @override
  Future<List<Parking>> getAll() async {
    final db = dbHelper.database;
    final result = db.select('SELECT * FROM parkings;');
    return result.map((row) => Parking.fromJson(row)).toList();
  }

  @override
  Future<Parking?> getById(String id) async {
    final db = dbHelper.database;
    final result = db.select('SELECT * FROM parkings WHERE id = ?;', [int.parse(id)]);
    if (result.isNotEmpty) {
      return Parking.fromJson(result.first);
    }
    return null;
  }

  @override
  Future<void> update(String id, Parking parking) async {
    final db = dbHelper.database;
    db.execute('''
      UPDATE parkings
      SET vehicleId = ?, parkingspaceId = ?, startTime = ?, endTime = ?
      WHERE id = ?;
    ''', [parking.vehicleId, parking.parkingSpaceId, parking.startTime, parking.endTime, int.parse(id)]);
  }

  @override
  Future<void> delete(String id) async {
    final db = dbHelper.database;
    db.execute('DELETE FROM parkings WHERE id = ?;', [int.parse(id)]);
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
  
}

extension on Database {
  insert(String s, Map<String, Object?> map) {}
}