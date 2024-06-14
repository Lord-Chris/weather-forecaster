import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../../core/app/_app.dart';
import '../../core/shared/models/_models.dart';
import 'i_local_storage.dart';

/// Concrete implementation of the [ILocalStorage] interface based on Hive.
class LocalStorageService implements ILocalStorage {
  final HiveInterface hive;
  LocalStorageService({
    HiveInterface? hive,
  }) : hive = hive ?? Hive;

  final _log = getLogger('LocalStorageService');

  /// Initializes the local storage service.
  ///
  /// This method initializes the local storage service by setting up the storage
  /// directory, initializing Hive, checking if the storage should be reset,
  /// clearing the storage if necessary and setting up all Hive type adapters.
  ///
  /// Throws a [DeviceAppException] if the initialization fails.
  Future<void> init() async {
    try {
      final storageDir = await path_provider.getApplicationDocumentsDirectory();
      await hive.initFlutter(storageDir.path);

      _log.i('Local storage service initialized');
    } on Exception catch (e) {
      _log.e(e);
      throw DeviceAppException(
        message: 'Failed to initialize local storage.',
        data: e,
      );
    }
  }

  /// Clears the storage by deleting the storage directory and reinitializing
  /// Hive. It then sets a value in the storage box to indicate that the storage
  /// has been cleared.
  ///
  /// Throws a [DeviceAppException] if the storage cannot be cleared.
  Future<void> _clearStorage(Directory directory) async {
    try {
      /// Clear the storage
      final dir = Directory(directory.path);
      if (dir.existsSync()) {
        await hive.deleteFromDisk();
        await dir.delete(recursive: true);
      }

      /// Reinitialize the storage
      await hive.initFlutter(directory.path);
    } catch (e) {
      _log.e(e);
      throw DeviceAppException(message: 'Failed to clear storage.', data: e);
    }
  }

  /// Deletes a value from the local storage.
  ///
  /// The [boxIdentifier] parameter specifies the identifier of the box to open in Hive.
  /// The [key] parameter specifies the key of the value to delete from the box.
  ///
  /// Throws a [DeviceAppException] if there is an error deleting the value from the storage.
  @override
  Future<void> delete(String boxIdentifier, {required String key}) async {
    try {
      final box = await hive.openBox(boxIdentifier);
      await box.delete(key);
    } catch (e) {
      _log.e(e);
      throw DeviceAppException(
        message: 'Failed to delete value from storage.',
        data: e,
      );
    }
  }

  /// Retrieves a value from the local storage.
  ///
  /// The [boxIdentifier] parameter specifies the identifier of the box to open in Hive.
  /// The [key] parameter specifies the key of the value to retrieve from the box.
  ///
  /// Returns the retrieved value from the local storage.
  ///
  /// Throws a [DeviceAppException] if there is an error retrieving the value from the storage.
  /// This can occur if there is a type error or any other general error.
  /// The [DeviceAppException] contains the error message and the error data.
  @override
  Future<dynamic> get(String boxIdentifier, {required String key}) async {
    try {
      final box = await hive.openBox(boxIdentifier);
      return box.get(key);
    } on TypeError catch (e) {
      _log.e('TYPE ERROR: $e');
      final appDocumentDir =
          await path_provider.getApplicationDocumentsDirectory();
      await _clearStorage(appDocumentDir);
      return null;
    } catch (e) {
      _log.e(e);
      throw DeviceAppException(
        message: 'Failed to get value from storage.',
        data: e,
      );
    }
  }

  /// Puts a value into the specified box in the local storage.
  ///
  /// The [boxIdentifier] parameter specifies the identifier of the box in which
  /// the value will be stored.
  /// The [key] parameter specifies the key under which the value will be stored.
  /// The [value] parameter specifies the value to be stored.
  ///
  /// Throws a [DeviceAppException] exception if the value fails to be put in storage.
  @override
  Future<void> put(
    String boxIdentifier, {
    required String key,
    dynamic value,
  }) async {
    try {
      final box = await hive.openBox(boxIdentifier);
      await box.put(key, value);
      _log.d('Successful - $key PUT $value');
      assert(box.get(key) != null);
    } catch (e) {
      _log.e(e);
      throw DeviceAppException(
          message: 'Failed to put value in storage.', data: e);
    }
  }

  @override

  /// Clears the data stored in the specified box.
  ///
  /// The [boxId] parameter specifies the identifier of the box to clear.
  ///
  /// Returns the number of items cleared.
  /// Throws a [DeviceAppException] if clearing the storage fails.
  Future<int?> clear(String boxId) async {
    try {
      final box = await hive.openBox(boxId);
      return await box.clear();
    } catch (e) {
      _log.e(e);
      throw DeviceAppException(message: 'Failed to clear storage.', data: e);
    }
  }
}
