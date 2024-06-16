import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../services/_services.dart';
import '../dtos/forecast_model.dart';
import '../dtos/weather_model.dart';

/// A class that provides local data storage operations for weather-related data.
class WeatherLocalSource {
  final _localStorageService = locator<ILocalStorage>();

  /// Caches the weather data for a specific city.
  ///
  /// The [cityId] parameter specifies the ID of the city.
  /// The [weather] parameter contains the weather data to be cached.
  Future<void> cacheWeather(String cityId, WeatherModel weather) async {
    await _localStorageService.put(
      StorageKeys.weatherBox,
      key: cityId,
      value: weather.toJson(),
    );
  }

  /// Retrieves the cached current weather data for a specific city.
  ///
  /// The [cityId] parameter specifies the ID of the city.
  /// Returns the [WeatherModel] object representing the current weather data,
  /// or null if the data is not found in the cache.
  Future<WeatherModel?> getCachedCurrentWeather(String cityId) async {
    final weather = await _localStorageService.get(
      StorageKeys.weatherBox,
      key: cityId,
    );
    return weather != null ? WeatherModel.fromJson(weather) : null;
  }

  /// Caches the forecast data for a specific city.
  ///
  /// The [cityId] parameter specifies the ID of the city.
  /// The [forecast] parameter contains the forecast data to be cached.
  Future<void> cacheForecast(String cityId, ForecastModel forecast) async {
    await _localStorageService.put(
      StorageKeys.forecastBox,
      key: cityId,
      value: forecast.toJson(),
    );
  }

  /// Retrieves the cached forecast data for a specific city.
  ///
  /// The [cityId] parameter specifies the ID of the city.
  /// Returns the [ForecastModel] object representing the forecast data,
  /// or null if the data is not found in the cache.
  Future<ForecastModel?> getCachedForecast(String cityId) async {
    final forecast = await _localStorageService.get(
      StorageKeys.forecastBox,
      key: cityId,
    );
    return forecast != null ? ForecastModel.fromJson(forecast) : null;
  }
}
