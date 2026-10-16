import 'package:flutter/foundation.dart';

import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/models/_models.dart';
import '../../../../services/_services.dart';
import '../datasources/weather_local_source.dart';
import '../datasources/weather_remote_source.dart';
import '../dtos/air_quality_model.dart';
import '../dtos/city_location_model.dart';
import '../dtos/forecast_model.dart';
import '../dtos/geo_location_model.dart';
import '../dtos/weather_model.dart';

/// Repository class for fetching weather data.
class WeatherRepo {
  final _localSource = locator<WeatherLocalSource>();
  final _remoteSource = locator<WeatherRemoteSource>();
  final _connectivityService = locator<IConnectivityService>();

  /// Checks if the device is connected to the internet.
  Future<bool> get isConnected =>
      _connectivityService.checkInternetConnection();

  /// Retrieves the current weather for the specified city.
  ///
  /// If the device is connected to the internet, the weather data is fetched
  /// from the remote source and cached locally. Otherwise, the cached weather
  /// data is returned.
  ///
  /// Throws [IAppException] if an application-specific exception occurs.
  /// Throws [FallbackAppException] if a fallback exception occurs.
  Future<WeatherModel?> getCurrentWeather(CityLocationModel city) async {
    // TODO(lab-1.8) Wide event: weather fetch. Start a Stopwatch and a
    // `final event = <String, Object?>{'operation': 'getCurrentWeather',
    // 'city_id': city.id, 'success': true}` here, fill it as the branches below
    // run (connected, source, fallback, cache_hit, error.type), and log it ONCE
    // in a `finally` with duration_ms. Do the same in get5DayForecast and
    // getAirQuality, then delete the fetch start/done prints in this repo.
    // TODO(lab-2.2) Timing, duration (the D in RED): `weather.fetch.duration` for
    // the whole call, tagged with the source (remote or cache). Reuse the
    // Stopwatch from step 1.8 if you did it. Run with FAULT_RETRY=true and find
    // the p95 spike: it only shows once timings are split by source.
    debugPrint('weather fetch start city_id=${city.id}');
    try {
      // TODO(lab-1.3) Decisions: data source. Log each branch that changes what
      // the user sees (the prints below, the cache miss in _cachedWeather, and
      // the same branches in get5DayForecast and getAirQuality) with named
      // fields: source, offline, fallback, cache_hit.
      if (await isConnected) {
        try {
          final weather = await _remoteSource.getCurrentWeather(city);
          await _localSource.cacheWeather(city.id, weather);
          debugPrint('weather fetch done city_id=${city.id} source=remote');
          return weather;
        } on IAppException catch (e) {
          if (!WorkshopFlags.silentFallback) rethrow;
          // Silent failure (logs): the user sees stale data and no error.
          // The only evidence is the fallback marker on the line below.
          debugPrint(
              'weather fetch done city_id=${city.id} source=cache fallback=true error=${e.runtimeType}');
          return await _cachedWeather(city);
        }
      }
      debugPrint(
          'weather fetch done city_id=${city.id} source=cache offline=true');
      return await _cachedWeather(city);
    } on IAppException {
      rethrow;
    } catch (e) {
      // The original error is wrapped and its type is lost from here on.
      throw FallbackAppException(data: e);
    }
  }

  Future<WeatherModel?> _cachedWeather(CityLocationModel city) async {
    final cached = await _localSource.getCachedCurrentWeather(city.id);
    if (cached == null) debugPrint('weather cache miss city_id=${city.id}');
    return cached;
  }

  /// Retrieves the 5-day weather forecast for the specified city.
  ///
  /// If the device is connected to the internet, the forecast data is fetched
  /// from the remote source and cached locally. Otherwise, the cached forecast
  /// data is returned.
  ///
  /// Throws [IAppException] if an application-specific exception occurs.
  /// Throws [FallbackAppException] if a fallback exception occurs.
  Future<ForecastModel?> get5DayForecast(CityLocationModel city) async {
    debugPrint('forecast fetch start city_id=${city.id}');
    try {
      if (await isConnected) {
        // TODO(lab-3.4) Child span in the repo: wrap the remote call in `traced(...)`
        // so the waterfall shows where the time goes inside the fetch, not just
        // that it was slow.
        final forecast = await _remoteSource.get5DayForecast(city);
        await _localSource.cacheForecast(city.id, forecast);
        debugPrint('forecast fetch done city_id=${city.id} source=remote');
        return forecast;
      }
      final cached = await _localSource.getCachedForecast(city.id);
      debugPrint(
          'forecast fetch done city_id=${city.id} source=cache offline=true cache_hit=${cached != null}');
      return cached;
    } on IAppException {
      rethrow;
    } catch (e) {
      throw FallbackAppException(data: e);
    }
  }

  /// Retrieves the air quality for the specified city, falling back to the
  /// cache when offline.
  ///
  /// Throws [IAppException] if an application-specific exception occurs.
  /// Throws [FallbackAppException] if a fallback exception occurs.
  Future<AirQualityModel?> getAirQuality(CityLocationModel city) async {
    try {
      if (await isConnected) {
        final airQuality = await _remoteSource.getAirQuality(city);
        await _localSource.cacheAirQuality(city.id, airQuality);
        return airQuality;
      }
      return await _localSource.getCachedAirQuality(city.id);
    } on IAppException {
      rethrow;
    } catch (e) {
      throw FallbackAppException(data: e);
    }
  }

  /// Searches places by name. Needs a connection.
  ///
  /// Throws [InternetAppException] when offline.
  Future<List<GeoLocationModel>> searchCities(String query) async {
    try {
      if (!await isConnected) throw InternetAppException();
      return await _remoteSource.searchCities(query);
    } on IAppException {
      rethrow;
    } catch (e) {
      throw FallbackAppException(data: e);
    }
  }

  /// Returns the cities the user added.
  Future<List<CityLocationModel>> getSavedCities() =>
      _localSource.getSavedCities();

  /// Saves [city] if it isn't already saved or one of the default cities.
  Future<void> saveCity(CityLocationModel city) async {
    final saved = await _localSource.getSavedCities();
    // TODO(lab-1.4) Silent drops: the app skips these without telling the user.
    // Log the duplicate skip here, the stale search response and the too-short
    // query in AddCityViewModel, and the offline refusal in searchCities.
    if (saved.any((e) => e.id == city.id)) return;
    await _localSource.saveCities([...saved, city]);
  }
}
