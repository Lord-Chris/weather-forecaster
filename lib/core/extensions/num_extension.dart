extension TemperatureExtension on num {
  /// Formats a metric temperature, e.g. `23.6` -> `24°C`.
  String get asCelsius => '${round()}°C';
}
