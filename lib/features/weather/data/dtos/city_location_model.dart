import 'package:equatable/equatable.dart';

import 'weather_model.dart';

class CityLocationModel extends Equatable {
  final String id;
  final String name;
  final double lat;
  final double lon;
  final WeatherModel? weather;

  const CityLocationModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    this.weather,
  });

  /// Persists only the location; the weather is always re-fetched.
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'lat': lat,
        'lon': lon,
      };

  factory CityLocationModel.fromMap(Map<String, dynamic> map) {
    return CityLocationModel(
      id: map['id'] as String,
      name: map['name'] as String,
      lat: (map['lat'] as num).toDouble(),
      lon: (map['lon'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      name,
      lat,
      lon,
      weather,
    ];
  }

  CityLocationModel copyWith({
    String? id,
    String? name,
    double? lat,
    double? lon,
    WeatherModel? weather,
  }) {
    return CityLocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      weather: weather ?? this.weather,
    );
  }
}
