import 'i_telemetry.dart';

extension TelemetryErrors on ITelemetry {
  /// Logs an error by type only, never its message, so no private detail can
  /// leak through an exception's text. Pass the caught stack trace to see where
  /// it came from.
  void logError(
    String message,
    Object error, {
    Map<String, Object?> fields = const {},
    StackTrace? stackTrace,
  }) {
    log.e(
        message,
        {
          ...fields,
          'error.type': error.runtimeType.toString(),
        },
        stackTrace);
  }
}
