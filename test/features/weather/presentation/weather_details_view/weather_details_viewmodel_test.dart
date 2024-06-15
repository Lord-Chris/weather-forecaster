import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/features/weather/data/dtos/city_location_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/forecast_model.dart';
import 'package:weather_forecast/features/weather/data/repositories/weather_repo.dart';
import 'package:weather_forecast/features/weather/presentation/weather_details_view/weather_details_viewmodel.dart';

import '../../../../helpers/data_helpers.dart';

void main() {
  const testCityModel = CityLocationModel(
    id: '1',
    name: 'SilverStone, UK',
    lat: 44.34,
    lon: 10.99,
  );
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
  group('WeatherDetailsViewModel Tests - ', () {
    late WeatherRepo repo;
    late WeatherDetailsViewModel viewModel;

    setUp(() {
      registerDataLayers();
      registerFallbackValue(testCityModel);

      repo = locator<WeatherRepo>();
      viewModel = WeatherDetailsViewModel();
    });

    tearDown(() {
      unregisterDataLayers();
    });

    group('init - ', () {
      test('should set city and call fetchForecast()', () {
        when(() => repo.get5DayForecast(testCityModel))
            .thenAnswer((_) async => testForecastModel);

        viewModel.init(testCityModel);

        expect(viewModel.city, testCityModel);
        verify(() => repo.get5DayForecast(testCityModel)).called(1);
      });
    });

    group('fetchForecast - ', () {
      test('should set forecast when successful', () async {
        when(() => repo.get5DayForecast(testCityModel))
            .thenAnswer((_) async => testForecastModel);

        viewModel.init(testCityModel);
        await viewModel.fetchForecast();

        expect(viewModel.forecast, testForecastModel.list);
      });
    });
  });
}
