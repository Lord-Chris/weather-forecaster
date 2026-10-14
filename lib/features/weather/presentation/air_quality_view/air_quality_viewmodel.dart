import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import '../../../../core/app/_app.dart';
import '../../../../core/shared/models/_models.dart';
import '../../data/dtos/air_quality_model.dart';
import '../../data/dtos/city_location_model.dart';
import '../../data/repositories/weather_repo.dart';

class AirQualityViewModel extends BaseViewModel {
  final _log = getLogger('AirQualityViewModel');
  final _weatherRepo = locator<WeatherRepo>();

  late CityLocationModel city;
  AirQualityModel? airQuality;

  void init(CityLocationModel city) {
    this.city = city;
    debugPrint('air quality opened city_id=${city.id}');
    fetchAirQuality();
  }

  /// Fetches the air quality for [city]. Errors are logged and leave
  /// [airQuality] unchanged so the view can show its empty state.
  Future<void> fetchAirQuality() async {
    try {
      setBusy(true);
      airQuality = await _weatherRepo.getAirQuality(city);
    } on IAppException catch (e) {
      _log.e(e);
    } finally {
      setBusy(false);
    }
  }
}
