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
    // TODO(lab-2): count this attempt (`weather.fetch.attempts`) and time the
    // whole call (`weather.fetch.duration`) with ITelemetry.counter / timing.
    debugPrint('weather fetch start city_id=${city.id}');
    try {
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
          return await _localSource.getCachedCurrentWeather(city.id);
        }
      } else {
        debugPrint(
            'weather fetch done city_id=${city.id} source=cache offline=true');
        return await _localSource.getCachedCurrentWeather(city.id);
      }
    } on IAppException {
      rethrow;
    } catch (e) {
      throw FallbackAppException(data: e);
    }
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
        return forecast;
      } else {
        return await _localSource.getCachedForecast(city.id);
      }
    } on IAppException {
      rethrow;
    } catch (e) {
      throw FallbackAppException(data: e);
    }
  }
}
