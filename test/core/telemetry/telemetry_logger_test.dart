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

  group('stack traces', () {
    test('e keeps the stack trace as an argument', () {
      final trace = StackTrace.current;

      telemetry.log.e('load failed', {'operation': 'init'}, trace);

      final record = exporter.logs.single;
      expect(record.stackTrace, trace);
      expect(record.fields['operation'], 'init');
    });

    test('the other forms record no stack trace', () {
      telemetry.log.i('info');
      telemetry.log.e('error without one');

      expect(exporter.logs.every((l) => l.stackTrace == null), isTrue);
    });

    test('the explicit-level call form accepts one too', () {
      final trace = StackTrace.current;

      telemetry.log(TelemetryLevel.error, 'failed', {'a': 1}, trace);

      expect(exporter.logs.single.stackTrace, trace);
    });

    test('the console prints only the top frames under the error line', () {
      final lines = <String>[];
      final console = TelemetryImpl(
        exporter: ConsoleExporter(lines.add),
        attendee: 'tester',
      );
      final frames = List.generate(20, (i) => '#$i      frame$i (a.dart:$i:1)');

      console.log.e('failed', {}, StackTrace.fromString(frames.join('\n')));

      expect(lines.first, startsWith('[LOG error] failed'));
      final printed = lines.last.split('\n');
      expect(printed.length, ConsoleExporter.maxStackFrames);
      expect(printed.first, contains('frame0'));
      expect(lines.join(), isNot(contains('frame19')));
    });
  });
}
