import 'package:shared/shared.dart';
import '../database.dart';

class SqlitePersonRepository implements PersonRepository {
  final DatabaseHelper dbHelper;

  SqlitePersonRepository(this.dbHelper);

  @override
  Future<int> create(Person person) async {
    final db = dbHelper.database;
    db.execute('''
      INSERT INTO persons (name, personnummer)
      VALUES (?, ?);
    ''', [person.name, person.personalNumber]);

    final result = db.select('SELECT last_insert_rowid() as id;');
    return result.first['id'] as int;
  }

  @override
  Future<List<Person>> getAll() async {
    final db = dbHelper.database;
    final result = db.select('SELECT * FROM persons;');
    print('Database result: $result'); // Debugging
    return result.map((row){
      print('Row: $row'); // Debugging
      if (row['name'] == null || row['personnummer'] == null) {
        throw Exception('Invalid data: name or personnummer is null');
      }
      return Person.fromJson(row);
    }).toList();
  }

  @override
  Future<Person?> getById(String id) async {
    final db = dbHelper.database;
    final result = db.select('SELECT * FROM persons WHERE id = ?;', [id]);
    if (result.isNotEmpty) {
      return Person.fromJson(result.first);
    }
    return null;
  }

  @override
  Future<void> update(String id, Person person) async {
    final db = dbHelper.database;
    db.execute('''
      UPDATE persons
      SET name = ?, personnummer = ?
      WHERE id = ?;
    ''', [person.name, person.personalNumber, id]);
  }

  @override
  Future<void> delete(String id) async {
    final db = dbHelper.database;
    db.execute('DELETE FROM persons WHERE id = ?;', [id]);
  }
  }