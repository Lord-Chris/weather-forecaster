abstract class IConnectivityService {
  Stream<bool> get connectionStream;

  Future<bool> checkInternetConnection();
  Future<void> dispose();
}
