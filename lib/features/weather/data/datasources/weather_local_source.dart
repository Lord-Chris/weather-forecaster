import 'dart:convert';

import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../services/_services.dart';
import '../dtos/air_quality_model.dart';
import '../dtos/city_location_model.dart';
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

  /// Caches the air quality reading for a specific city.
  Future<void> cacheAirQuality(
      String cityId, AirQualityModel airQuality) async {
    await _localStorageService.put(
      StorageKeys.airQualityBox,
      key: cityId,
      value: airQuality.toJson(),
    );
  }

  /// Retrieves the cached air quality for a city, or null if none is cached.
  Future<AirQualityModel?> getCachedAirQuality(String cityId) async {
    final airQuality = await _localStorageService.get(
      StorageKeys.airQualityBox,
      key: cityId,
    );
    return airQuality != null ? AirQualityModel.fromJson(airQuality) : null;
  }

  /// Persists the cities the user added through the search screen.
  Future<void> saveCities(List<CityLocationModel> cities) async {
    await _localStorageService.put(
      StorageKeys.savedCitiesBox,
      key: StorageKeys.savedCitiesKey,
      value: json.encode(cities.map((e) => e.toMap()).toList()),
    );
  }

  /// Returns the cities the user added, or an empty list.
  Future<List<CityLocationModel>> getSavedCities() async {
    // TODO(lab-3.9) Storage spans: wrap this read and saveCities in `traced(...)`.
    // Not every slow step is the network; local storage shows up as its own bar.
    // TODO(lab-1.5) State and persistence: log what was read and written to
    // storage here and in saveCities (saved_count, cache_hit, parse failures),
    // and what cacheWeather, cacheForecast and cacheAirQuality wrote (city_id).
    final raw = await _localStorageService.get(
      StorageKeys.savedCitiesBox,
      key: StorageKeys.savedCitiesKey,
    );
    if (raw == null) return [];
    return (json.decode(raw as String) as List)
        .map((e) => CityLocationModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
