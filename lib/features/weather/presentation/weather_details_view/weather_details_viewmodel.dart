import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/models/_models.dart';
import '../../data/repositories/weather_repo.dart';
import '../../data/dtos/city_location_model.dart';
import '../../data/dtos/forecast_model.dart';

// TODO(lab-3.3) Details waterfall: extend ObservedViewModel and wrap the work in
// fetchForecast() with `observe(() async { ... })`. Run with
// SILENT_DUPLICATE_REQUEST=true and look for two sibling request spans.
class WeatherDetailsViewModel extends BaseViewModel {
  final _log = getLogger('WeatherDetailsViewModel');
  final _weatherRepo = locator<WeatherRepo>();

  final _navigationService = locator<NavigationService>();

  late CityLocationModel city;
  ForecastModel? _forecast;

  void init(CityLocationModel city) {
    this.city = city;
    // TODO(lab-3.10) Correlate logs and traces: inside the observed work, log a
    // line with ITelemetry.log. TelemetryImpl stamps it with the current trace
    // and span id, so the log lines up with its span. Check the ids match.
    debugPrint('details opened city_id=${city.id}');
    fetchForecast();
    // Silent failure (traces): one tap sends the same request twice. Nothing
    // crashes; the only evidence is two sibling request spans.
    if (WorkshopFlags.silentDuplicateRequest) fetchForecast();
  }

  /// Fetches the forecast for the current city.
  ///
  /// This method sets the [busy] state to true, then calls the [_weatherRepo.get5DayForecast] method
  /// to fetch the 5-day forecast for the [city]. If an [IAppException] is thrown during the process,
  /// Finally, the [busy] state is set to false.
  ///
  /// Throws:
  ///   - [IAppException]: If an error occurs while fetching the forecast.
  Future<void> fetchForecast() async {
    // TODO(lab-2.9) Timing, user-perceived latency: `screen.load.duration` with
    // a `screen` tag (details here, home in HomeViewModel.init, air_quality in
    // AirQualityViewModel). Measure from the call to the busy flag clearing.
    try {
      setBusy(true);
      _forecast = await _weatherRepo.get5DayForecast(city);
    } on IAppException catch (e) {
      _log.e(e);
      // TODO(lab-3.7) Errors on spans: this catch swallows the error INSIDE
      // observe(), so the span ends as a success. Move the try/catch outside
      // observe() (or rethrow) so the span records error.type, then verify with
      // FAULT_FAIL_RATE=100.
    } finally {
      setBusy(false);
    }
  }

  /// Opens the air quality screen for the current city.
  void onAirQualityTap() {
    debugPrint('air quality tapped city_id=${city.id}');
    _navigationService.navigateTo(
      Routes.airQualityView,
      arguments: AirQualityViewArguments(city: city),
    );
  }

  /// Forecast entries grouped by calendar day, in chronological order.
  Map<DateTime, List<ListElement>> get forecastByDay {
    final days = <DateTime, List<ListElement>>{};
    for (final item in forecast) {
      final time = DateTime.fromMillisecondsSinceEpoch(item.dt * 1000);
      final day = DateTime(time.year, time.month, time.day);
      days.putIfAbsent(day, () => []).add(item);
    }
    return days;
  }

  List<ListElement> get forecast => _forecast?.list ?? [];
}
