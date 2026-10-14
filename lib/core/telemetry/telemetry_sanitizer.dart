/// Privacy rules applied by the telemetry layer to everything it records.
///
/// - No names, tokens, keys or amounts in attributes.
/// - URLs lose their query string (the OpenWeather key lives there).
class TelemetrySanitizer {
  static const deniedKeys = {'name', 'city', 'token', 'appid', 'amount'};

  static bool isAllowedKey(String key) =>
      !deniedKeys.contains(key.toLowerCase());

  static Map<String, Object?> attributes(Map<String, Object?> input) {
    final out = <String, Object?>{};
    input.forEach((key, value) {
      if (isAllowedKey(key)) out[key] = value;
    });
    return out;
  }

  /// Returns `scheme://host/path` without query or fragment.
  static String url(Uri uri) => Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
        path: uri.path,
      ).toString();
}
