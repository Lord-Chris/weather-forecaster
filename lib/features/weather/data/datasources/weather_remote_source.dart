import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/utilities/transformer.dart';
import '../../../../services/_services.dart';
import '../dtos/city_location_model.dart';
import '../dtos/forecast_model.dart';
import '../dtos/weather_model.dart';

/// A class that represents a remote data source for weather information.
class WeatherRemoteSource {
  final _apiService = locator<IApi>();

  /// Retrieves the current weather for a given city.
  ///
  /// Returns a [WeatherModel] object representing the current weather.
  /// The [city] parameter specifies the location for which to retrieve the weather.
  Future<WeatherModel> getCurrentWeather(CityLocationModel city) async {
    final url =
        '${AppConstants.basePath}weather?lat=${city.lat}&lon=${city.lon}&appid=${AppKeys.openWeatherApiKey}';
    final res = await _apiService.get(Uri.parse(url));

    return await transformApiResponse(res, WeatherModel.fromMap);
  }

  /// Retrieves the 5-day weather forecast for a given city.
  ///
  /// Returns a [ForecastModel] object representing the weather forecast.
  /// The [city] parameter specifies the location for which to retrieve the forecast.
  Future<ForecastModel> get5DayForecast(CityLocationModel city) async {
    final url =
        '${AppConstants.basePath}forecast?lat=${city.lat}&lon=${city.lon}&appid=${AppKeys.openWeatherApiKey}';
    final res = await _apiService.get(Uri.parse(url));

    return await transformApiResponse(res, ForecastModel.fromMap);
  }
}
