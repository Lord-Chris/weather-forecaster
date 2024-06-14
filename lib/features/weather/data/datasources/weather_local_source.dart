import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../services/_services.dart';
import '../../domain/entities/weather_model.dart';

class WeatherLocalSource {
  final _localStorageService = locator<ILocalStorage>();

  Future<void> cacheWeather(String cityId, WeatherModel weather) async {
    await _localStorageService.put(
      StorageKeys.weatherBox,
      key: cityId,
      value: weather.toMap(),
    );
  }

  Future<WeatherModel?> getCachedCurrentWeather(String cityId) async {
    final weather = await _localStorageService.get(
      StorageKeys.weatherBox,
      key: cityId,
    );
    return weather != null ? WeatherModel.fromMap(weather) : null;
  }
}
