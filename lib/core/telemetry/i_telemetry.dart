import 'span.dart';
import 'telemetry_record.dart';

/// The only thing the app talks to for observability.
abstract class ITelemetry {
  void log(
    TelemetryLevel level,
    String message, [
    Map<String, Object?> fields = const {},
  ]);

  void counter(String name, [Map<String, Object?> tags = const {}]);

  void timing(String name, Duration duration,
      [Map<String, Object?> tags = const {}]);

  void metric(String name, num value, [Map<String, Object?> tags = const {}]);

  /// Starts a span. Without [parent] it attaches to [current].
  Span startSpan(
    String name, {
    Span? parent,
    Map<String, Object?> attributes = const {},
  });

  /// The span new child spans attach to, read from the current [Zone].
  Span? get current;

  /// Runs [body] with [span] as [current]. The span is visible across awaits.
  T runWith<T>(Span span, T Function() body);
}
