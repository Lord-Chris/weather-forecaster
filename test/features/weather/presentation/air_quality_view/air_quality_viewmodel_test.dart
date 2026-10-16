import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/core/shared/models/_models.dart';
import 'package:weather_forecast/core/telemetry/_telemetry.dart';
import 'package:weather_forecast/features/weather/data/dtos/air_quality_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/city_location_model.dart';
import 'package:weather_forecast/features/weather/data/repositories/weather_repo.dart';
import 'package:weather_forecast/features/weather/presentation/air_quality_view/air_quality_viewmodel.dart';

import '../../../../helpers/data_helpers.dart';
import '../../../../helpers/helpers.dart';
import '../../../../helpers/service_helpers.dart';
import '../../data/dtos/air_quality_and_geo_model_test.dart';
import '../../../../helpers/in_memory_exporter.dart';

void main() {
  const city = CityLocationModel(id: '1', name: 'Lagos', lat: 6.5, lon: 3.4);

  group('AirQualityViewModel Tests - ', () {
    late WeatherRepo repo;
    late AirQualityViewModel viewModel;
    late InMemoryExporter exporter;

    setUp(() {
      exporter = getAndRegisterTelemetry();
      registerDataLayers();
      registerFallbackValue(city);
      repo = locator<WeatherRepo>();
      viewModel = AirQualityViewModel()..city = city;
    });

    tearDown(() {
      unregisterDataLayers();
      removeRegistrationIfExists<Telemetry>();
    });

    test('fetchAirQuality should set the reading when successful', () async {
      final reading = AirQualityModel.fromMap(airQualityResponse);
      when(() => repo.getAirQuality(city)).thenAnswer((_) async => reading);

      await viewModel.fetchAirQuality();

      expect(viewModel.airQuality, reading);
      expect(viewModel.isBusy, isFalse);
    });

    test('fetchAirQuality should leave the reading null on IAppException',
        () async {
      when(() => repo.getAirQuality(city)).thenThrow(InternetAppException());

      await viewModel.fetchAirQuality();

      expect(viewModel.airQuality, isNull);
      expect(viewModel.isBusy, isFalse);
    });

    test('fetchAirQuality should log the error by type', () async {
      when(() => repo.getAirQuality(city)).thenThrow(InternetAppException());

      await viewModel.fetchAirQuality();

      final log = exporter.logs
          .firstWhere((l) => l.message == 'air quality load failed');
      expect(log.fields['error.type'], 'InternetAppException');
      expect(log.fields['operation'], 'fetchAirQuality');
      expect(log.stackTrace, isNotNull);
    });
  });
}
