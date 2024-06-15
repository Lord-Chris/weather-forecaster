import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/core/shared/models/_models.dart';
import 'package:weather_forecast/core/shared/models/app_exception.dart';
import 'package:weather_forecast/features/weather/data/datasources/weather_local_source.dart';
import 'package:weather_forecast/features/weather/data/datasources/weather_remote_source.dart';
import 'package:weather_forecast/features/weather/data/dtos/city_location_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/forecast_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/weather_model.dart';
import 'package:weather_forecast/features/weather/data/repositories/weather_repo.dart';
import 'package:weather_forecast/services/_services.dart';

import '../../../../helpers/data_helpers.dart';
import '../../../../helpers/service_helpers.dart';

void main() {
  const testCityModel = CityLocationModel(
    id: '1',
    name: 'Zocca',
    lat: 44.34,
    lon: 10.99,
  );
  final testWeatherModel = WeatherModel.fromMap(const {
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
  });

  final testForecastModel = ForecastModel.fromMap({
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
  });
  group('WeatherRepo Tests - ', () {
    late WeatherLocalSource localSource;
    late WeatherRemoteSource remoteSource;
    late IConnectivityService connectivityService;
    late WeatherRepo repo;

    setUp(() {
      registerServices();
      registerDataLayers();

      localSource = locator<WeatherLocalSource>();
      remoteSource = locator<WeatherRemoteSource>();
      connectivityService = locator<IConnectivityService>();
      repo = WeatherRepo();
    });

    tearDown(() {
      unregisterServices();
      unregisterDataLayers();
    });

    group('getCurrentWeather - ', () {
      test('should return weather model when connected', () async {
        when(() => connectivityService.checkInternetConnection())
            .thenAnswer((_) async => true);
        when(() => remoteSource.getCurrentWeather(testCityModel))
            .thenAnswer((_) async => testWeatherModel);
        when(() => localSource.cacheWeather(testCityModel.id, testWeatherModel))
            .thenAnswer((_) async {});

        final result = await repo.getCurrentWeather(testCityModel);

        expect(result, isA<WeatherModel>());
        expect(result, isNotNull);
        expect(result, equals(testWeatherModel));
      });

      test(
          'should return cached weather model when not connected and stored value is not null',
          () async {
        when(() => connectivityService.checkInternetConnection())
            .thenAnswer((_) async => false);
        when(() => localSource.getCachedCurrentWeather(testCityModel.id))
            .thenAnswer((_) async => testWeatherModel);

        final result = await repo.getCurrentWeather(testCityModel);

        expect(result, isA<WeatherModel>());
        expect(result, isNotNull);
        expect(result, equals(testWeatherModel));
      });

      test('should return null when not connected and stored value is null',
          () async {
        when(() => connectivityService.checkInternetConnection())
            .thenAnswer((_) async => false);
        when(() => localSource.getCachedCurrentWeather(testCityModel.id))
            .thenAnswer((_) async => null);

        final result = await repo.getCurrentWeather(testCityModel);

        expect(result, isNull);
      });

      test('should rethrow an AppException when an AppException occurs',
          () async {
        when(() => connectivityService.checkInternetConnection())
            .thenAnswer((_) async => true);
        when(() => remoteSource.getCurrentWeather(testCityModel))
            .thenThrow(InternetAppException());

        expect(() => repo.getCurrentWeather(testCityModel),
            throwsA(isA<InternetAppException>()));
      });

      test('should throw FallbackAppException when an unknown error occurs',
          () async {
        when(() => connectivityService.checkInternetConnection())
            .thenAnswer((_) async => true);
        when(() => remoteSource.getCurrentWeather(testCityModel))
            .thenThrow(Exception());

        expect(() => repo.getCurrentWeather(testCityModel),
            throwsA(isA<FallbackAppException>()));
      });
    });

    group('get5DayForecast - ', () {
      test('should return forecast model when connected', () async {
        when(() => connectivityService.checkInternetConnection())
            .thenAnswer((_) async => true);
        when(() => remoteSource.get5DayForecast(testCityModel))
            .thenAnswer((_) async => testForecastModel);
        when(() =>
                localSource.cacheForecast(testCityModel.id, testForecastModel))
            .thenAnswer((_) async {});

        final result = await repo.get5DayForecast(testCityModel);

        expect(result, isA<ForecastModel>());
        expect(result, isNotNull);
        expect(result, equals(testForecastModel));
      });

      test(
          'should return cached forecast model when not connected and stored value is not null',
          () async {
        when(() => connectivityService.checkInternetConnection())
            .thenAnswer((_) async => false);
        when(() => localSource.getCachedForecast(testCityModel.id))
            .thenAnswer((_) async => testForecastModel);

        final result = await repo.get5DayForecast(testCityModel);

        expect(result, isA<ForecastModel>());
        expect(result, isNotNull);
        expect(result, equals(testForecastModel));
      });

      test('should return null when not connected and stored value is null',
          () async {
        when(() => connectivityService.checkInternetConnection())
            .thenAnswer((_) async => false);
        when(() => localSource.getCachedForecast(testCityModel.id))
            .thenAnswer((_) async => null);

        final result = await repo.get5DayForecast(testCityModel);

        expect(result, isNull);
      });

      test('should rethrow an AppException when an AppException occurs',
          () async {
        when(() => connectivityService.checkInternetConnection())
            .thenAnswer((_) async => true);
        when(() => remoteSource.get5DayForecast(testCityModel))
            .thenThrow(InternetAppException());

        expect(() => repo.get5DayForecast(testCityModel),
            throwsA(isA<InternetAppException>()));
      });

      test('should throw FallbackAppException when an unknown error occurs',
          () async {
        when(() => connectivityService.checkInternetConnection())
            .thenAnswer((_) async => true);
        when(() => remoteSource.get5DayForecast(testCityModel))
            .thenThrow(Exception());

        expect(() => repo.get5DayForecast(testCityModel),
            throwsA(isA<FallbackAppException>()));
      });
    });
  });
}
