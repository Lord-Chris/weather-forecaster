import 'dart:convert';

import 'package:equatable/equatable.dart';

class CityLocationModel extends Equatable {
  final String id;
  final String name;
  final double lat;
  final double lon;

  const CityLocationModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
  });

  @override
  List<Object> get props => [id, name, lat, lon];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lon': lon,
    };
  }

  factory CityLocationModel.fromMap(Map<String, dynamic> map) {
    return CityLocationModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      lat: map['lat']?.toDouble() ?? 0.0,
      lon: map['lon']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory CityLocationModel.fromJson(String source) =>
      CityLocationModel.fromMap(json.decode(source));
}
