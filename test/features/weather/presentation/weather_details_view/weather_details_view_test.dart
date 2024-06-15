import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/core/shared/widgets/_widgets.dart';
import 'package:weather_forecast/features/weather/data/dtos/city_location_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/forecast_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/weather_model.dart';
import 'package:weather_forecast/features/weather/presentation/weather_details_view/weather_details_view.dart';
import 'package:weather_forecast/features/weather/presentation/weather_details_view/weather_details_viewmodel.dart';
import 'package:weather_forecast/features/weather/presentation/widgets/city_item_card.dart';
import 'package:weather_forecast/features/weather/presentation/widgets/forecast_item_card.dart';

import '../../../../helpers/helpers.dart';
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

  group('WeatherDetailsView Test - ', () {
    late WeatherDetailsViewModel viewModel;

    setUp(() {
      registerViewModels();
      viewModel = locator<WeatherDetailsViewModel>();
    });

    tearDown(() {
      unregisterViewModels();
    });

    testWidgets(
      'should show loader when viewmodel is busy and forecast is empty',
      (WidgetTester tester) async {
        when(() => viewModel.init(testCityModel)).thenAnswer((_) async {});
        when(() => viewModel.forecast).thenReturn([]);
        when(() => viewModel.city).thenReturn(testCityModel);
        when(() => viewModel.isBusy).thenReturn(true);

        await tester.pumpWidget(
          buildTestableWidget(WeatherDetailsView(city: testCityModel)),
        );

        verify(() => viewModel.init(testCityModel)).called(1);

        expect(find.text('Current Weather'), findsOneWidget);
        expect(find.byType(CityItemCard), findsOneWidget);
        expect(find.byType(AppLoader), findsOneWidget);
      },
    );

    testWidgets(
      'should show `No forecast available` when forecast is empty',
      (WidgetTester tester) async {
        when(() => viewModel.init(testCityModel)).thenAnswer((_) async {});
        when(() => viewModel.forecast).thenReturn([]);
        when(() => viewModel.city).thenReturn(testCityModel);
        when(() => viewModel.isBusy).thenReturn(false);

        await tester.pumpWidget(
          buildTestableWidget(WeatherDetailsView(city: testCityModel)),
        );

        verify(() => viewModel.init(testCityModel)).called(1);

        expect(find.text('Current Weather'), findsOneWidget);
        expect(find.byType(CityItemCard), findsOneWidget);
        expect(find.text('No forecast available'), findsOneWidget);
        expect(find.byType(AppButton), findsOneWidget);
      },
    );

    testWidgets(
      'when forecast is empty, should call fetchForecast when refresh button is clicked',
      (WidgetTester tester) async {
        when(() => viewModel.init(testCityModel)).thenAnswer((_) async {});
        when(() => viewModel.fetchForecast()).thenAnswer((_) async {});
        when(() => viewModel.forecast).thenReturn([]);
        when(() => viewModel.city).thenReturn(testCityModel);
        when(() => viewModel.isBusy).thenReturn(false);

        await tester.pumpWidget(
          buildTestableWidget(WeatherDetailsView(city: testCityModel)),
        );

        verify(() => viewModel.init(testCityModel)).called(1);

        final buttonFinder = find.byType(AppButton);
        await tester.tap(buttonFinder);

        verify(() => viewModel.fetchForecast()).called(1);
      },
    );

    testWidgets(
      'should show forecast when forecast is available',
      (WidgetTester tester) async {
        when(() => viewModel.init(testCityModel)).thenAnswer((_) async {});
        when(() => viewModel.forecast).thenReturn(testForecastModel.list);
        when(() => viewModel.city).thenReturn(testCityModel);
        when(() => viewModel.isBusy).thenReturn(false);

        await tester.pumpWidget(
          buildTestableWidget(WeatherDetailsView(city: testCityModel)),
        );

        verify(() => viewModel.init(testCityModel)).called(1);

        expect(find.text('Current Weather'), findsOneWidget);
        expect(find.byType(CityItemCard), findsOneWidget);
        expect(find.byType(ListView), findsExactly(2));
        expect(find.byType(ForecastItemCard), findsOneWidget);
      },
    );

    testWidgets(
        'verify that viewModel.getCurrentWeather is called when pull to refresh is triggered',
        (tester) async {
      when(() => viewModel.init(testCityModel)).thenAnswer((_) async {});
      when(() => viewModel.fetchForecast()).thenAnswer((_) async {});
      when(() => viewModel.forecast).thenReturn(testForecastModel.list);
      when(() => viewModel.city).thenReturn(testCityModel);
      when(() => viewModel.isBusy).thenReturn(false);

      await tester.pumpWidget(
        buildTestableWidget(WeatherDetailsView(city: testCityModel)),
      );

      final cityList = find.byType(ListView).first;
      expect(cityList, findsOneWidget);

      await tester.fling(cityList, const Offset(0, 300), 3000);
      await tester.pumpAndSettle();
      verify(() => viewModel.fetchForecast()).called(1);
    });
  });
}
