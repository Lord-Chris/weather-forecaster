import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/core/shared/constants/_constants.dart';
import 'package:weather_forecast/core/shared/models/_models.dart';
import 'package:weather_forecast/core/telemetry/_telemetry.dart';
import 'package:weather_forecast/features/weather/data/datasources/weather_local_source.dart';
import 'package:weather_forecast/features/weather/data/dtos/city_location_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/forecast_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/geo_location_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/weather_model.dart';
import 'package:weather_forecast/features/weather/data/repositories/weather_repo.dart';
import 'package:weather_forecast/features/weather/presentation/add_city_view/add_city_viewmodel.dart';
import 'package:weather_forecast/features/weather/presentation/home_view/home_viewmodel.dart';
import 'package:weather_forecast/features/weather/presentation/weather_details_view/weather_details_viewmodel.dart';
import 'package:weather_forecast/services/_services.dart';

import '../../../helpers/data_helpers.dart';
import '../../../helpers/service_helpers.dart';

class _FakeWeather extends Fake implements WeatherModel {}

class _FakeForecast extends Fake implements ForecastModel {
  @override
  List<ListElement> get list => [];
}

void main() {
  const city = CityLocationModel(id: '7', name: 'Zocca', lat: 44.3, lon: 10.9);
  const lagos =
      GeoLocationModel(name: 'Lagos', country: 'NG', lat: 6.45, lon: 3.39);

  late WeatherRepo repo;
  late NavigationService navigation;

  setUpAll(() {
    registerFallbackValue(city);
    registerFallbackValue(const WeatherDetailsViewArguments(city: city));
  });

  setUp(() {
    registerServices();
    registerDataLayers();
    repo = locator<WeatherRepo>();
    navigation = locator<NavigationService>();
  });

  tearDown(() {
    unregisterServices();
    unregisterDataLayers();
  });

  List<LogRecord> logs(String message) =>
      telemetryExporter.logs.where((l) => l.message == message).toList();

  MetricRecord metric(String name) =>
      telemetryExporter.metrics.firstWhere((m) => m.name == name);

  group('HomeViewModel', () {
    late HomeViewModel viewModel;

    setUp(() => viewModel = HomeViewModel());

    test('card tap counts a ui.action and logs the city id, not its name', () {
      viewModel.onCardTap(city);

      expect(metric('ui.action').tags, containsPair('action', 'card_tap'));
      final log = logs('card tapped').single;
      expect(log.fields['city_id'], '7');
      expect(log.fields.containsKey('name'), isFalse);
    });

    test('search input is logged by length only', () {
      viewModel.onSearchQueryChanged('Silver');

      expect(logs('search changed').single.fields['query_length'], 6);
    });

    test('add city tap counts a ui.action', () async {
      when(() => navigation.navigateTo(any())).thenAnswer((_) async => false);

      await viewModel.onAddCityTap();

      expect(metric('ui.action').tags['action'], 'add_city');
    });

    test('load is one span with the city count and one home.load event',
        () async {
      when(() => repo.getSavedCities()).thenAnswer((_) async => [city]);
      when(() => repo.getCurrentWeather(any()))
          .thenAnswer((_) async => _FakeWeather());

      await viewModel.init();

      final span =
          telemetryExporter.spans.firstWhere((s) => s.name == 'HomeViewModel');
      expect(span.attributes['cities'], AppConstants.cities.length + 1);
      final event = logs('home.load').single;
      expect(event.fields['default_cities'], AppConstants.cities.length);
      expect(event.fields['saved_cities'], 1);
      expect(event.fields['cities_loaded'], AppConstants.cities.length + 1);
      expect(event.fields['cities_failed'], 0);
      expect(event.fields['duration_ms'], isA<int>());
      expect(metric('cities.saved').value, 1);
      expect(metric('cities.saved').kind, MetricKind.gauge);
      expect(metric('cities.displayed').value, AppConstants.cities.length + 1);
      expect(metric('screen.load.duration').tags['screen'], 'home');
    });

    test(
        'a failed load reports every city as failed and the span has the error',
        () async {
      when(() => repo.getSavedCities()).thenAnswer((_) async => []);
      when(() => repo.getCurrentWeather(any()))
          .thenThrow(InternetAppException());

      await viewModel.init();

      expect(logs('home.load').single.fields['cities_failed'],
          AppConstants.cities.length);
      expect(logs('weather load failed').single.fields['error.type'],
          'InternetAppException');
      expect(
        telemetryExporter.spans
            .firstWhere((s) => s.name == 'HomeViewModel')
            .errorType,
        'InternetAppException',
      );
    });

    test('a saved-cities failure is logged and the load carries on', () async {
      when(() => repo.getSavedCities()).thenThrow(const FormatException('bad'));
      when(() => repo.getCurrentWeather(any()))
          .thenAnswer((_) async => _FakeWeather());

      await viewModel.init();

      expect(logs('saved cities load failed').single.fields['error.type'],
          'FormatException');
      expect(logs('home.load').single.fields['cities_loaded'],
          AppConstants.cities.length);
    });
  });

  group('WeatherDetailsViewModel', () {
    late WeatherDetailsViewModel viewModel;

    setUp(() => viewModel = WeatherDetailsViewModel()..city = city);

    test('a log written inside the work carries its span trace and span ids',
        () async {
      when(() => repo.get5DayForecast(any()))
          .thenAnswer((_) async => _FakeForecast());

      await viewModel.fetchForecast();

      final span = telemetryExporter.spans
          .firstWhere((s) => s.name == 'WeatherDetailsViewModel');
      final log = logs('forecast fetch').single;
      expect(log.traceId, span.traceId);
      expect(log.spanId, span.spanId);
      expect(metric('screen.load.duration').tags['screen'], 'details');
    });

    test('a failure reaches the span instead of ending as a success', () async {
      when(() => repo.get5DayForecast(any())).thenThrow(InternetAppException());

      await viewModel.fetchForecast();

      final span = telemetryExporter.spans
          .firstWhere((s) => s.name == 'WeatherDetailsViewModel');
      expect(span.errorType, 'InternetAppException');
      expect(logs('forecast load failed').single.fields['error.type'],
          'InternetAppException');
    });

    test('air quality tap counts a ui.action', () {
      when(() =>
              navigation.navigateTo(any(), arguments: any(named: 'arguments')))
          .thenAnswer((_) async => null);

      viewModel.onAirQualityTap();

      expect(metric('ui.action').tags['action'], 'air_quality');
      expect(logs('air quality tapped').single.fields['city_id'], '7');
    });
  });

  group('AddCityViewModel', () {
    late AddCityViewModel viewModel;

    setUp(() => viewModel = AddCityViewModel());
    tearDown(() => viewModel.dispose());

    test('a search emits one city.search event, a count and a timing',
        () async {
      when(() => repo.searchCities('Lagos')).thenAnswer((_) async => [lagos]);
      viewModel.query = 'Lagos';

      await viewModel.search();

      final event = logs('city.search').single;
      expect(event.fields['query_length'], 5);
      expect(event.fields['result_count'], 1);
      expect(event.fields['stale_discarded'], false);
      expect(event.fields['success'], true);
      expect(event.fields['duration_ms'], isA<int>());
      expect(metric('city.search.count').tags['success'], true);
      expect(metric('city.search.duration').kind, MetricKind.timing);
      expect(
        telemetryExporter.spans.any((s) => s.name == 'AddCityViewModel'),
        isTrue,
      );
    });

    test('a stale response is discarded, counted and flagged on the event',
        () async {
      when(() => repo.searchCities('Lagos')).thenAnswer((_) async {
        viewModel.query = 'Lagos, Nigeria';
        return [lagos];
      });
      viewModel.query = 'Lagos';

      await viewModel.search();

      expect(viewModel.results, isEmpty);
      expect(logs('city.search').single.fields['stale_discarded'], true);
      expect(
          logs('search response discarded').single.fields['reason'], 'stale');
      expect(metric('city.search.stale_discarded').kind, MetricKind.counter);
    });

    test('a failed search logs the error type on the event and the span',
        () async {
      when(() => repo.searchCities('Lagos')).thenThrow(InternetAppException());
      viewModel.query = 'Lagos';

      await viewModel.search();

      final event = logs('city.search').single;
      expect(event.level, TelemetryLevel.error);
      expect(event.fields['success'], false);
      expect(event.fields['error.type'], 'InternetAppException');
      expect(
        telemetryExporter.spans
            .firstWhere((s) => s.name == 'AddCityViewModel')
            .errorType,
        'InternetAppException',
      );
    });

    test('a too-short query is logged as skipped and makes no search span', () {
      viewModel.onQueryChanged('L');

      final skipped = logs('search skipped').single;
      expect(skipped.fields['reason'], 'query_too_short');
      expect(telemetryExporter.spans, isEmpty);
    });

    test('a failed save is logged by type', () async {
      when(() => repo.saveCity(any())).thenThrow(StateError('disk full'));

      await viewModel.onResultTap(lagos);

      expect(
          logs('city save failed').single.fields['error.type'], 'StateError');
      expect(
          logs('add city result tapped').single.fields['city_id'], isNotNull);
    });
  });

  group('WeatherLocalSource', () {
    late ILocalStorage storage;
    late WeatherLocalSource source;

    setUp(() {
      storage = locator<ILocalStorage>();
      // The real source, not the mock the data layers registered.
      source = WeatherLocalSource();
    });

    test('reading saved cities logs the count and traces the read', () async {
      when(() => storage.get(any(), key: any(named: 'key'))).thenAnswer(
        (_) async => json.encode([city.toMap()]),
      );

      final cities = await source.getSavedCities();

      expect(cities.length, 1);
      final log = logs('saved cities read').single;
      expect(log.fields['saved_count'], 1);
      expect(log.fields['cache_hit'], true);
      expect(telemetryExporter.spans.single.name, 'storage read saved_cities');
    });

    test('an empty store is logged as a miss', () async {
      when(() => storage.get(any(), key: any(named: 'key')))
          .thenAnswer((_) async => null);

      expect(await source.getSavedCities(), isEmpty);

      expect(logs('saved cities read').single.fields['cache_hit'], false);
    });

    test('a corrupt store logs a parse failure and rethrows', () async {
      when(() => storage.get(any(), key: any(named: 'key')))
          .thenAnswer((_) async => 'not json');

      await expectLater(
          source.getSavedCities(), throwsA(isA<FormatException>()));

      expect(logs('saved cities parse failed').single.fields['error.type'],
          'FormatException');
    });

    test('writing saved cities is traced and counted', () async {
      when(() => storage.put(any(),
          key: any(named: 'key'),
          value: any(named: 'value'))).thenAnswer((_) async {});

      await source.saveCities([city]);

      expect(logs('saved cities written').single.fields['saved_count'], 1);
      expect(telemetryExporter.spans.single.name, 'storage write saved_cities');
    });
  });
}
