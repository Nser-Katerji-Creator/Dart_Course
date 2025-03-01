abstract class Repository<T> {
  List<T> _items = [];

  void add(T item) => _items.add(item);

  List<T> getAll() => _items;

  T getById(int id) => _items[id];

  void update(T item, int id) {
    if (id < _items.length) {
      _items[id] = item;
    }
  }

  void delete(int id) {
    if (id < _items.length) {
      _items.removeAt(id);
    }
  }
}