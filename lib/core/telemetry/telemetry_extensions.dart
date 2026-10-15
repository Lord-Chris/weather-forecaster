import 'i_telemetry.dart';
import 'telemetry_record.dart';

extension TelemetryErrors on ITelemetry {
  /// Logs an error by type only, never its message, so no private detail can
  /// leak through an exception's text.
  void logError(
    String message,
    Object error, [
    Map<String, Object?> fields = const {},
  ]) {
    log(TelemetryLevel.error, message, {
      ...fields,
      'error.type': error.runtimeType.toString(),
    });
  }
}
