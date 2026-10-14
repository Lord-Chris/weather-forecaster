import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/utilities/transformer.dart';
import '../../../../services/_services.dart';
import '../dtos/air_quality_model.dart';
import '../dtos/city_location_model.dart';
import '../dtos/forecast_model.dart';
import '../dtos/geo_location_model.dart';
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
        '${AppConstants.basePath}weather?lat=${city.lat}&lon=${city.lon}&units=metric&appid=${AppKeys.openWeatherApiKey}';
    final res = await _apiService.get(Uri.parse(url));

    return await transformApiResponse(res, WeatherModel.fromMap);
  }

  /// Retrieves the 5-day weather forecast for a given city.
  ///
  /// Returns a [ForecastModel] object representing the weather forecast.
  /// The [city] parameter specifies the location for which to retrieve the forecast.
  Future<ForecastModel> get5DayForecast(CityLocationModel city) async {
    final url =
        '${AppConstants.basePath}forecast?lat=${city.lat}&lon=${city.lon}&units=metric&appid=${AppKeys.openWeatherApiKey}';
    final res = await _apiService.get(Uri.parse(url));

    return await transformApiResponse(res, ForecastModel.fromMap);
  }

  /// Retrieves the current air pollution reading for a given city.
  Future<AirQualityModel> getAirQuality(CityLocationModel city) async {
    final url =
        '${AppConstants.basePath}air_pollution?lat=${city.lat}&lon=${city.lon}&appid=${AppKeys.openWeatherApiKey}';
    final res = await _apiService.get(Uri.parse(url));

    return await transformApiResponse(res, AirQualityModel.fromMap);
  }

  /// Searches places by name with the geocoding endpoint.
  ///
  /// The endpoint answers with a JSON array, which [IApi] exposes under the
  /// `data` key.
  Future<List<GeoLocationModel>> searchCities(String query) async {
    final url =
        '${AppConstants.geoPath}direct?q=${Uri.encodeQueryComponent(query)}&limit=5&appid=${AppKeys.openWeatherApiKey}';
    final res = await _apiService.get(Uri.parse(url));

    return await transformApiResponse(
      res,
      (map) => (map['data'] as List)
          .map((e) => GeoLocationModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
