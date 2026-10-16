import 'package:stacked/stacked.dart';

import '../../../../core/app/_app.dart';
import '../../../../core/shared/models/_models.dart';
import '../../../../core/telemetry/_telemetry.dart';
import '../../data/dtos/air_quality_model.dart';
import '../../data/dtos/city_location_model.dart';
import '../../data/repositories/weather_repo.dart';

class AirQualityViewModel extends BaseViewModel {
  final _log = getLogger('AirQualityViewModel');
  final _weatherRepo = locator<WeatherRepo>();
  final _telemetry = locator<Telemetry>();

  late CityLocationModel city;
  AirQualityModel? airQuality;

  void init(CityLocationModel city) {
    this.city = city;
    _telemetry.log.d('air quality opened', {
      'city_id': city.id,
    });
    fetchAirQuality();
  }

  /// Fetches the air quality for [city]. Errors are logged and leave
  /// [airQuality] unchanged so the view can show its empty state.
  Future<void> fetchAirQuality() async {
    try {
      setBusy(true);
      airQuality = await _weatherRepo.getAirQuality(city);
    } on IAppException catch (e, s) {
      _log.e(e);
      _telemetry.logError('air quality load failed', e,
          fields: {
            'viewmodel': 'AirQualityViewModel',
            'operation': 'fetchAirQuality',
          },
          stackTrace: s);
    } finally {
      setBusy(false);
    }
  }
}
