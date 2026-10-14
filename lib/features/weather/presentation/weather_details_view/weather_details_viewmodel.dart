import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/models/_models.dart';
import '../../data/repositories/weather_repo.dart';
import '../../data/dtos/city_location_model.dart';
import '../../data/dtos/forecast_model.dart';

// TODO(lab-3): extend ObservedViewModel instead of BaseViewModel, and wrap the
// work in fetchForecast() with `observe(() async { ... })`.
class WeatherDetailsViewModel extends BaseViewModel {
  final _log = getLogger('WeatherDetailsViewModel');
  final _weatherRepo = locator<WeatherRepo>();

  final _navigationService = locator<NavigationService>();

  late CityLocationModel city;
  ForecastModel? _forecast;

  void init(CityLocationModel city) {
    this.city = city;
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
    try {
      setBusy(true);
      _forecast = await _weatherRepo.get5DayForecast(city);
    } on IAppException catch (e) {
      _log.e(e);
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
