import 'dart:async';
import 'dart:math';

import 'i_telemetry.dart';
import 'span.dart';
import 'telemetry_exporter.dart';
import 'telemetry_record.dart';
import 'telemetry_sanitizer.dart';

/// Static facade over an [ITelemetry] instance, for Lab 1 and for code that
/// cannot be injected. Prefer injecting [ITelemetry]. Tests can swap the
/// instance with [Telemetry.setInstance].
class Telemetry {
  Telemetry._();

  static ITelemetry _instance = TelemetryImpl();

  static ITelemetry get instance => _instance;

  static void setInstance(ITelemetry telemetry) => _instance = telemetry;

  static void log(
    TelemetryLevel level,
    String message, [
    Map<String, Object?> fields = const {},
  ]) =>
      _instance.log(level, message, fields);

  static void counter(String name, [Map<String, Object?> tags = const {}]) =>
      _instance.counter(name, tags);

  static void timing(String name, Duration duration,
          [Map<String, Object?> tags = const {}]) =>
      _instance.timing(name, duration, tags);

  static Span startSpan(
    String name, {
    Span? parent,
    Map<String, Object?> attributes = const {},
  }) =>
      _instance.startSpan(name, parent: parent, attributes: attributes);

  static Span? get current => _instance.current;
}

/// Default [ITelemetry]. Adds the attendee tag to every record and applies
/// the privacy rules before handing data to the exporter.
class TelemetryImpl implements ITelemetry {
  static const attendee =
      String.fromEnvironment('ATTENDEE', defaultValue: 'unknown');
  static final _spanKey = Object();
  static final _random = Random();

  final TelemetryExporter _exporter;
  final String _attendee;

  TelemetryImpl({TelemetryExporter? exporter, String? attendee})
      : _exporter = exporter ?? ConsoleExporter(),
        _attendee = attendee ?? TelemetryImpl.attendee;

  // ---- ITelemetry -----------------------------------------------------

  @override
  void log(
    TelemetryLevel level,
    String message, [
    Map<String, Object?> fields = const {},
  ]) {
    final span = current;
    _exporter.exportLog(LogRecord(
      level: level,
      message: message,
      fields: {...TelemetrySanitizer.attributes(fields), 'attendee': _attendee},
      traceId: span?.traceId,
      spanId: span?.spanId,
    ));
  }

  @override
  void counter(String name, [Map<String, Object?> tags = const {}]) =>
      _emit(name, 1, MetricKind.counter, tags);

  @override
  void timing(String name, Duration duration,
          [Map<String, Object?> tags = const {}]) =>
      _emit(name, duration.inMilliseconds, MetricKind.timing, tags);

  @override
  void metric(String name, num value, [Map<String, Object?> tags = const {}]) =>
      _emit(name, value, MetricKind.gauge, tags);

  void _emit(
      String name, num value, MetricKind kind, Map<String, Object?> tags) {
    _exporter.exportMetric(MetricRecord(
      name: name,
      value: value,
      kind: kind,
      tags: {...TelemetrySanitizer.attributes(tags), 'attendee': _attendee},
    ));
  }

  @override
  Span startSpan(
    String name, {
    Span? parent,
    Map<String, Object?> attributes = const {},
  }) {
    final p = parent ?? current;
    return Span(
      name: name,
      traceId: p?.traceId ?? _id(16),
      spanId: _id(8),
      parentSpanId: p?.spanId,
      attributes: {...attributes, 'attendee': _attendee},
      onEnd: _exporter.exportSpan,
    );
  }

  @override
  Span? get current => Zone.current[_spanKey] as Span?;

  @override
  T runWith<T>(Span span, T Function() body) =>
      runZoned(body, zoneValues: {_spanKey: span});

  static String _id(int bytes) => List.generate(
          bytes, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'))
      .join();
}
