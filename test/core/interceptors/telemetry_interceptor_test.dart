import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:weather_forecast/core/interceptors/telemetry_interceptor.dart';
import 'package:weather_forecast/core/telemetry/_telemetry.dart';

void main() {
  late InMemoryExporter exporter;
  late TelemetryImpl telemetry;
  late Dio dio;
  late DioAdapter adapter;

  setUp(() {
    exporter = InMemoryExporter();
    telemetry = TelemetryImpl(exporter: exporter, attendee: 'tester');
    dio = Dio();
    adapter = DioAdapter(dio: dio);
    dio.interceptors.add(TelemetryInterceptor(telemetry));
  });

  test('records one span with status code and no query string', () async {
    adapter.onGet('https://api.test/weather', (s) => s.reply(200, {'ok': true}),
        queryParameters: {'appid': 'KEY'});

    await dio
        .get('https://api.test/weather', queryParameters: {'appid': 'KEY'});

    final span = exporter.spans.single;
    expect(span.attributes['http.status_code'], 200);
    expect(span.attributes['http.url'], 'https://api.test/weather');
    expect(span.attributes.values.join(), isNot(contains('KEY')));
  });

  test('records the error type on failure', () async {
    adapter.onGet(
        'https://api.test/weather', (s) => s.reply(500, {'message': 'secret'}));

    await expectLater(
        dio.get('https://api.test/weather'), throwsA(isA<DioException>()));

    final span = exporter.spans.single;
    expect(span.attributes['http.status_code'], 500);
    expect(span.errorType, 'DioException');
  });

  test('parents the span to the current span', () async {
    adapter.onGet('https://api.test/weather', (s) => s.reply(200, {}));
    final parent = telemetry.startSpan('parent');

    await telemetry.runWith(parent, () => dio.get('https://api.test/weather'));

    expect(exporter.spans.single.parentSpanId, parent.spanId);
  });

  test('ends the span when a later interceptor rejects the request', () async {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) => handler.reject(
        DioException.connectionError(requestOptions: options, reason: 'x'),
        true,
      ),
    ));

    await expectLater(
        dio.get('https://api.test/weather'), throwsA(isA<DioException>()));

    expect(exporter.spans.single.isEnded, true);
    expect(exporter.spans.single.errorType, 'DioException');
  });

  group('derived metrics', () {
    test('counts the request and times it, tagged by status class', () async {
      adapter.onGet('https://api.test/weather', (s) => s.reply(200, {}));

      await dio.get('https://api.test/weather');

      final requests =
          exporter.metrics.firstWhere((m) => m.name == 'http.client.requests');
      expect(requests.kind, MetricKind.counter);
      expect(requests.tags['method'], 'GET');
      expect(requests.tags['status_class'], '2xx');
      expect(
          exporter.metrics.any((m) => m.name == 'http.client.duration'), true);
    });

    test('tags a failed response with its status class', () async {
      adapter.onGet('https://api.test/weather', (s) => s.reply(404, {}));

      await expectLater(
          dio.get('https://api.test/weather'), throwsA(isA<DioException>()));

      final requests =
          exporter.metrics.firstWhere((m) => m.name == 'http.client.requests');
      expect(requests.tags['status_class'], '4xx');
    });

    test('tags a request with no response as error', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) => handler.reject(
          DioException.connectionError(requestOptions: options, reason: 'x'),
          true,
        ),
      ));

      await expectLater(
          dio.get('https://api.test/weather'), throwsA(isA<DioException>()));

      final requests =
          exporter.metrics.firstWhere((m) => m.name == 'http.client.requests');
      expect(requests.tags['status_class'], 'error');
    });
  });
}
