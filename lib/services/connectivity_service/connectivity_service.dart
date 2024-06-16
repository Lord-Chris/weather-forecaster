import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/shared/models/app_exception.dart';
import 'i_connectivity_service.dart';

class ConnectivityService extends IConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  bool _mapResult(List<ConnectivityResult> result) {
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }

  @override
  Future<bool> checkInternetConnection() async {
    try {
      final status = await _connectivity.checkConnectivity();
      return _mapResult(status);
    } on Exception catch (e) {
      throw InternetAppException(data: e);
    }
  }

  @override
  Stream<bool> get connectionStream =>
      _connectivity.onConnectivityChanged.map(_mapResult);
}
