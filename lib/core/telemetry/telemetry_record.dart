/// Severity of a [LogRecord].
enum TelemetryLevel { debug, info, warning, error }

/// A structured log line.
class LogRecord {
  final TelemetryLevel level;
  final String message;
  final Map<String, Object?> fields;
  final String? traceId;
  final String? spanId;
  final DateTime time;

  LogRecord({
    required this.level,
    required this.message,
    this.fields = const {},
    this.traceId,
    this.spanId,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

/// A single metric data point.
class MetricRecord {
  final String name;
  final num value;
  final MetricKind kind;
  final Map<String, Object?> tags;

  const MetricRecord({
    required this.name,
    required this.value,
    required this.kind,
    this.tags = const {},
  });
}

enum MetricKind { counter, timing, gauge }
