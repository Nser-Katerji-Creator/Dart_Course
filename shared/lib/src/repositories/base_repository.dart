abstract class BaseRepository<T> {
  /// Creates a new item.
  Future<void> create(T item);

  /// Retrieves all items.
  Future<List<T>> getAll();

  /// Retrieves an item by its ID.
  Future<T?> getById(String id);

  /// Updates an existing item.
  Future<void> update(String id, T item);

  /// Deletes an item by its ID.
  Future<void> delete(String id);
}