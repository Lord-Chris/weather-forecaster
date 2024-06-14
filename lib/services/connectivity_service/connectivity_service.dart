import 'dart:async';
import 'dart:io';

import 'i_connectivity_service.dart';

class ConnectivityService extends IConnectivityService {
  ConnectivityService() {
    _connectionSubscription = streamInternetConnection().listen((event) {
      _connectionController.add(event);
    });
  }

  StreamSubscription? _connectionSubscription;
  bool hasConnection = false;
  final _connectionController = StreamController<bool>.broadcast();
  @override
  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }
    return hasConnection;
  }

  Stream<bool> streamInternetConnection() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      final res = await checkInternetConnection();
      _connectionController.add(res);
      yield res;
    }
  }

  @override
  Future<void> dispose() async {
    await _connectionSubscription?.cancel();
    await _connectionController.close();
  }

  @override
  Stream<bool> get connectionStream => _connectionController.stream.distinct();
}
