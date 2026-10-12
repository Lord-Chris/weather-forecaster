/// Switches for the workshop's silent failures. All default to off, so labs 1-3
/// run clean. Pass with `--dart-define=NAME=true`.
class WorkshopFlags {
  /// Logs challenge: the repository swallows a remote error and returns cached data.
  static const silentFallback = bool.fromEnvironment('SILENT_FALLBACK');

  /// Traces challenge: one tap sends the same forecast request twice.
  static const silentDuplicateRequest =
      bool.fromEnvironment('SILENT_DUPLICATE_REQUEST');
}
