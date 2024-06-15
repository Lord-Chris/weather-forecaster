import '../../../../core/app/_app.dart';
import '../../../../core/utilities/transformer.dart';
import '../../../../services/_services.dart';
import '../../domain/entities/city_location_model.dart';
import '../../domain/entities/forecast_model.dart';
import '../../domain/entities/weather_model.dart';

class WeatherRemoteSource {
  static const apiKey = '851733971fa35ff568fed67cb41b575b';
  final _apiService = locator<IApi>();

  Future<WeatherModel> getCurrentWeather(CityLocationModel city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=${city.lat}&lon=${city.lon}&appid=$apiKey';
    final res = await _apiService.get(Uri.parse(url));

    return await transformApiResponse(res, WeatherModel.fromMap);
  }

  Future<ForecastModel> get5DayForecast(CityLocationModel city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=${city.lat}&lon=${city.lon}&appid=$apiKey';
    final res = await _apiService.get(Uri.parse(url));

    return await transformApiResponse(res, ForecastModel.fromMap);
  }
}
