import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/core/shared/constants/_constants.dart';
import 'package:weather_forecast/core/shared/models/_models.dart';
import 'package:weather_forecast/core/telemetry/_telemetry.dart';
import 'package:weather_forecast/features/weather/data/datasources/weather_local_source.dart';
import 'package:weather_forecast/features/weather/data/dtos/city_location_model.dart';
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

void main() {
  const city = CityLocationModel(id: '7', name: 'Zocca', lat: 44.3, lon: 10.9);
  const lagos =
      GeoLocationModel(name: 'Lagos', country: 'NG', lat: 6.45, lon: 3.39);

  late WeatherRepo repo;

  setUpAll(() {
    registerFallbackValue(city);
    registerFallbackValue(const WeatherDetailsViewArguments(city: city));
  });

  setUp(() {
    registerServices();
    registerDataLayers();
    repo = locator<WeatherRepo>();
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

    test('card tap logs the city id, not its name', () {
      viewModel.onCardTap(city);

      final log = logs('card tapped').single;
      expect(log.fields['city_id'], '7');
      expect(log.fields.containsKey('name'), isFalse);
    });

    test('search input is logged by length only', () {
      viewModel.onSearchQueryChanged('Silver');

      expect(logs('search changed').single.fields['query_length'], 6);
    });

    test('load is one span and one home.load event', () async {
      when(() => repo.getSavedCities()).thenAnswer((_) async => [city]);
      when(() => repo.getCurrentWeather(any()))
          .thenAnswer((_) async => _FakeWeather());

      await viewModel.init();

      expect(
        telemetryExporter.spans.any((s) => s.name == 'HomeViewModel'),
        isTrue,
      );
      final event = logs('home.load').single;
      expect(event.fields['default_cities'], AppConstants.cities.length);
      expect(event.fields['saved_cities'], 1);
      expect(event.fields['cities_loaded'], AppConstants.cities.length + 1);
      expect(event.fields['cities_failed'], 0);
      expect(event.fields['duration_ms'], isA<int>());
      expect(metric('cities.saved').value, 1);
      expect(metric('cities.saved').kind, MetricKind.gauge);
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
      expect(logs('weather load failed').single.stackTrace, isNotNull);
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

    test('a failure reaches the span instead of ending as a success', () async {
      when(() => repo.get5DayForecast(any())).thenThrow(InternetAppException());

      await viewModel.fetchForecast();

      final span = telemetryExporter.spans
          .firstWhere((s) => s.name == 'WeatherDetailsViewModel');
      expect(span.errorType, 'InternetAppException');
      expect(logs('forecast load failed').single.fields['error.type'],
          'InternetAppException');
      expect(logs('forecast load failed').single.stackTrace, isNotNull);
    });
  });

  group('AddCityViewModel', () {
    late AddCityViewModel viewModel;

    setUp(() => viewModel = AddCityViewModel());
    tearDown(() => viewModel.dispose());

    test('a search emits one city.search event', () async {
      when(() => repo.searchCities('Lagos')).thenAnswer((_) async => [lagos]);
      viewModel.query = 'Lagos';

      await viewModel.search();

      final event = logs('city.search').single;
      expect(event.fields['query_length'], 5);
      expect(event.fields['result_count'], 1);
      expect(event.fields['stale_discarded'], false);
      expect(event.fields['success'], true);
      expect(event.fields['duration_ms'], isA<int>());
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

    test('a failed search logs the error type on the event', () async {
      when(() => repo.searchCities('Lagos')).thenThrow(InternetAppException());
      viewModel.query = 'Lagos';

      await viewModel.search();

      final event = logs('city.search').single;
      expect(event.level, TelemetryLevel.error);
      expect(event.fields['success'], false);
      expect(event.fields['error.type'], 'InternetAppException');
    });

    test('a too-short query is logged as skipped', () {
      viewModel.onQueryChanged('L');

      final skipped = logs('search skipped').single;
      expect(skipped.fields['reason'], 'query_too_short');
    });

    test('a failed save is logged by type', () async {
      when(() => repo.saveCity(any())).thenThrow(StateError('disk full'));

      await viewModel.onResultTap(lagos);

      expect(
          logs('city save failed').single.fields['error.type'], 'StateError');
      expect(logs('city save failed').single.stackTrace, isNotNull);
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

    test('cached reads count a miss, tagged by cache', () async {
      when(() => storage.get(any(), key: any(named: 'key')))
          .thenAnswer((_) async => null);

      await source.getCachedCurrentWeather('7');
      await source.getCachedForecast('7');
      await source.getCachedAirQuality('7');

      final misses = telemetryExporter.metrics
          .where((m) => m.name == 'cache.miss')
          .map((m) => m.tags['cache'])
          .toList();
      expect(misses, ['weather', 'forecast', 'air_quality']);
    });

    test('a cached value counts as a hit', () async {
      when(() => storage.get(any(), key: any(named: 'key')))
          .thenAnswer((_) async => '{}');

      // The stub is not a real reading, so decoding it fails; the lookup is
      // counted before that.
      await expectLater(source.getCachedAirQuality('7'), throwsA(anything));

      expect(metric('cache.hit').tags['cache'], 'air_quality');
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
      expect(logs('saved cities parse failed').single.stackTrace, isNotNull);
    });

    test('writing saved cities is logged', () async {
      when(() => storage.put(any(),
          key: any(named: 'key'),
          value: any(named: 'value'))).thenAnswer((_) async {});

      await source.saveCities([city]);

      expect(logs('saved cities written').single.fields['saved_count'], 1);
      expect(telemetryExporter.spans, isEmpty);
    });
  });
}
