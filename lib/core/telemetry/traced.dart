import 'i_telemetry.dart';

/// Wraps [body] in a span: starts it, makes it [Telemetry.current] for
/// anything called inside (across awaits), records errors by type, and ends it.
Future<T> traced<T>(
  String name,
  Future<T> Function() body, {
  required Telemetry telemetry,
  Map<String, Object?> attributes = const {},
}) async {
  final span = telemetry.startSpan(name, attributes: attributes);
  try {
    return await telemetry.runWith(span, body);
  } catch (e) {
    span.setError(e);
    rethrow;
  } finally {
    span.end();
  }
}
