import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/core/shared/models/_models.dart';
import 'package:weather_forecast/core/telemetry/_telemetry.dart';
import 'package:weather_forecast/features/weather/data/datasources/weather_local_source.dart';
import 'package:weather_forecast/features/weather/data/datasources/weather_remote_source.dart';
import 'package:weather_forecast/features/weather/data/dtos/city_location_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/forecast_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/weather_model.dart';
import 'package:weather_forecast/features/weather/data/repositories/weather_repo.dart';
import 'package:weather_forecast/services/_services.dart';

import '../../../helpers/data_helpers.dart';
import '../../../helpers/service_helpers.dart';

class _FakeWeather extends Fake implements WeatherModel {}

class _FakeForecast extends Fake implements ForecastModel {}

void main() {
  const city = CityLocationModel(id: '7', name: 'Zocca', lat: 44.3, lon: 10.9);

  late WeatherLocalSource local;
  late WeatherRemoteSource remote;
  late IConnectivityService connectivity;
  late WeatherRepo repo;

  setUpAll(() {
    registerFallbackValue(_FakeWeather());
    registerFallbackValue(_FakeForecast());
    registerFallbackValue(city);
  });

  setUp(() {
    registerServices();
    registerDataLayers();
    local = locator<WeatherLocalSource>();
    remote = locator<WeatherRemoteSource>();
    connectivity = locator<IConnectivityService>();
    repo = WeatherRepo();
  });

  tearDown(() {
    unregisterServices();
    unregisterDataLayers();
  });

  void online(bool value) => when(() => connectivity.checkInternetConnection())
      .thenAnswer((_) async => value);

  List<LogRecord> events() => telemetryExporter.logs
      .where((l) => l.message == 'weather.fetch')
      .toList();

  MetricRecord metric(String name) =>
      telemetryExporter.metrics.firstWhere((m) => m.name == name);

  group('wide event and RED metrics', () {
    test('a remote success emits exactly one event with the full story',
        () async {
      online(true);
      when(() => remote.getCurrentWeather(any()))
          .thenAnswer((_) async => _FakeWeather());
      when(() => local.cacheWeather(any(), any())).thenAnswer((_) async {});

      await repo.getCurrentWeather(city);

      final event = events().single;
      expect(event.level, TelemetryLevel.info);
      expect(event.fields['operation'], 'getCurrentWeather');
      expect(event.fields['city_id'], '7');
      expect(event.fields['connected'], true);
      expect(event.fields['source'], 'remote');
      expect(event.fields['success'], true);
      expect(event.fields['duration_ms'], isA<int>());
      expect(event.fields.containsKey('error.type'), isFalse);
      expect(event.stackTrace, isNull);
    });

    test('attempts, duration and the in-flight gauge are recorded', () async {
      online(true);
      when(() => remote.getCurrentWeather(any()))
          .thenAnswer((_) async => _FakeWeather());
      when(() => local.cacheWeather(any(), any())).thenAnswer((_) async {});

      await repo.getCurrentWeather(city);

      final attempts = metric('weather.fetch.attempts');
      expect(attempts.kind, MetricKind.counter);
      expect(attempts.tags['operation'], 'getCurrentWeather');
      expect(attempts.tags['source'], 'remote');
      expect(attempts.tags.containsKey('city_id'), isFalse);
      expect(metric('weather.fetch.duration').kind, MetricKind.timing);
      final inFlight = telemetryExporter.metrics
          .where((m) => m.name == 'weather.fetch.in_flight')
          .map((m) => m.value)
          .toList();
      expect(inFlight, [1, 0]);
    });

    test('offline with a cache hit records source, cache_hit and cache.hit',
        () async {
      online(false);
      when(() => local.getCachedCurrentWeather('7'))
          .thenAnswer((_) async => _FakeWeather());

      await repo.getCurrentWeather(city);

      final event = events().single;
      expect(event.fields['connected'], false);
      expect(event.fields['source'], 'cache');
      expect(event.fields['cache_hit'], true);
      expect(metric('cache.hit').tags['cache'], 'weather');
    });

    test('offline with a cache miss records cache.miss and a miss log',
        () async {
      online(false);
      when(() => local.getCachedCurrentWeather('7'))
          .thenAnswer((_) async => null);

      await repo.getCurrentWeather(city);

      expect(events().single.fields['cache_hit'], false);
      expect(metric('cache.miss').tags['cache'], 'weather');
      expect(
        telemetryExporter.logs.any((l) => l.message == 'weather cache miss'),
        isTrue,
      );
    });

    test('an app error emits one error event, counts the error and rethrows',
        () async {
      online(true);
      when(() => remote.getCurrentWeather(any()))
          .thenThrow(InternetAppException());

      await expectLater(
        repo.getCurrentWeather(city),
        throwsA(isA<InternetAppException>()),
      );

      final event = events().single;
      expect(event.level, TelemetryLevel.error);
      expect(event.fields['success'], false);
      expect(event.fields['error.type'], 'InternetAppException');
      expect(event.stackTrace, isNotNull);
      final errors = metric('weather.fetch.errors');
      expect(errors.tags['error.type'], 'InternetAppException');
      expect(errors.tags['operation'], 'getCurrentWeather');
    });

    test('an unexpected error keeps its original type before it is wrapped',
        () async {
      online(true);
      when(() => remote.getCurrentWeather(any())).thenThrow(StateError('boom'));

      await expectLater(
        repo.getCurrentWeather(city),
        throwsA(isA<FallbackAppException>()),
      );

      final wrapped = telemetryExporter.logs
          .firstWhere((l) => l.message == 'unexpected error wrapped');
      expect(wrapped.fields['error.type'], 'StateError');
      expect(wrapped.fields['service'], 'WeatherRepo');
      expect(wrapped.stackTrace, isNotNull);
      expect(events().single.fields['error.type'], 'FallbackAppException');
    });

    test('no private data reaches a log or a metric', () async {
      online(true);
      when(() => remote.getCurrentWeather(any()))
          .thenThrow(StateError('secret-token'));

      await expectLater(
        repo.getCurrentWeather(city),
        throwsA(isA<FallbackAppException>()),
      );

      final everything = [
        ...telemetryExporter.logs.map((l) => '${l.message} ${l.fields}'),
        ...telemetryExporter.metrics.map((m) => '${m.name} ${m.tags}'),
      ].join(' ');
      expect(everything, isNot(contains('secret-token')));
      expect(everything, isNot(contains('Zocca')));
    });

    test('the forecast has its own event', () async {
      online(false);
      when(() => local.getCachedForecast('7')).thenAnswer((_) async => null);

      await repo.get5DayForecast(city);

      final event = events().single;
      expect(event.fields['operation'], 'get5DayForecast');
      expect(event.fields['cache_hit'], false);
      expect(metric('cache.miss').tags['cache'], 'forecast');
    });
  });

  group('child spans', () {
    test('forecast shows the connectivity check, remote call and cache write',
        () async {
      online(true);
      when(() => remote.get5DayForecast(any()))
          .thenAnswer((_) async => _FakeForecast());
      when(() => local.cacheForecast(any(), any())).thenAnswer((_) async {});
      final parent = locator<ITelemetry>().startSpan('parent');

      await locator<ITelemetry>()
          .runWith(parent, () => repo.get5DayForecast(city));
      parent.end();

      final children =
          telemetryExporter.spans.where((s) => s.name != 'parent').toList();
      expect(children.map((s) => s.name), [
        'connectivity check',
        'remote get5DayForecast',
        'cache write forecast',
      ]);
      expect(children.every((s) => s.parentSpanId == parent.spanId), isTrue);
    });
  });

  group('silent drops and refusals', () {
    test('saving a duplicate city is logged and not written', () async {
      when(() => local.getSavedCities()).thenAnswer((_) async => [city]);

      await repo.saveCity(city);

      final skipped = telemetryExporter.logs
          .firstWhere((l) => l.message == 'city save skipped');
      expect(skipped.fields['reason'], 'duplicate');
      expect(skipped.fields['city_id'], '7');
      verifyNever(() => local.saveCities(any()));
    });

    test('searching offline is refused and logged as a warning', () async {
      online(false);

      await expectLater(
        repo.searchCities('Lagos'),
        throwsA(isA<InternetAppException>()),
      );

      final refused = telemetryExporter.logs
          .firstWhere((l) => l.message == 'search refused');
      expect(refused.level, TelemetryLevel.warning);
      expect(refused.fields['reason'], 'offline');
      expect(refused.fields['query_length'], 5);
    });
  });
}
