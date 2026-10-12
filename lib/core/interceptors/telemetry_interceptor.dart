import 'package:dio/dio.dart';

import '../telemetry/_telemetry.dart';

/// One span per HTTP request, parented to the current span.
///
/// Records the method, the URL without its query string, the status code and
/// the error type. Never the body, headers, query or error message.
class TelemetryInterceptor extends Interceptor {
  static const _spanKey = 'telemetry.span';

  final ITelemetry _telemetry;

  TelemetryInterceptor([ITelemetry? telemetry])
      : _telemetry = telemetry ?? Telemetry.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_spanKey] = _telemetry.startSpan(
      'http ${options.method}',
      attributes: {
        'http.method': options.method,
        'http.url': TelemetrySanitizer.url(options.uri),
      },
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final span = response.requestOptions.extra[_spanKey] as Span?;
    span?.setAttribute('http.status_code', response.statusCode);
    span?.end();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final span = err.requestOptions.extra[_spanKey] as Span?;
    span?.setAttribute('http.status_code', err.response?.statusCode);
    span?.setAttribute('error.type', err.type.name);
    span?.setError(err);
    span?.end();
    handler.next(err);
  }
}
