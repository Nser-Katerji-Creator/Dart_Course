import 'package:path/path.dart' as path;
import 'package:shared/shared.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Database get database {
    if (_database != null) return _database!;
    _database = _initDatabase();
    return _database!;
  }

  Database _initDatabase() {
    // Open or create the database file
    final dbPath = path.join(path.current, 'parking_app.db');
    final db = sqlite3.open(dbPath);

    // Create tables if they don't exist
    db.execute('''
      CREATE TABLE IF NOT EXISTS persons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        personalNumber TEXT NOT NULL
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        registreringsnummer TEXT NOT NULL,
        type TEXT NOT NULL,
        ownerId INTEGER NOT NULL,
        FOREIGN KEY (ownerId) REFERENCES persons(id)
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS parkingspaces (
        id TEXT PRIMARY KEY NOT NULL,
        address TEXT NOT NULL,
        pricePerHour REAL NOT NULL
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS parkings (
        id TEXT PRIMARY KEY NOT NULL,
        vehicleId INTEGER NOT NULL,
        parkingspaceId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        FOREIGN KEY (vehicleId) REFERENCES vehicles(id),
        FOREIGN KEY (parkingspaceId) REFERENCES parkingspaces(id)
      );
    ''');

    return db;
  }

  // CRUD operations for Person
  Future<int> insertPerson(Person person) async {
    final db = database;
    db.execute('''
      INSERT INTO persons (name, personalNumber)
      VALUES (?, ?);
    ''', [person.name, person.personalNumber]);

    return db.lastInsertRowId;
  }

  Future<List<Person>> getAllPersons() async {
    final db = database;
    final result = db.select('SELECT * FROM persons;');
    return result.map((row) => Person.fromJson(row)).toList();
  }

  Future<Person?> getPersonById(int id) async {
    final db = database;
    final result = db.select('SELECT * FROM persons WHERE id = ?;', [id]);
    if (result.isNotEmpty) {
      return Person.fromJson(result.first);
    }
    return null;
  }

  
  Future<Person?> getBypersonalNumber(String personalNumber) async {
    final db = database;
    final result = db.select('SELECT * FROM persons WHERE personalNumber = ?;', [personalNumber]);
    print('Data base result is : $result');
    if (result.isNotEmpty) {
      return Person.fromJson(result.first);
    }
    return null;
  }
  Future<void> updateBypersonalNumber(String personalNumber, Person item) async {
     final db = database;
    db.execute('''
      UPDATE persons
      SET name = ?, personalNumber = ?
      WHERE personalNumber = ?;
    ''', [item.name, item.personalNumber, personalNumber]);
  }

  Future<void> updatePerson(Person person) async {
    final db = database;
    db.execute('''
      UPDATE persons
      SET name = ?, personalNumber = ?
      WHERE personalNumber = ?;
    ''', [person.name, person.personalNumber]);
  }

  Future<void> deletePerson(int personalNumber) async {
    final db = database;
    db.execute('DELETE FROM persons WHERE id = ?;', [personalNumber]);
  }

  // CRUD operations for Vehicle
  Future<int> insertVehicle(Vehicle vehicle) async {
    final db = database;
    db.execute('''
      INSERT INTO vehicles (registreringsnummer, type, ownerId)
      VALUES (?, ?, ?);
    ''', [vehicle.registreringsnummer, vehicle.type, vehicle.ownerId]);

    return db.lastInsertRowId;
  }

  Future<List<Vehicle>> getAllVehicles() async {
    final db = database;
    final result = db.select('SELECT * FROM vehicles;');
    return result.map((row) => Vehicle.fromJson(row)).toList();
  }

  Future<Vehicle?> getVehicleById(String registreringsnummer) async {
    final db = database;
    final result = db.select('SELECT * FROM vehicles WHERE registreringsnummer = ?;', [registreringsnummer]);
    if (result.isNotEmpty) {
      return Vehicle.fromJson(result.first);
    }
    return null;
  }

  Future<void> updateVehicle(String registreringsnummer, Vehicle vehicle) async {
    final db = database;
    db.execute('''
      UPDATE vehicles
      SET type = ?, ownerId = ?
      WHERE registreringsnummer = ?;
    ''', [vehicle.registreringsnummer, vehicle.type, vehicle.ownerId, registreringsnummer]);
  }

  Future<void> deleteVehicle(int registreringsnummer) async {
    final db = database;
    db.execute('DELETE FROM vehicles WHERE registreringsnummer = ?;', [registreringsnummer]);
  }

  // CRUD operations for ParkingSpace
  Future<int> insertParkingSpace(ParkingSpace parkingSpace) async {
    final db = database;
    db.execute('''
      INSERT INTO parkingspaces (id, address, pricePerHour)
      VALUES (?, ?, ?);
    ''', [parkingSpace.id, parkingSpace.address, parkingSpace.pricePerHour]);

    return db.lastInsertRowId;
  }

  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    final db = database;
    final result = db.select('SELECT * FROM parkingspaces;');
    return result.map((row) => ParkingSpace.fromJson(row)).toList();
  }

  Future<ParkingSpace?> getParkingSpaceById(int id) async {
    final db = database;
    final result = db.select('SELECT * FROM parkingspaces WHERE id = ?;', [id]);
    if (result.isNotEmpty) {
      return ParkingSpace.fromJson(result.first);
    }
    return null;
  }

  Future<void> updateParkingSpace(ParkingSpace parkingSpace) async {
    final db = database;
    db.execute('''
      UPDATE parkingspaces
      SET address = ?, pricePerHour = ?
      WHERE id = ?;
    ''', [parkingSpace.address, parkingSpace.pricePerHour, parkingSpace.id]);
  }

  Future<void> deleteParkingSpace(int id) async {
    final db = database;
    db.execute('DELETE FROM parkingspaces WHERE id = ?;', [id]);
  }

  // CRUD operations for Parking
  Future<int> insertParking(Parking parking) async {
    final db = database;
    db.execute('''
      INSERT INTO parkings (id, vehicleId, parkingspaceId, startTime, endTime)
      VALUES (?, ?, ?, ?, ?);
    ''', [parking.id, parking.vehicleId, parking.parkingSpaceId, parking.startTime, parking.endTime]);

    return db.lastInsertRowId;
  }

  Future<List<Parking>> getAllParkings() async {
    final db = database;
    final result = db.select('SELECT * FROM parkings;');
    print(result);
    return result.map((row) => Parking.fromJson(row)).toList();
  }

  Future<Parking?> getParkingById(String id) async {
    final db = database;
    final result = db.select('SELECT * FROM parkings WHERE id = ?;', [id]);
    if (result.isNotEmpty) {
      return Parking.fromJson(result.first);
    }
    return null;
  }

  Future<void> updateParking(Parking parking) async {
    final db = database;
    db.execute('''
      UPDATE parkings
      SET vehicleId = ?, parkingspaceId = ?, startTime = ?, endTime = ?
      WHERE id = ?;
    ''', [parking.vehicleId, parking.parkingSpaceId, parking.startTime, parking.endTime, parking.id]);
  }

  Future<void> deleteParking(String id) async {
    final db = database;
    db.execute('DELETE FROM parkings WHERE id = ?;', [id]);
  }

  // Close the database when done
  void close() {
    _database?.dispose();
  }
}