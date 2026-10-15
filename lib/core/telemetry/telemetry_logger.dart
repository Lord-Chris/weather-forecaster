import 'telemetry_record.dart';

/// The level-named logging API behind `ITelemetry.log`:
///
/// ```dart
/// telemetry.log.i('city saved', {'city_id': id});
/// telemetry.log.e('load failed', {'operation': 'init'});
/// ```
///
/// `d` is debug, `i` info, `w` warning and `e` error. The object is also
/// callable, so `telemetry.log(TelemetryLevel.info, 'message', fields)` works
/// too. Pass an error's type as a field (`'error.type': e.runtimeType.toString()`),
/// never its message.
class TelemetryLogger {
  final void Function(
    TelemetryLevel level,
    String message,
    Map<String, Object?> fields,
  ) _sink;

  const TelemetryLogger(this._sink);

  /// Logs at [level]. Same as the level-named methods.
  void call(
    TelemetryLevel level,
    String message, [
    Map<String, Object?> fields = const {},
  ]) =>
      _sink(level, message, fields);

  void d(String message, [Map<String, Object?> fields = const {}]) =>
      _sink(TelemetryLevel.debug, message, fields);

  void i(String message, [Map<String, Object?> fields = const {}]) =>
      _sink(TelemetryLevel.info, message, fields);

  void w(String message, [Map<String, Object?> fields = const {}]) =>
      _sink(TelemetryLevel.warning, message, fields);

  void e(String message, [Map<String, Object?> fields = const {}]) =>
      _sink(TelemetryLevel.error, message, fields);
}
