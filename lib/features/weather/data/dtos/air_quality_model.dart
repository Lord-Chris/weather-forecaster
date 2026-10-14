import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Air pollution reading returned by `data/2.5/air_pollution`.
class AirQualityModel extends Equatable {
  /// Air Quality Index, 1 (good) to 5 (very poor).
  final int aqi;
  final int dt;
  final double co;
  final double no;
  final double no2;
  final double o3;
  final double so2;
  final double pm25;
  final double pm10;
  final double nh3;

  const AirQualityModel({
    required this.aqi,
    required this.dt,
    required this.co,
    required this.no,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm25,
    required this.pm10,
    required this.nh3,
  });

  factory AirQualityModel.fromMap(Map<String, dynamic> map) {
    final reading = (map['list'] as List).first as Map<String, dynamic>;
    final components = reading['components'] as Map<String, dynamic>;
    return AirQualityModel(
      aqi: (reading['main'] as Map<String, dynamic>)['aqi'] as int,
      dt: reading['dt'] as int,
      co: (components['co'] as num).toDouble(),
      no: (components['no'] as num).toDouble(),
      no2: (components['no2'] as num).toDouble(),
      o3: (components['o3'] as num).toDouble(),
      so2: (components['so2'] as num).toDouble(),
      pm25: (components['pm2_5'] as num).toDouble(),
      pm10: (components['pm10'] as num).toDouble(),
      nh3: (components['nh3'] as num).toDouble(),
    );
  }

  /// Serialises back into the shape of the API response so the cache can be
  /// read with [AirQualityModel.fromMap].
  Map<String, dynamic> toMap() => {
        'list': [
          {
            'main': {'aqi': aqi},
            'dt': dt,
            'components': {
              'co': co,
              'no': no,
              'no2': no2,
              'o3': o3,
              'so2': so2,
              'pm2_5': pm25,
              'pm10': pm10,
              'nh3': nh3,
            },
          },
        ],
      };

  String toJson() => json.encode(toMap());

  factory AirQualityModel.fromJson(String source) =>
      AirQualityModel.fromMap(json.decode(source));

  String get aqiLabel {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      default:
        return 'Very poor';
    }
  }

  String get aqiAdvice {
    switch (aqi) {
      case 1:
        return 'Air quality is great. Enjoy the outdoors.';
      case 2:
        return 'Acceptable for most people.';
      case 3:
        return 'Sensitive groups should limit long outdoor exertion.';
      case 4:
        return 'Consider reducing time spent outdoors.';
      default:
        return 'Avoid outdoor activity if possible.';
    }
  }

  /// Pollutant name to concentration in μg/m³, in display order.
  Map<String, double> get components => {
        'PM2.5': pm25,
        'PM10': pm10,
        'O₃': o3,
        'NO₂': no2,
        'SO₂': so2,
        'CO': co,
        'NO': no,
        'NH₃': nh3,
      };

  @override
  List<Object?> get props => [aqi, dt, co, no, no2, o3, so2, pm25, pm10, nh3];
}
