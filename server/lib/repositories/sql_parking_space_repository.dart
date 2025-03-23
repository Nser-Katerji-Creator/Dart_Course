import 'package:shared/shared.dart';
// ignore: implementation_imports
import 'package:sqlite3/src/ffi/api.dart';
import '../database.dart';

class SqliteParkingSpaceRepository implements ParkingSpaceRepository {
  final DatabaseHelper dbHelper;

  SqliteParkingSpaceRepository(this.dbHelper);

  @override
  Future<int> create(ParkingSpace parkingSpace) async {

    final db =  dbHelper.database;
    db.execute('''
      INSERT INTO parkingspaces (id, address, pricePerHour)
      VALUES (?, ?, ?);
    ''', [parkingSpace.id, parkingSpace.address, parkingSpace.pricePerHour]);

      final result = db.select('SELECT last_insert_rowid() as id;');
       return result.first['id'] as int;
    
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
    ''', [parkingSpace.address, parkingSpace.pricePerHour, id]);
  }

  @override
  Future<void> delete(String id) async {
    final db = dbHelper.database;
    db.execute('DELETE FROM parkingspaces WHERE id = ?;', [id]);
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

extension on Database {
  insert(String s, Map<String, Object> map) {}
}