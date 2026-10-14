import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/features/weather/data/dtos/air_quality_model.dart';
import 'package:weather_forecast/features/weather/data/dtos/geo_location_model.dart';

const airQualityResponse = {
  'coord': {'lon': 3.39, 'lat': 6.52},
  'list': [
    {
      'main': {'aqi': 3},
      'components': {
        'co': 500.5,
        'no': 0.1,
        'no2': 12,
        'o3': 60.2,
        'so2': 3.3,
        'pm2_5': 22.4,
        'pm10': 40.1,
        'nh3': 1.5,
      },
      'dt': 1661870592,
    }
  ],
};

void main() {
  group('AirQualityModel Test - ', () {
    test('fromMap should read the first reading', () {
      final model = AirQualityModel.fromMap(airQualityResponse);

      expect(model.aqi, 3);
      expect(model.pm25, 22.4);
      expect(model.no2, 12.0);
      expect(model.aqiLabel, 'Moderate');
    });

    test('toJson then fromJson should round trip', () {
      final model = AirQualityModel.fromMap(airQualityResponse);

      expect(AirQualityModel.fromJson(model.toJson()), model);
    });

    test('components should list PM2.5 first', () {
      final model = AirQualityModel.fromMap(airQualityResponse);

      expect(model.components.keys.first, 'PM2.5');
      expect(model.components.length, 8);
    });
  });

  group('GeoLocationModel Test - ', () {
    test('fromMap should parse and build a display name', () {
      final model = GeoLocationModel.fromMap(const {
        'name': 'Lagos',
        'lat': 6.4550575,
        'lon': 3.3941795,
        'country': 'NG',
        'state': 'Lagos',
      });

      expect(model.displayName, 'Lagos, Lagos, NG');
      expect(model.toCityLocationModel().id, '6.4551_3.3942');
    });

    test('displayName should skip a missing state', () {
      final model = GeoLocationModel.fromMap(const {
        'name': 'Paris',
        'lat': 48.85,
        'lon': 2.35,
        'country': 'FR',
      });

      expect(model.displayName, 'Paris, FR');
    });
  });
}
