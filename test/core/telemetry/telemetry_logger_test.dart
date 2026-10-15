import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/core/telemetry/_telemetry.dart';

void main() {
  late InMemoryExporter exporter;
  late TelemetryImpl telemetry;

  setUp(() {
    exporter = InMemoryExporter();
    telemetry = TelemetryImpl(exporter: exporter, attendee: 'tester');
  });

  test('d, i, w and e log at their own level', () {
    telemetry.log.d('debug');
    telemetry.log.i('info');
    telemetry.log.w('warning');
    telemetry.log.e('error');

    expect(exporter.logs.map((l) => l.level), [
      TelemetryLevel.debug,
      TelemetryLevel.info,
      TelemetryLevel.warning,
      TelemetryLevel.error,
    ]);
    expect(exporter.logs.map((l) => l.message),
        ['debug', 'info', 'warning', 'error']);
  });

  test('fields get the attendee tag and the privacy rules', () {
    telemetry.log.i('fetched', {'city_id': '1', 'city': 'Lagos', 'appid': 'k'});

    expect(
      exporter.logs.single.fields,
      {'city_id': '1', 'attendee': 'tester'},
    );
  });

  test('the explicit-level call form still works', () {
    telemetry.log(TelemetryLevel.warning, 'slow', {'duration_ms': 900});

    final record = exporter.logs.single;
    expect(record.level, TelemetryLevel.warning);
    expect(record.fields['duration_ms'], 900);
  });

  test('a log inside a span carries its trace and span ids', () {
    final span = telemetry.startSpan('work');

    telemetry.runWith(span, () => telemetry.log.i('inside'));

    expect(exporter.logs.single.traceId, span.traceId);
    expect(exporter.logs.single.spanId, span.spanId);
  });
}
