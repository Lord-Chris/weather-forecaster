import 'package:dio/dio.dart';

import '../app/_app.dart';
import '../telemetry/_telemetry.dart';

/// One span per HTTP request, parented to the current span.
///
/// Records the method, the URL without its query string, the status code and
/// the error type. Never the body, headers, query or error message.
class TelemetryInterceptor extends Interceptor {
  static const _spanKey = 'telemetry.span';

  TelemetryInterceptor();

  final _telemetry = locator<Telemetry>();

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

  // TODO(lab-2.1) Derive instead of hand-writing: record `http.client.requests`
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final span = response.requestOptions.extra[_spanKey] as Span?;
    span?.setAttribute('http.status_code', response.statusCode);
    span?.end();
    _recordRequest(response.requestOptions, response.statusCode);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final span = err.requestOptions.extra[_spanKey] as Span?;
    span?.setAttribute('http.status_code', err.response?.statusCode);
    span?.setAttribute('error.type', err.type.name);
    span?.setError(err);
    span?.end();
    _recordRequest(err.requestOptions, err.response?.statusCode);
    handler.next(err);
  }

  /// One counter for every request, tagged by method and status class (2xx,
  /// 4xx, 5xx, or `error` when no response came back). Rate and error rate
  /// both come from it.
  void _recordRequest(RequestOptions options, int? statusCode) {
    _telemetry.counter('http.client.requests', {
      'method': options.method,
      'status_class': statusCode == null ? 'error' : '${statusCode ~/ 100}xx',
    });
  }
}
