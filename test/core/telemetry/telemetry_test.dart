import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/core/telemetry/_telemetry.dart';
import '../../helpers/in_memory_exporter.dart';

void main() {
  late InMemoryExporter exporter;
  late TelemetryImpl telemetry;

  setUp(() {
    exporter = InMemoryExporter();
    telemetry = TelemetryImpl(exporter: exporter, attendee: 'tester');
  });

  group('log', () {
    test('adds the attendee tag and drops denied keys', () {
      telemetry.log(TelemetryLevel.info, 'fetched', {
        'city_id': '1',
        'city': 'Lagos',
        'appid': 'secret',
      });

      expect(
          exporter.logs.single.fields, {'city_id': '1', 'attendee': 'tester'});
    });
  });

  group('metrics', () {
    test('counter records 1 and timing records milliseconds', () {
      telemetry.counter('weather.fetch.attempts', {'source': 'remote'});
      telemetry.timing(
          'weather.fetch.duration', const Duration(milliseconds: 250));

      expect(exporter.metrics[0].value, 1);
      expect(exporter.metrics[0].kind, MetricKind.counter);
      expect(exporter.metrics[1].value, 250);
      expect(exporter.metrics[1].tags['attendee'], 'tester');
    });
  });

  group('spans', () {
    test('child span attaches to the current span across an await', () async {
      final parent = telemetry.startSpan('parent');

      await telemetry.runWith(parent, () async {
        await Future<void>.delayed(Duration.zero);
        telemetry.startSpan('child').end();
      });
      parent.end();

      final child = exporter.spans.firstWhere((s) => s.name == 'child');
      expect(child.parentSpanId, parent.spanId);
      expect(child.traceId, parent.traceId);
    });

    test('two spans started in the same zone are siblings', () async {
      final parent = telemetry.startSpan('parent');

      await telemetry.runWith(parent, () async {
        telemetry.startSpan('a').end();
        telemetry.startSpan('b').end();
      });

      expect(exporter.spans.map((s) => s.parentSpanId),
          [parent.spanId, parent.spanId]);
    });

    test('end is idempotent', () {
      final span = telemetry.startSpan('once')
        ..end()
        ..end();

      expect(span.isEnded, true);
      expect(exporter.spans.length, 1);
    });

    test('setError keeps only the error type', () {
      final span = telemetry.startSpan('failing')
        ..setError(const FormatException('secret detail'))
        ..end();

      expect(span.errorType, 'FormatException');
      expect(exporter.spans.single.attributes.values.join(),
          isNot(contains('secret')));
    });
  });

  group('traced', () {
    test('ends the span, records the error type and rethrows', () async {
      await expectLater(
        traced<void>('work', () async => throw StateError('boom'),
            telemetry: telemetry),
        throwsStateError,
      );

      expect(exporter.spans.single.errorType, 'StateError');
      expect(exporter.spans.single.isEnded, true);
    });
  });

  group('sanitizer', () {
    test('url drops the query string', () {
      expect(
        TelemetrySanitizer.url(
            Uri.parse('https://api.test/data/2.5/weather?lat=1&appid=KEY')),
        'https://api.test/data/2.5/weather',
      );
    });
  });
}
