import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../services/_services.dart';
import '../dtos/forecast_model.dart';
import '../dtos/weather_model.dart';

class WeatherLocalSource {
  final _localStorageService = locator<ILocalStorage>();

  Future<void> cacheWeather(String cityId, WeatherModel weather) async {
    await _localStorageService.put(
      StorageKeys.weatherBox,
      key: cityId,
      value: weather.toJson(),
    );
  }

  Future<WeatherModel?> getCachedCurrentWeather(String cityId) async {
    final weather = await _localStorageService.get(
      StorageKeys.weatherBox,
      key: cityId,
    );
    return weather != null ? WeatherModel.fromJson(weather) : null;
  }

  Future<void> cacheForecast(String cityId, ForecastModel forecast) async {
    await _localStorageService.put(
      StorageKeys.forecastBox,
      key: cityId,
      value: forecast.toJson(),
    );
  }

  Future<ForecastModel?> getCachedForecast(String cityId) async {
    final forecast = await _localStorageService.get(
      StorageKeys.forecastBox,
      key: cityId,
    );
    return forecast != null ? ForecastModel.fromJson(forecast) : null;
  }
}
