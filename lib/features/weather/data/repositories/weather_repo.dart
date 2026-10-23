import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/models/_models.dart';
import '../../../../core/telemetry/_telemetry.dart';
import '../../../../services/_services.dart';
import '../datasources/weather_local_source.dart';
import '../datasources/weather_remote_source.dart';
import '../dtos/air_quality_model.dart';
import '../dtos/city_location_model.dart';
import '../dtos/forecast_model.dart';
import '../dtos/geo_location_model.dart';
import '../dtos/weather_model.dart';

/// Repository class for fetching weather data.
///
/// Each fetch builds one wide event (`weather.fetch`) as it runs and logs it
/// once when it finishes, and times itself.
class WeatherRepo {
  final _localSource = locator<WeatherLocalSource>();
  final _remoteSource = locator<WeatherRemoteSource>();
  final _connectivityService = locator<IConnectivityService>();
  final _telemetry = locator<Telemetry>();

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
    // TODO(lab-2.2) Timing, duration (the D in RED): `weather.fetch.duration` for
    final stopwatch = Stopwatch()..start();
    final event = _startFetch('getCurrentWeather', city);
    StackTrace? failure;
    try {
      final connected = await isConnected;
      event['connected'] = connected;
      // TODO(lab-1.3) Decisions: data source. Log each branch that changes what
      if (connected) {
        try {
          final weather = await _remoteSource.getCurrentWeather(city);
          await _localSource.cacheWeather(city.id, weather);
          event['source'] = 'remote';
          return weather;
        } on IAppException catch (e) {
          if (!WorkshopFlags.silentFallback) rethrow;
          // Silent failure (logs): the user sees stale data and no error.
          // The wide event carries fallback=true, and this warning names the
          // error that was swallowed.
          event['source'] = 'cache';
          event['fallback'] = true;
          _telemetry.log.w('served cache after failure', {
            'operation': 'getCurrentWeather',
            'city_id': city.id,
            'error.type': e.runtimeType.toString(),
          });
          return await _cachedWeather(city, event);
        }
      }
      event['source'] = 'cache';
      return await _cachedWeather(city, event);
    } on IAppException catch (e, s) {
      event['success'] = false;
      event['error.type'] = e.runtimeType.toString();
      failure = s;
      rethrow;
    } catch (e, s) {
      // The original error is wrapped and its type is lost from here on.
      _telemetry.logError('unexpected error wrapped', e,
          fields: {'service': 'WeatherRepo', 'operation': 'getCurrentWeather'},
          stackTrace: s);
      event['success'] = false;
      event['error.type'] = 'FallbackAppException';
      failure = s;
      throw FallbackAppException(data: e);
    } finally {
      _endFetch(event, stopwatch, failure);
    }
  }

  Future<WeatherModel?> _cachedWeather(
    CityLocationModel city,
    Map<String, Object?> event,
  ) async {
    final cached = await _localSource.getCachedCurrentWeather(city.id);
    event['cache_hit'] = cached != null;
    if (cached == null) {
      _telemetry.log.i('weather cache miss', {
        'city_id': city.id,
      });
    }
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
    final stopwatch = Stopwatch()..start();
    final event = _startFetch('get5DayForecast', city);
    StackTrace? failure;
    try {
      final connected = await isConnected;
      event['connected'] = connected;
      if (connected) {
        // TODO(lab-3.4) Child span in the repo: wrap the remote call in `traced(...)`
        final forecast = await traced(
          'remote get5DayForecast',
          () => _remoteSource.get5DayForecast(city),
          telemetry: _telemetry,
        );
        await _localSource.cacheForecast(city.id, forecast);
        event['source'] = 'remote';
        return forecast;
      }
      final cached = await _localSource.getCachedForecast(city.id);
      event['source'] = 'cache';
      event['cache_hit'] = cached != null;
      return cached;
    } on IAppException catch (e, s) {
      event['success'] = false;
      event['error.type'] = e.runtimeType.toString();
      failure = s;
      rethrow;
    } catch (e, s) {
      _telemetry.logError('unexpected error wrapped', e,
          fields: {'service': 'WeatherRepo', 'operation': 'get5DayForecast'},
          stackTrace: s);
      event['success'] = false;
      event['error.type'] = 'FallbackAppException';
      failure = s;
      throw FallbackAppException(data: e);
    } finally {
      _endFetch(event, stopwatch, failure);
    }
  }

  /// Retrieves the air quality for the specified city, falling back to the
  /// cache when offline.
  ///
  /// Throws [IAppException] if an application-specific exception occurs.
  /// Throws [FallbackAppException] if a fallback exception occurs.
  Future<AirQualityModel?> getAirQuality(CityLocationModel city) async {
    final stopwatch = Stopwatch()..start();
    final event = _startFetch('getAirQuality', city);
    StackTrace? failure;
    try {
      final connected = await isConnected;
      event['connected'] = connected;
      if (connected) {
        final airQuality = await _remoteSource.getAirQuality(city);
        await _localSource.cacheAirQuality(city.id, airQuality);
        event['source'] = 'remote';
        return airQuality;
      }
      final cached = await _localSource.getCachedAirQuality(city.id);
      event['source'] = 'cache';
      event['cache_hit'] = cached != null;
      return cached;
    } on IAppException catch (e, s) {
      event['success'] = false;
      event['error.type'] = e.runtimeType.toString();
      failure = s;
      rethrow;
    } catch (e, s) {
      _telemetry.logError('unexpected error wrapped', e,
          fields: {'service': 'WeatherRepo', 'operation': 'getAirQuality'},
          stackTrace: s);
      event['success'] = false;
      event['error.type'] = 'FallbackAppException';
      failure = s;
      throw FallbackAppException(data: e);
    } finally {
      _endFetch(event, stopwatch, failure);
    }
  }

  /// Searches places by name. Needs a connection.
  ///
  /// Throws [InternetAppException] when offline.
  Future<List<GeoLocationModel>> searchCities(String query) async {
    try {
      if (!await isConnected) {
        _telemetry.log.w('search refused', {
          'reason': 'offline',
          'query_length': query.length,
        });
        throw InternetAppException();
      }
      return await _remoteSource.searchCities(query);
    } on IAppException {
      rethrow;
    } catch (e, s) {
      _telemetry.logError('unexpected error wrapped', e,
          fields: {
            'service': 'WeatherRepo',
            'operation': 'searchCities',
          },
          stackTrace: s);
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
    if (saved.any((e) => e.id == city.id)) {
      _telemetry.log.i('city save skipped', {
        'reason': 'duplicate',
        'city_id': city.id,
      });
      return;
    }
    await _localSource.saveCities([...saved, city]);
  }

  /// Starts the wide event for a fetch: a plain map that the method fills in
  /// as it learns things, and logs once at the end.
  Map<String, Object?> _startFetch(String operation, CityLocationModel city) {
    return {'operation': operation, 'city_id': city.id, 'success': true};
  }

  /// Logs the wide event once and times the fetch (Lab 2), tagged by source.
  void _endFetch(
    Map<String, Object?> event,
    Stopwatch stopwatch,
    StackTrace? failure,
  ) {
    event['duration_ms'] = stopwatch.elapsedMilliseconds;
    final operation = event['operation'];
    final tags = {'operation': operation, 'source': event['source'] ?? 'none'};
    _telemetry.timing('weather.fetch.duration', stopwatch.elapsed, tags);
    if (event['success'] == false) {
      _telemetry.log.e('weather.fetch', event, failure);
    } else {
      _telemetry.log.i('weather.fetch', event);
    }
  }
}
