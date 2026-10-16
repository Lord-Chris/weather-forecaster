import 'dart:async';
import 'dart:math';

import 'i_telemetry.dart';
import 'sentry_exporter.dart';
import 'span.dart';
import 'telemetry_exporter.dart';
import 'telemetry_logger.dart';
import 'telemetry_record.dart';
import 'telemetry_sanitizer.dart';

/// Default [Telemetry]. Adds the attendee tag to every record and applies
/// the privacy rules before handing data to the exporter.
class TelemetryImpl implements Telemetry {
  static const attendee =
      String.fromEnvironment('ATTENDEE', defaultValue: 'unknown');
  static final _spanKey = Object();
  static final _random = Random();

  final TelemetryExporter _exporter;
  final String _attendee;
  final _screens = <String>[];

  TelemetryImpl({TelemetryExporter? exporter, String? attendee})
      : _exporter = exporter ?? SentryExporter(),
        _attendee = attendee ?? TelemetryImpl.attendee;

  // ---- ITelemetry -----------------------------------------------------

  @override
  late final TelemetryLogger log = TelemetryLogger(_log);

  void _log(
    TelemetryLevel level,
    String message,
    Map<String, Object?> fields,
    StackTrace? stackTrace,
  ) {
    final span = current;
    _exporter.exportLog(LogRecord(
      level: level,
      message: message,
      fields: {
        ...TelemetrySanitizer.attributes(_withScreen(fields)),
        'attendee': _attendee},
      traceId: span?.traceId,
      spanId: span?.spanId,
      stackTrace: stackTrace,
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
      tags: {
        ...TelemetrySanitizer.attributes(_withScreen(tags)),
        'attendee': _attendee},
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
      attributes: {..._withScreen(attributes), 'attendee': _attendee},
      onEnd: _exporter.exportSpan,
    );
  }

  @override
  String? get currentScreen => _screens.isEmpty ? null : _screens.last;

  @override
  void enterScreen(String name) => _screens.add(name);

  @override
  void leaveScreen(String name) {
    final i = _screens.lastIndexOf(name);
    if (i >= 0) _screens.removeAt(i);
  }

  /// Adds the current screen unless the caller already set one.
  Map<String, Object?> _withScreen(Map<String, Object?> fields) {
    final screen = currentScreen;
    if (screen == null || fields.containsKey('screen')) return fields;
    return {...fields, 'screen': screen};
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
