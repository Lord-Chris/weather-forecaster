import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/core/shared/models/_models.dart';
import 'package:weather_forecast/features/weather/data/dtos/city_location_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/geo_location_model.dart';
import 'package:weather_forecast/features/weather/data/repositories/weather_repo.dart';
import 'package:weather_forecast/features/weather/presentation/add_city_view/add_city_viewmodel.dart';

import '../../../../helpers/data_helpers.dart';
import '../../../../helpers/service_helpers.dart';

void main() {
  const lagos = GeoLocationModel(
    name: 'Lagos',
    country: 'NG',
    lat: 6.45,
    lon: 3.39,
  );

  group('AddCityViewModel Tests - ', () {
    late WeatherRepo repo;
    late NavigationService navigationService;
    late AddCityViewModel viewModel;

    setUp(() {
      registerServices();
      registerDataLayers();
      registerFallbackValue(
        const CityLocationModel(id: '1', name: 'a', lat: 0, lon: 0),
      );
      repo = locator<WeatherRepo>();
      navigationService = locator<NavigationService>();
      viewModel = AddCityViewModel();
    });

    tearDown(() {
      unregisterDataLayers();
      unregisterServices();
    });

    test('search should store the results', () async {
      when(() => repo.searchCities('Lagos')).thenAnswer((_) async => [lagos]);
      viewModel.query = 'Lagos';

      await viewModel.search();

      expect(viewModel.results, [lagos]);
      expect(viewModel.errorMessage, isNull);
    });

    test('search should expose the error message on failure', () async {
      when(() => repo.searchCities('Lagos'))
          .thenThrow(InternetAppException());
      viewModel.query = 'Lagos';

      await viewModel.search();

      expect(viewModel.results, isEmpty);
      expect(viewModel.errorMessage, contains('internet'));
    });

    test('short queries should clear results without calling the repo', () {
      viewModel.onQueryChanged('L');

      expect(viewModel.results, isEmpty);
      verifyNever(() => repo.searchCities(any()));
    });

    test('onResultTap should save the city and go back with true', () async {
      when(() => repo.saveCity(any())).thenAnswer((_) async {});

      await viewModel.onResultTap(lagos);

      verify(() => repo.saveCity(lagos.toCityLocationModel())).called(1);
      verify(() => navigationService.back(result: true)).called(1);
    });
  });
}
