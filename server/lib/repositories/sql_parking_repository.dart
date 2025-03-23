import 'package:shared/shared.dart';
// ignore: implementation_imports
import 'package:sqlite3/src/ffi/api.dart';
import '../database.dart';


class SqliteParkingRepository implements ParkingRepository {
  final DatabaseHelper dbHelper;

  SqliteParkingRepository(this.dbHelper);

  @override
  Future<String> create(Parking parking) async {
    final db = dbHelper.database;
    db.execute('''
      INSERT INTO parkings (id, vehicleId, parkingSpaceId, startTime, endTime)
      VALUES (?, ?, ?, ?, ?);
    ''', [
      parking.id,
      parking.vehicleId,
      parking.parkingSpaceId,
      parking.startTime.toIso8601String(),
      parking.endTime?.toIso8601String()
    ]);
    return parking.id;
    
  }

  @override
  Future<List<Parking>> getAll() async {
    final db = dbHelper.database;
    final result = db.select('SELECT * FROM parkings;');
    print(result);
    return result.map((row) => Parking.fromJson(row)).toList();
  }

  @override
  Future<Parking?> getById(String id) async {
    final db = dbHelper.database;
    final result = db.select('SELECT * FROM parkings WHERE id = ?;', [id] );
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
      SET vehicleId = ?, parkingSpaceId = ?, startTime = ?, endTime = ?
      WHERE id = ?;
    ''', [
      parking.vehicleId,
      parking.parkingSpaceId,
      parking.startTime.toIso8601String(),
      parking.endTime?.toIso8601String(),
      id
    ]);
  }

  @override
  Future<void> delete(String id) async {
    final db = dbHelper.database;
    db.execute('DELETE FROM parkings WHERE id = ?;', [id]);
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