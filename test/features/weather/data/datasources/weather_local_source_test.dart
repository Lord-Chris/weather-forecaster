import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/core/shared/constants/storage_keys.dart';
import 'package:weather_forecast/features/weather/data/datasources/weather_local_source.dart';
import 'package:weather_forecast/features/weather/data/dtos/forecast_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/weather_model.dart';
import 'package:weather_forecast/services/_services.dart';

import '../../../../helpers/service_helpers.dart';

void main() {
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

  group('WeatherLocalSource', () {
    late WeatherLocalSource localSource;
    late ILocalStorage localStorage;

    setUp(() {
      registerServices();
      localStorage = locator<ILocalStorage>();
      localSource = WeatherLocalSource();
    });

    tearDown(() {
      reset(localStorage);
      unregisterServices();
    });

    group('cacheWeather', () {
      const cityId = '2';
      final weatherModel = WeatherModel.fromMap(testWeatherModel);
      test('should call localStorage.put with the right data', () async {
        when(() => localStorage.put(any(),
            key: any(named: 'key'),
            value: any(named: 'value'))).thenAnswer((_) async {});

        // act
        await localSource.cacheWeather(cityId, weatherModel);

        // assert
        verify(() => localStorage.put(StorageKeys.weatherBox,
            key: cityId, value: weatherModel.toJson())).called(1);
      });
    });

    group('getCachedCurrentWeather', () {
      const cityId = '2';
      final weatherModel = WeatherModel.fromMap(testWeatherModel);
      test('should call localStorage.get with the right data', () async {
        when(() => localStorage.get(any(), key: any(named: 'key')))
            .thenAnswer((_) async => jsonEncode(testWeatherModel));
        // act
        await localSource.getCachedCurrentWeather(cityId);

        // assert
        verify(() => localStorage.get(StorageKeys.weatherBox, key: cityId))
            .called(1);
      });

      test('should return WeatherModel when localStorage.get returns a value',
          () async {
        when(() => localStorage.get(any(), key: any(named: 'key')))
            .thenAnswer((_) async => jsonEncode(testWeatherModel));
        // act
        final result = await localSource.getCachedCurrentWeather(cityId);

        // assert
        expect(result?.id, weatherModel.id);
      });

      test('should return null when localStorage.get returns null', () async {
        when(() => localStorage.get(any(), key: any(named: 'key')))
            .thenAnswer((_) async => null);
        // act
        final result = await localSource.getCachedCurrentWeather(cityId);

        // assert
        expect(result, null);
      });
    });

    group('cacheForecast', () {
      const cityId = '2';
      final forecastModel = ForecastModel.fromMap(testForecastModel);
      test('should call localStorage.put with the right data', () async {
        when(() => localStorage.put(any(),
            key: any(named: 'key'),
            value: any(named: 'value'))).thenAnswer((_) async {});

        // act
        await localSource.cacheForecast(cityId, forecastModel);

        // assert
        verify(() => localStorage.put(StorageKeys.forecastBox,
            key: cityId, value: forecastModel.toJson())).called(1);
      });
    });

    group('getCachedForecast', () {
      const cityId = '2';
      final forecastModel = ForecastModel.fromMap(testForecastModel);
      test('should call localStorage.get with the right data', () async {
        when(() => localStorage.get(any(), key: any(named: 'key')))
            .thenAnswer((_) async => jsonEncode(testForecastModel));
        // act
        await localSource.getCachedForecast(cityId);

        // assert
        verify(() => localStorage.get(StorageKeys.forecastBox, key: cityId))
            .called(1);
      });

      test('should return ForecastModel when localStorage.get returns a value',
          () async {
        when(() => localStorage.get(any(), key: any(named: 'key')))
            .thenAnswer((_) async => jsonEncode(testForecastModel));
        // act
        final result = await localSource.getCachedForecast(cityId);

        // assert
        expect(result?.city.id, forecastModel.city.id);
      });
      test('should return null when localStorage.get returns null', () async {
        when(() => localStorage.get(any(), key: any(named: 'key')))
            .thenAnswer((_) async => null);
        // act
        final result = await localSource.getCachedForecast(cityId);

        // assert
        expect(result, null);
      });
    });
  });
}
