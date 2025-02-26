import '../models/Person.dart';
import 'repository.dart';

class PersonRepository extends Repository<Person> {
   List<Person> _persons = [];
  static final PersonRepository _instance = PersonRepository._internal();

  factory PersonRepository() {
    return _instance;
  }

  PersonRepository._internal();

  void add(Person person) {
    if (person.isValid()) {
      _persons.add(person);
    } else {
      throw Exception('Invalid person data. Please Check you data it should not be null and personnummer should be exactly 10 digits');
    }
  }
List<Person> getAll() {
    return _persons;
  }

  @override
  Person getById(int personnummer) {
    return _persons.firstWhere((p) => p.personnummer == personnummer.toString(),
        orElse: () => throw Exception('Person not found.'));
  }

    @override
  void update(Person item, int id) {
    if (item.isValid()) {
     _persons[id] = item;
    } else {
      throw Exception('Invalid person data.');
    }
  }

  @override
  void delete(int personnummer) {
    _persons.removeWhere((p) => p.personnummer == personnummer.toString());
  }

  List<Person> searchByName(String name) {
    return _persons.where((p) => p.namn.contains(name)).toList();
  }
}