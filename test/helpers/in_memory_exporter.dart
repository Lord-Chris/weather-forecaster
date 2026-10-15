import 'package:weather_forecast/core/telemetry/_telemetry.dart';

/// Keeps everything in memory so tests can assert on what was recorded.
class InMemoryExporter implements TelemetryExporter {
  final logs = <LogRecord>[];
  final metrics = <MetricRecord>[];
  final spans = <Span>[];

  @override
  void exportLog(LogRecord record) => logs.add(record);

  @override
  void exportMetric(MetricRecord record) => metrics.add(record);

  @override
  void exportSpan(Span span) => spans.add(span);
}
