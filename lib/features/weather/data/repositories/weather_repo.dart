import '../../../../core/app/_app.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/models/_models.dart';
import '../../../../services/_services.dart';
import '../datasources/weather_local_source.dart';
import '../datasources/weather_remote_source.dart';
import '../dtos/city_location_model.dart';
import '../dtos/forecast_model.dart';
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
    // TODO(lab-1.4) Wide event: start a Stopwatch and a
    // `final event = <String, Object?>{'operation': 'getCurrentWeather',
    // 'city_id': city.id}` here, fill it as the branches below run (connected,
    // source, fallback, cache_hit, error.type), and log it ONCE in a `finally`
    // with duration_ms. Do the same in get5DayForecast, then delete the fetch
    // start/done prints from steps 2 and 3: one line now tells the whole story.
    // TODO(lab-2): count this attempt (`weather.fetch.attempts`) and time the
    // whole call (`weather.fetch.duration`) with ITelemetry.counter / timing.
    debugPrint('weather fetch start city_id=${city.id}');
    try {
      // TODO(lab-1.2) Decision logs: log each branch that changes what the user
      // sees (the three prints below and the cache miss in _cachedWeather, plus
      // the same branches in get5DayForecast) with named fields: source,
      // offline, fallback, cache_hit.
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
      } else {
        debugPrint(
            'weather fetch done city_id=${city.id} source=cache offline=true');
        return await _cachedWeather(city);
      }
    } on IAppException {
      rethrow;
    } catch (e) {
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
        final forecast = await _remoteSource.get5DayForecast(city);
        await _localSource.cacheForecast(city.id, forecast);
        debugPrint('forecast fetch done city_id=${city.id} source=remote');
        return forecast;
      } else {
        final cached = await _localSource.getCachedForecast(city.id);
        debugPrint(
            'forecast fetch done city_id=${city.id} source=cache offline=true cache_hit=${cached != null}');
        return cached;
      }
    } on IAppException {
      rethrow;
    } catch (e) {
      throw FallbackAppException(data: e);
    }
  }
}
