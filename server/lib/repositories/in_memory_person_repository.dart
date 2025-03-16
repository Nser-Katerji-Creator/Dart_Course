import 'package:shared/shared.dart';


class InMemoryPersonRepository implements PersonRepository {
  final Map<String, Person> _persons = {};

  @override
  Future<void> create(Person person) async {
    _persons[person.personalNumber.toString()] = person;
  }

  @override
  Future<List<Person>> getAll() async {
    return _persons.values.toList();
  }

  @override
  Future<Person?> getById(String id) async {
    return _persons[id];
  }

  @override
  Future<void> update(String id, Person person) async {
    if (_persons.containsKey(id)) {
      _persons[id] = person;
    } else {
      throw Exception('Person not found');
    }
  }

  @override
  Future<void> delete(String id) async {
    _persons.remove(id);
  }
  
  @override
  Future<Person?> getBypersonalNumber(String personalNumber) {
    // TODO: implement getBypersonalNumber
    throw UnimplementedError();
  }
  
  @override
  Future<void> updateBypersonalNumber(String personalNumber, Person item) {
    // TODO: implement updateBypersonalNumber
    throw UnimplementedError();
  }
  
}