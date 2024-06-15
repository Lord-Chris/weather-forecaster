import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/core/shared/models/_models.dart';
import 'package:weather_forecast/features/weather/data/datasources/weather_remote_source.dart';
import 'package:weather_forecast/features/weather/data/dtos/city_location_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/forecast_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/weather_model.dart';
import 'package:weather_forecast/services/_services.dart';

import '../../../../helpers/service_helpers.dart';

void main() {
  const testCityModel = CityLocationModel(
    id: '1',
    name: 'Zocca',
    lat: 44.34,
    lon: 10.99,
  );
  final testWeatherModel = {
    'coord': {'lon': 10.99, 'lat': 44.34},
    'weather': [
      {'id': 501, 'main': 'Rain', 'description': 'moderate rain', 'icon': '10d'}
    ],
    'base': 'stations',
    'main': {
      'temp': 298.48,
      'feels_like': 298.74,
      'temp_min': 297.56,
      'temp_max': 300.05,
      'pressure': 1015,
      'humidity': 64,
      'sea_level': 1015,
      'grnd_level': 933
    },
    'visibility': 10000,
    'wind': {'speed': 0.62, 'deg': 349, 'gust': 1.18},
    'rain': {'1h': 3.16},
    'clouds': {'all': 100},
    'dt': 1661870592,
    'sys': {
      'type': 2,
      'id': 2075663,
      'country': 'IT',
      'sunrise': 1661834187,
      'sunset': 1661882248
    },
    'timezone': 7200,
    'id': 3163858,
    'name': 'Zocca',
    'cod': 200
  };

  final testForecastModel = {
    'cod': '200',
    'message': 0,
    'cnt': 40,
    'list': [
      {
        'dt': 1661871600,
        'main': {
          'temp': 296.76,
          'feels_like': 296.98,
          'temp_min': 296.76,
          'temp_max': 297.87,
          'pressure': 1015,
          'sea_level': 1015,
          'grnd_level': 933,
          'humidity': 69,
          'temp_kf': -1.11
        },
        'weather': [
          {
            'id': 500,
            'main': 'Rain',
            'description': 'light rain',
            'icon': '10d'
          }
        ],
        'clouds': {'all': 100},
        'wind': {'speed': 0.62, 'deg': 349, 'gust': 1.18},
        'visibility': 10000,
        'pop': 0.32,
        'rain': {'3h': 0.26},
        'sys': {'pod': 'd'},
        'dt_txt': '2022-08-30 15:00:00'
      },
    ],
    'city': {
      'id': 3163858,
      'name': 'Zocca',
      'coord': {'lat': 44.34, 'lon': 10.99},
      'country': 'IT',
      'population': 4593,
      'timezone': 7200,
      'sunrise': 1661834187,
      'sunset': 1661882248
    }
  };

  group('WeatherRemoteSource', () {
    late WeatherRemoteSource remoteSource;
    late IApi apiService;

    setUp(() {
      registerServices();
      registerFallbackValue(Uri.parse('https://example.com'));
      apiService = locator<IApi>();
      remoteSource = WeatherRemoteSource();
    });

    tearDown(() {
      reset(apiService);
      unregisterServices();
    });

    group('getCurrentWeather', () {
      test('should return WeatherModel when the call is successful', () async {
        when(() => apiService.get(any()))
            .thenAnswer((_) async => testWeatherModel);

        final result = await remoteSource.getCurrentWeather(testCityModel);

        expect(result, isA<WeatherModel>());
      });

      test('should throw an app exception when the call is unsuccessful', () {
        when(() => apiService.get(any())).thenThrow(InternetAppException());

        expect(() => remoteSource.getCurrentWeather(testCityModel),
            throwsA(isA<InternetAppException>()));
      });

      test(
          'should throw an app exception when the call returns an unexpected map',
          () {
        when(() => apiService.get(any())).thenAnswer((_) async => {});

        expect(() => remoteSource.getCurrentWeather(testCityModel),
            throwsA(isA<ObjectParserAppException>()));
      });
    });

    group('get5DayForecast', () {
      test('should return ForecastModel when the call is successful', () async {
        when(() => apiService.get(any()))
            .thenAnswer((_) async => testForecastModel);

        final result = await remoteSource.get5DayForecast(testCityModel);

        expect(result, isA<ForecastModel>());
      });

      test('should throw an app exception when the call is unsuccessful', () {
        when(() => apiService.get(any())).thenThrow(InternetAppException());

        expect(() => remoteSource.get5DayForecast(testCityModel),
            throwsA(isA<InternetAppException>()));
      });

      test(
          'should throw an app exception when the call returns an unexpected map',
          () {
        when(() => apiService.get(any())).thenAnswer((_) async => {});

        expect(() => remoteSource.get5DayForecast(testCityModel),
            throwsA(isA<ObjectParserAppException>()));
      });
    });
  });
}
