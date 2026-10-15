import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/core/telemetry/_telemetry.dart';
import '../../helpers/in_memory_exporter.dart';

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

  test('observe turns busy on during the work and off after', () async {
    var busyDuringWork = false;

    await viewModel.observe(() async {
      busyDuringWork = viewModel.isBusy;
    });

    expect(busyDuringWork, true);
    expect(viewModel.isBusy, false);
  });

  test('observe makes its span current for the work inside', () async {
    await viewModel.observe(() async {
      await Future<void>.delayed(Duration.zero);
      telemetry.startSpan('inner').end();
    });

    final inner = exporter.spans.firstWhere((s) => s.name == 'inner');
    final observed =
        exporter.spans.firstWhere((s) => s.name == '_TestViewModel');
    expect(inner.parentSpanId, observed.spanId);
  });

  test('observe records the error type, ends the span and rethrows', () async {
    await expectLater(
      viewModel.observe(() async => throw const FormatException('secret')),
      throwsFormatException,
    );

    final span = exporter.spans.single;
    expect(span.errorType, 'FormatException');
    expect(viewModel.isBusy, false);
  });
}
