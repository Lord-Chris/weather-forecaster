import 'package:stacked/stacked.dart';

import '../../../../core/app/_app.dart';
import '../../../../core/shared/models/_models.dart';
import '../../data/repositories/weather_repo.dart';
import '../../domain/entities/city_location_model.dart';
import '../../domain/entities/forecast_model.dart';

class WeatherDetailsViewModel extends BaseViewModel {
  final _log = getLogger('WeatherDetailsViewModel');
  final _weatherRepo = locator<WeatherRepo>();

  late CityLocationModel city;
  ForecastModel? _forecast;

  void init(CityLocationModel city) {
    this.city = city;
    fetchForecast();
  }

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

  List<ListElement> get forecast => _forecast?.list ?? [];
}
