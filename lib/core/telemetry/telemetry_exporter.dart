import 'span.dart';
import 'telemetry_record.dart';

/// Where telemetry goes. Swap the exporter to change provider; nothing else
/// in the app changes.
abstract class TelemetryExporter {
  void exportLog(LogRecord record);
  void exportMetric(MetricRecord record);
  void exportSpan(Span span);
}

/// Prints everything to the console. The default.
class ConsoleExporter implements TelemetryExporter {
  final void Function(String line) _sink;

  ConsoleExporter([void Function(String line)? sink])
      : _sink = sink ?? _defaultSink;

  // ignore: avoid_print
  static void _defaultSink(String line) => print(line);

  @override
  void exportLog(LogRecord r) {
    _sink('[LOG ${r.level.name}] ${r.message} ${r.fields}'
        '${r.traceId == null ? '' : ' trace=${r.traceId} span=${r.spanId}'}');
    final trace = r.stackTrace;
    if (trace != null) {
      // The top frames are enough to find the failing call.
      final frames = trace.toString().trim().split('\n').take(maxStackFrames);
      _sink(frames.map((line) => '    $line').join('\n'));
    }
  }

  /// How many stack frames are printed under an error log.
  static const maxStackFrames = 8;

  @override
  void exportMetric(MetricRecord r) =>
      _sink('[METRIC ${r.kind.name}] ${r.name}=${r.value} ${r.tags}');

  @override
  void exportSpan(Span s) => _sink(
      '[SPAN] ${s.name} trace=${s.traceId} span=${s.spanId} '
      'parent=${s.parentSpanId} ${s.duration.inMilliseconds}ms '
      '${s.attributes}${s.errorType == null ? '' : ' error=${s.errorType}'}');
}

/// Keeps everything in memory. Use it in tests.
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
