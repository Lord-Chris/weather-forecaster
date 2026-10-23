import 'telemetry_sanitizer.dart';

/// A timed unit of work. Create one with `ITelemetry.startSpan`.
class Span {
  final String name;
  final String traceId;
  final String spanId;
  final String? parentSpanId;
  final Map<String, Object?> attributes;
  final DateTime startTime;

  DateTime? endTime;
  String? errorType;

  final void Function(Span span) _onEnd;

  Span({
    required this.name,
    required this.traceId,
    required this.spanId,
    required this.parentSpanId,
    required Map<String, Object?> attributes,
    required this._onEnd,
  }) : attributes = TelemetrySanitizer.attributes(attributes),
       startTime = DateTime.now();

  bool get isEnded => endTime != null;

  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);

  /// Adds an attribute. Denied keys are dropped.
  void setAttribute(String key, Object? value) {
    if (TelemetrySanitizer.isAllowedKey(key)) attributes[key] = value;
  }

  /// Marks the span as failed. Only the error type is kept, never the message.
  void setError(Object error) {
    errorType = error.runtimeType.toString();
  }

  /// Ends the span once. Later calls are ignored.
  void end() {
    if (isEnded) return;
    endTime = DateTime.now();
    _onEnd(this);
  }
}
