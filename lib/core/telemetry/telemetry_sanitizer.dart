/// Privacy rules applied by the telemetry layer to everything it records.
///
/// - No names, tokens, keys or amounts in attributes.
/// - URLs lose their query string (the OpenWeather key lives there).
/// - Errors are reduced to their type.
class TelemetrySanitizer {
  static const deniedKeys = {
    'name',
    'city',
    'token',
    'appid',
    'apikey',
    'api_key',
    'password',
    'amount',
    'email',
    'message',
  };

  static bool isAllowedKey(String key) =>
      !deniedKeys.contains(key.toLowerCase());

  static Map<String, Object?> attributes(Map<String, Object?> input) {
    final out = <String, Object?>{};
    input.forEach((key, value) {
      if (!isAllowedKey(key)) return;
      out[key] = value is Uri ? url(value) : value;
    });
    return out;
  }

  /// Returns `scheme://host/path` without query or fragment.
  static String url(Uri uri) => Uri(
          scheme: uri.scheme,
          host: uri.host,
          port: uri.hasPort ? uri.port : null,
          path: uri.path)
      .toString();

  static String errorType(Object error) => error.runtimeType.toString();
}
