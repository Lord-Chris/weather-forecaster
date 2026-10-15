import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'span.dart';
import 'telemetry_exporter.dart';
import 'telemetry_record.dart';

/// The app's exporter. It always prints to the console, and also sends to
/// Sentry when a `SENTRY_DSN` is set and the build is not a debug build, or
/// [sendOnDebugMode] is on (`--dart-define=SEND_ON_DEBUG=true`).
class SentryExporter implements TelemetryExporter {
  static const dsn = String.fromEnvironment('SENTRY_DSN');
  static const sendOnDebugMode = bool.fromEnvironment('SEND_ON_DEBUG');

  static bool get isSending =>
      dsn.isNotEmpty && (!kDebugMode || sendOnDebugMode);

  /// Options for `SentryFlutter.init`.
  static void configure(SentryFlutterOptions options) {
    options
      ..dsn = dsn
      ..enableLogs = true
      ..traceLifecycle = SentryTraceLifecycle.stream
      ..tracesSampleRate = 1.0;
  }

  final _console = ConsoleExporter();

  // Spans arrive when they end, children first. Hold them per trace and send
  // the whole trace, parents first, when its root span ends.
  final _pending = <String, List<Span>>{};

  @override
  void exportLog(LogRecord r) {
    _console.exportLog(r);
    if (!isSending) return;

    final attributes = _attributes(r.fields);
    switch (r.level) {
      case TelemetryLevel.debug:
        Sentry.logger.debug(r.message, attributes: attributes);
      case TelemetryLevel.info:
        Sentry.logger.info(r.message, attributes: attributes);
      case TelemetryLevel.warning:
        Sentry.logger.warn(r.message, attributes: attributes);
      case TelemetryLevel.error:
        Sentry.logger.error(r.message, attributes: attributes);
        // Also an issue, grouped by the stack trace.
        Sentry.captureException(r.message, stackTrace: r.stackTrace);
    }
  }

  @override
  void exportMetric(MetricRecord r) {
    _console.exportMetric(r);
    if (!isSending) return;

    final attributes = _attributes(r.tags);
    switch (r.kind) {
      case MetricKind.counter:
        Sentry.metrics.count(r.name, r.value.toInt(), attributes: attributes);
      case MetricKind.timing:
        Sentry.metrics.distribution(r.name, r.value.toDouble(),
            unit: SentryMetricUnit.millisecond, attributes: attributes);
      case MetricKind.gauge:
        Sentry.metrics
            .gauge(r.name, r.value.toDouble(), attributes: attributes);
    }
  }

  @override
  void exportSpan(Span span) {
    _console.exportSpan(span);
    if (!isSending) return;

    _pending.putIfAbsent(span.traceId, () => []).add(span);
    if (span.parentSpanId != null) return;

    final spans = _pending.remove(span.traceId)!
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final sent = <String, SentrySpanV2>{};
    for (final s in spans) {
      final sentrySpan = HubAdapter().startInactiveSpan(
        s.name,
        parentSpan: sent[s.parentSpanId],
        startTimestamp: s.startTime,
        attributes: _attributes(s.attributes),
      );
      if (s.errorType != null) sentrySpan.status = SentrySpanStatusV2.error;
      sentrySpan.end(endTimestamp: s.endTime);
      sent[s.spanId] = sentrySpan;
    }
  }

  static Map<String, SentryAttribute> _attributes(Map<String, Object?> input) =>
      {
        for (final e in input.entries)
          if (e.value != null)
            e.key: switch (e.value) {
              bool v => SentryAttribute.bool(v),
              int v => SentryAttribute.int(v),
              double v => SentryAttribute.double(v),
              final v => SentryAttribute.string(v.toString()),
            },
      };
}
