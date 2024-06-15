import 'dart:convert';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lon': lon,
      'weather': weather?.toMap(),
    };
  }

  factory CityLocationModel.fromMap(Map<String, dynamic> map) {
    return CityLocationModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      lat: map['lat']?.toDouble() ?? 0.0,
      lon: map['lon']?.toDouble() ?? 0.0,
      weather:
          map['weather'] != null ? WeatherModel.fromMap(map['weather']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CityLocationModel.fromJson(String source) =>
      CityLocationModel.fromMap(json.decode(source));

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
