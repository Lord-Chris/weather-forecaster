import '../../../../core/app/_app.dart';
import '../../../../core/shared/models/_models.dart';
import '../../../../services/_services.dart';
import '../../domain/entities/city_location_model.dart';
import '../../domain/entities/forecast_model.dart';
import '../../domain/entities/weather_model.dart';
import '../datasources/weather_local_source.dart';
import '../datasources/weather_remote_source.dart';

class WeatherRepo {
  final _localSource = locator<WeatherLocalSource>();
  final _remoteSource = locator<WeatherRemoteSource>();
  final _connectivityService = locator<IConnectivityService>();

  Future<bool> get isConnected =>
      _connectivityService.checkInternetConnection();

  Future<WeatherModel?> getCurrentWeather(CityLocationModel city) async {
    try {
      if (await isConnected) {
        final weather = await _remoteSource.getCurrentWeather(city);
        await _localSource.cacheWeather(city.id, weather);
        return weather;
      } else {
        return await _localSource.getCachedCurrentWeather(city.id);
      }
    } on IAppException {
      rethrow;
    } catch (e) {
      throw FallbackAppException(data: e);
    }
  }

  Future<ForecastModel?> get5DayForecast(CityLocationModel city) async {
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
