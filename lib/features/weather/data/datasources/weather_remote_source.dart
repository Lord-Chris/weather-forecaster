import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/utilities/transformer.dart';
import '../../../../services/_services.dart';
import '../dtos/city_location_model.dart';
import '../dtos/forecast_model.dart';
import '../dtos/weather_model.dart';

class WeatherRemoteSource {
  static const apiKey = '851733971fa35ff568fed67cb41b575b';
  final _apiService = locator<IApi>();

  Future<WeatherModel> getCurrentWeather(CityLocationModel city) async {
    final url =
        '${AppConstants.basePath}weather?lat=${city.lat}&lon=${city.lon}&appid=$apiKey';
    final res = await _apiService.get(Uri.parse(url));

    return await transformApiResponse(res, WeatherModel.fromMap);
  }

  Future<ForecastModel> get5DayForecast(CityLocationModel city) async {
    final url =
        '${AppConstants.basePath}forecast?lat=${city.lat}&lon=${city.lon}&appid=$apiKey';
    final res = await _apiService.get(Uri.parse(url));

    return await transformApiResponse(res, ForecastModel.fromMap);
  }
}
