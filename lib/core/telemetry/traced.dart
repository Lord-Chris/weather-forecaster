import 'i_telemetry.dart';
import 'telemetry.dart';

/// Wraps [body] in a span: starts it, makes it [ITelemetry.current] for
/// anything called inside (across awaits), records errors by type, and ends it.
Future<T> traced<T>(
  String name,
  Future<T> Function() body, {
  Map<String, Object?> attributes = const {},
  ITelemetry? telemetry,
}) async {
  final t = telemetry ?? Telemetry.instance;
  final span = t.startSpan(name, attributes: attributes);
  try {
    return await t.runWith(span, body);
  } catch (e) {
    span.setError(e);
    rethrow;
  } finally {
    span.end();
  }
}
