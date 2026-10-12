import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/core/telemetry/_telemetry.dart';

class _TestViewModel extends ObservedViewModel {
  _TestViewModel(super.telemetry);
}

void main() {
  late InMemoryExporter exporter;
  late TelemetryImpl telemetry;
  late _TestViewModel viewModel;

  setUp(() {
    exporter = InMemoryExporter();
    telemetry = TelemetryImpl(exporter: exporter, attendee: 'tester');
    viewModel = _TestViewModel(telemetry);
  });

  test('busy on then off produces one ended span', () {
    viewModel.setBusy(true);
    viewModel.setBusy(false);

    expect(exporter.spans.single.name, '_TestViewModel busy');
  });

  test('observe makes the span current for the work inside', () async {
    await viewModel.observe(() async {
      await Future<void>.delayed(Duration.zero);
      telemetry.startSpan('inner').end();
    });

    final inner = exporter.spans.firstWhere((s) => s.name == 'inner');
    final busy = exporter.spans.firstWhere((s) => s.name.endsWith('busy'));
    expect(inner.parentSpanId, busy.spanId);
  });

  test('errors are logged by type only', () {
    viewModel.setErrorForObject(viewModel, const FormatException('secret'));

    final log = exporter.logs.single;
    expect(log.fields['error.type'], 'FormatException');
    expect(log.fields.values.join(), isNot(contains('secret')));
  });

  test('dispose ends spans that are still open', () {
    viewModel.setBusy(true);

    viewModel.dispose();

    expect(exporter.spans.length, 1);
  });
}
