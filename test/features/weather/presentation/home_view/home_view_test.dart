import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/core/shared/widgets/_widgets.dart';
import 'package:weather_forecast/features/weather/data/dtos/city_location_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/weather_model.dart';
import 'package:weather_forecast/features/weather/presentation/home_view/home_view.dart';
import 'package:weather_forecast/features/weather/presentation/home_view/home_viewmodel.dart';
import 'package:weather_forecast/features/weather/presentation/widgets/city_item_card.dart';

import '../../../../helpers/viewmodel_helpers.dart';

void main() {
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

  final testCityModel = CityLocationModel(
    id: '1',
    name: 'Zocca',
    lat: 44.34,
    lon: 10.99,
    weather: testWeatherModel,
  );
  group('HomeView Test - ', () {
    late HomeViewModel viewModel;
    setUp(() {
      registerViewModels();
      viewModel = locator<HomeViewModel>();
    });

    testWidgets(
        'should show the text `Weather Forecaster` and a loader when the view is loading initially',
        (tester) async {
      when(() => viewModel.getCurrentWeather())
          .thenAnswer((_) async => testCityModel);
      when(() => viewModel.allCities).thenReturn([]);
      when(() => viewModel.isBusy).thenReturn(true);
      when(() => viewModel.cities).thenReturn([]);

      await tester.pumpWidget(const MaterialApp(home: HomeView()));
      verify(() => viewModel.getCurrentWeather()).called(1);
      verify(() => viewModel.allCities).called(1);

      final header = find.text('Weather Forecaster');
      expect(header, findsOneWidget);

      final loader = find.byType(AppLoader);
      expect(loader, findsOneWidget);
    });

    testWidgets(
        'should show the text `No cities found` when the view is loaded and no cities are available',
        (tester) async {
      when(() => viewModel.getCurrentWeather())
          .thenAnswer((_) async => testCityModel);
      when(() => viewModel.allCities).thenReturn([]);
      when(() => viewModel.isBusy).thenReturn(false);
      when(() => viewModel.cities).thenReturn([]);

      await tester.pumpWidget(const MaterialApp(home: HomeView()));

      final noCitiesavailable = find.text('No cities available');
      expect(noCitiesavailable, findsOneWidget);

      final refreshButton = find.text('Refresh');
      final refreshButtonWidget = find.byType(AppButton);
      expect(refreshButton, findsOneWidget);
      expect(refreshButtonWidget, findsOneWidget);
    });

    testWidgets(
        'verify that viewModel.getCurrentWeather is called when refresh button is clicked and no cities are available',
        (tester) async {
      when(() => viewModel.getCurrentWeather())
          .thenAnswer((_) async => testCityModel);
      when(() => viewModel.allCities).thenReturn([]);
      when(() => viewModel.isBusy).thenReturn(false);
      when(() => viewModel.cities).thenReturn([]);

      await tester.pumpWidget(const MaterialApp(home: HomeView()));
      verify(() => viewModel.getCurrentWeather()).called(1);
      expect(viewModel.allCities, isEmpty);

      final noCitiesavailable = find.text('No cities available');
      expect(noCitiesavailable, findsOneWidget);

      await tester.tap(find.text('Refresh'));
      await tester.pump();
      verify(() => viewModel.getCurrentWeather()).called(1);
    });

    testWidgets(
        'should show a search field and a list of cities when the view is loaded and cities are available',
        (tester) async {
      when(() => viewModel.getCurrentWeather())
          .thenAnswer((_) async => testCityModel);
      when(() => viewModel.allCities).thenReturn([testCityModel]);
      when(() => viewModel.isBusy).thenReturn(false);
      when(() => viewModel.cities).thenReturn([testCityModel]);

      await tester.pumpWidget(const MaterialApp(home: HomeView()));

      final searchField = find.byType(AppTextField);
      expect(searchField, findsOneWidget);

      final cityCard = find.byType(CityItemCard);
      expect(cityCard, findsOneWidget);

      final cityName = find.text('Zocca');
      expect(cityName, findsOneWidget);
    });

    testWidgets(
        'verify that viewModel.getCurrentWeather is called when pull to refresh is triggered',
        (tester) async {
      when(() => viewModel.getCurrentWeather())
          .thenAnswer((_) async => testCityModel);
      when(() => viewModel.allCities).thenReturn([testCityModel]);
      when(() => viewModel.isBusy).thenReturn(false);
      when(() => viewModel.cities).thenReturn([testCityModel]);

      await tester.pumpWidget(const MaterialApp(home: HomeView()));

      final cityList = find.byType(ListView);
      expect(cityList, findsOneWidget);

      await tester.fling(cityList, const Offset(0, 300), 3000);
      await tester.pump();
      verify(() => viewModel.getCurrentWeather()).called(1);
    });
  });
}
