import 'dart:math';

import 'package:dio/dio.dart';

/// Debug-only fault injection for the silent-failure challenges.
///
/// Flags (pass with `--dart-define`):
/// - `FAULT_LATENCY_MS`: delay every request by this many milliseconds.
/// - `FAULT_FAIL_RATE`: 0-100, percent of requests that fail with a connection error.
/// - `FAULT_RETRY`: `true` makes the first attempt of each request fail, and
///   a retry follows after an extra delay. Nothing is shown to the user.
class FaultInjectionInterceptor extends Interceptor {
  static const latencyMs = int.fromEnvironment('FAULT_LATENCY_MS');
  static const failRate = int.fromEnvironment('FAULT_FAIL_RATE');
  static const retry = bool.fromEnvironment('FAULT_RETRY');
  static const retryDelayMs = 1500;

  static bool get isEnabled => latencyMs > 0 || failRate > 0 || retry;

  final Dio _dio;
  final Random _random;

  FaultInjectionInterceptor(this._dio, {Random? random})
      : _random = random ?? Random();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (latencyMs > 0) {
      await Future<void>.delayed(const Duration(milliseconds: latencyMs));
    }
    if (failRate > 0 && _random.nextInt(100) < failRate) {
      return handler.reject(
        DioException.connectionError(
          requestOptions: options,
          reason: 'injected fault',
        ),
        // Run the error interceptors too, so a telemetry span opened earlier
        // in the chain still ends.
        true,
      );
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (retry && err.requestOptions.extra['fault.retried'] != true) {
      await Future<void>.delayed(const Duration(milliseconds: retryDelayMs));
      err.requestOptions.extra['fault.retried'] = true;
      try {
        return handler.resolve(await _dio.fetch(err.requestOptions));
      } on DioException catch (e) {
        return handler.next(e);
      }
    }
    handler.next(err);
  }
}
