import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/core/telemetry/_telemetry.dart';

void main() {
  test('by default it only prints: nothing is sent without a DSN', () {
    expect(SentryExporter.isSending, isFalse);

    // Safe to call with Sentry not initialised.
    final telemetry = TelemetryImpl(exporter: SentryExporter());
    telemetry.log.e('failed');
    telemetry.counter('hits');
    telemetry.startSpan('work').end();
  });
}
