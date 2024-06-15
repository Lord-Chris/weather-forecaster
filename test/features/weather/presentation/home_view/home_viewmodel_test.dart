import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/core/shared/models/_models.dart';
import 'package:weather_forecast/core/shared/models/app_exception.dart';
import 'package:weather_forecast/features/weather/data/dtos/city_location_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/weather_model.dart';
import 'package:weather_forecast/features/weather/data/repositories/weather_repo.dart';
import 'package:weather_forecast/features/weather/presentation/home_view/home_viewmodel.dart';

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

  group('HomeViewModel Tests - ', () {
    late WeatherRepo repo;
    late NavigationService navigationService;
    late HomeViewModel viewModel;

    setUp(() {
      registerServices();
      registerDataLayers();
      registerFallbackValue(testCityModel);

      repo = locator<WeatherRepo>();
      navigationService = locator<NavigationService>();
      viewModel = HomeViewModel();
    });

    tearDown(() {
      unregisterServices();
      unregisterDataLayers();
    });

    group('onSearchQueryChanged - ', () {
      test('should update searchedCities when searchQuery is changed', () {
        viewModel.onSearchQueryChanged('Silver');

        expect(viewModel.searchedCities.length, 1);
        expect(viewModel.searchedCities.first.name, 'Silverstone, UK');
        expect(viewModel.cities, viewModel.searchedCities);
      });

      test('should update searchedCities when searchQuery is empty', () {
        viewModel.onSearchQueryChanged('');

        expect(viewModel.searchedCities.length, 0);
        expect(viewModel.cities, viewModel.allCities);
      });

      test('should update searchedCities when searchQuery is not found', () {
        viewModel.onSearchQueryChanged('Not Found');

        expect(viewModel.searchedCities.length, 0);
        expect(viewModel.cities, viewModel.searchedCities);
      });
    });

    group('getCurrentWeather - ', () {
      test('should update allCities with weather data', () async {
        when(() => repo.getCurrentWeather(any()))
            .thenAnswer((_) async => testWeatherModel);

        await viewModel.getCurrentWeather();

        expect(viewModel.allCities.first.weather, isA<WeatherModel>());
        expect(viewModel.allCities.first.weather, equals(testWeatherModel));
      });

      test(
          'weatherRepo.getCurrentWeather should be called number of times equal to cities length',
          () async {
        when(() => repo.getCurrentWeather(any()))
            .thenAnswer((_) async => testWeatherModel);

        await viewModel.getCurrentWeather();

        verify(() => repo.getCurrentWeather(any()))
            .called(viewModel.allCities.length);
      });

      test('should log error when getCurrentWeather fails', () async {
        when(() => repo.getCurrentWeather(any()))
            .thenThrow(InternetAppException());

        await viewModel.getCurrentWeather();

        expect(viewModel.allCities.first.weather, isNull);
      });
    });

    group('onCardTap - ', () {
      test('should navigate to WeatherDetailsView', () {
        viewModel.onCardTap(testCityModel);

        verify(() => navigationService.navigateTo(
              Routes.weatherDetailsView,
              arguments: const WeatherDetailsViewArguments(city: testCityModel),
            ));
      });
    });
  });
}
