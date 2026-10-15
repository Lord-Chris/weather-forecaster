import 'dart:convert';

import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/telemetry/_telemetry.dart';
import '../../../../services/_services.dart';
import '../dtos/air_quality_model.dart';
import '../dtos/city_location_model.dart';
import '../dtos/forecast_model.dart';
import '../dtos/weather_model.dart';

/// A class that provides local data storage operations for weather-related data.
class WeatherLocalSource {
  final _localStorageService = locator<ILocalStorage>();
  final _telemetry = locator<ITelemetry>();

  void _cacheWritten(String cache, String cityId) =>
      _telemetry.log.d('cache written', {
        'cache': cache,
        'city_id': cityId,
      });

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
    _cacheWritten('weather', cityId);
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
    _cacheWritten('forecast', cityId);
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
    _cacheWritten('air_quality', cityId);
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
  Future<void> saveCities(List<CityLocationModel> cities) {
    return traced('storage write saved_cities', () async {
      await _localStorageService.put(
        StorageKeys.savedCitiesBox,
        key: StorageKeys.savedCitiesKey,
        value: json.encode(cities.map((e) => e.toMap()).toList()),
      );
      _telemetry.log.i('saved cities written', {
        'saved_count': cities.length,
      });
    }, telemetry: _telemetry);
  }

  /// Returns the cities the user added, or an empty list.
  Future<List<CityLocationModel>> getSavedCities() {
    // TODO(lab-3.9) Storage spans: wrap this read and saveCities in `traced(...)`.
    // TODO(lab-1.5) State and persistence: log what was read and written to
    return traced('storage read saved_cities', () async {
      final raw = await _localStorageService.get(
        StorageKeys.savedCitiesBox,
        key: StorageKeys.savedCitiesKey,
      );
      if (raw == null) {
        _telemetry.log.i('saved cities read', {
          'saved_count': 0,
          'cache_hit': false,
        });
        return <CityLocationModel>[];
      }
      try {
        final cities = (json.decode(raw as String) as List)
            .map((e) => CityLocationModel.fromMap(e as Map<String, dynamic>))
            .toList();
        _telemetry.log.i('saved cities read', {
          'saved_count': cities.length,
          'cache_hit': true,
        });
        return cities;
      } catch (e) {
        _telemetry.logError('saved cities parse failed', e, {
          'operation': 'getSavedCities',
        });
        rethrow;
      }
    }, telemetry: _telemetry);
  }
}
