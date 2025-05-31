import 'package:shared/shared.dart';
import '../database.dart';

class SqlitePersonRepository implements PersonRepository {
  final DatabaseHelper dbHelper;

  SqlitePersonRepository(this.dbHelper);

  @override
  Future<int> create(Person person) async {
    final db = dbHelper.database;
    db.execute('''
      INSERT INTO persons (id, name, personalNumber)
      VALUES (?, ?, ?);
    ''', [person.id, person.name, person.personalNumber]);

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
      if (row['name'] == null || row['personalNumber'] == null) {
        throw Exception('Invalid data: name or personalNumber is null');
      }
      return Person.fromJson(row);
    }).toList();
  }

   @override
  Future<Person?> getBypersonalNumber(String personalNumber) async {
    return await dbHelper.getBypersonalNumber(personalNumber);

  }

  @override
  Future<void> update(String id, Person person) async {
    final db = dbHelper.database;
    db.execute('''
      UPDATE persons
      SET name = ?, personalNumber = ?
      WHERE id = ?;
    ''', [person.name, person.personalNumber, id]);
  }

  @override
  Future<void> delete(String personalNumber) async {
    final db = dbHelper.database;
    db.execute('DELETE FROM persons WHERE personalNumber = ?;', [personalNumber]);
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
Future<void> updateBypersonalNumber(String personalNumber, Person item) async {
    final db = dbHelper.database;
    db.execute('''
      UPDATE persons
      SET name = ?
      WHERE personalNumber = ?;
    ''', [item.name, item.personalNumber]);
   // await dbHelper.updateBypersonalNumber(personalNumber,item);
  }
  }  