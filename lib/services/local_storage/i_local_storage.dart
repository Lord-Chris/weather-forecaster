/// Interface for local storage
///
/// This is the interface for the local storage service. It provides methods for
/// reading, updating, deleting, closing, and clearing values in the local storage.
abstract class ILocalStorage {
  /// Retrieves a value from the local storage.
  ///
  /// The [boxIdentifier] parameter specifies the identifier of the storage box.
  /// The [key] parameter specifies the key of the value to retrieve.
  ///
  /// Returns a [Future] that completes with the retrieved value.
  Future<dynamic> get(String boxIdentifier, {required String key});

  /// Updates a value in the local storage.
  ///
  /// The [boxIdentifier] parameter specifies the identifier of the storage box.
  /// The [key] parameter specifies the key of the value to update.
  /// The [value] parameter specifies the new value to be stored.
  ///
  /// Returns a [Future] that completes when the value is updated.
  Future<void> put(
    String boxIdentifier, {
    required String key,
    required dynamic value,
  });

  /// Deletes a value from the local storage.
  ///
  /// The [boxIdentifier] parameter specifies the identifier of the storage box.
  /// The [key] parameter specifies the key of the value to delete.
  ///
  /// Returns a [Future] that completes when the value is deleted.
  Future<void> delete(String boxIdentifier, {required String key});

  /// Clears all values in the local storage box.
  ///
  /// The [boxId] parameter specifies the identifier of the storage box to clear.
  ///
  /// Returns a [Future] that completes with the number of values cleared.
  Future<int?> clear(String boxId);
}
