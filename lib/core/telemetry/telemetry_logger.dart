import 'telemetry_record.dart';

/// The level-named logging API behind `ITelemetry.log`:
///
/// ```dart
/// telemetry.log.i('city saved', {'city_id': id});
/// telemetry.log.e('load failed', {'operation': 'init'}, stackTrace);
/// ```
///
/// `d` is debug, `i` info, `w` warning and `e` error. The object is also
/// callable, so `telemetry.log(TelemetryLevel.info, 'message', fields)` works
/// too. Pass an error's type as a field (`'error.type': e.runtimeType.toString()`),
/// never its message. For a caught error, pass the stack trace as the last
/// argument: `catch (e, s)` then `telemetry.log.e('failed', {...}, s)`.
class TelemetryLogger {
  final void Function(
    TelemetryLevel level,
    String message,
    Map<String, Object?> fields,
    StackTrace? stackTrace,
  ) _sink;

  const TelemetryLogger(this._sink);

  /// Logs at [level]. Same as the level-named methods.
  void call(
    TelemetryLevel level,
    String message, [
    Map<String, Object?> fields = const {},
    StackTrace? stackTrace,
  ]) =>
      _sink(level, message, fields, stackTrace);

  void d(String message, [Map<String, Object?> fields = const {}]) =>
      _sink(TelemetryLevel.debug, message, fields, null);

  void i(String message, [Map<String, Object?> fields = const {}]) =>
      _sink(TelemetryLevel.info, message, fields, null);

  void w(String message, [Map<String, Object?> fields = const {}]) =>
      _sink(TelemetryLevel.warning, message, fields, null);

  /// Logs an error. Pass the caught [stackTrace] to see where it came from.
  void e(
    String message, [
    Map<String, Object?> fields = const {},
    StackTrace? stackTrace,
  ]) =>
      _sink(TelemetryLevel.error, message, fields, stackTrace);
}
