/// An abstract class representing a connectivity service.
abstract class IConnectivityService {
  /// A stream that emits a boolean value indicating the connection status.
  Stream<bool> get connectionStream;

  /// Checks if there is an active internet connection.
  Future<bool> checkInternetConnection();
}
