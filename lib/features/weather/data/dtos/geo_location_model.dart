import 'package:equatable/equatable.dart';

import 'city_location_model.dart';

/// A place returned by the OpenWeatherMap geocoding endpoint.
class GeoLocationModel extends Equatable {
  final String name;
  final String country;
  final String? state;
  final double lat;
  final double lon;

  const GeoLocationModel({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
    this.state,
  });

  factory GeoLocationModel.fromMap(Map<String, dynamic> map) {
    return GeoLocationModel(
      name: map['name'] as String,
      country: map['country'] as String? ?? '',
      state: map['state'] as String?,
      lat: (map['lat'] as num).toDouble(),
      lon: (map['lon'] as num).toDouble(),
    );
  }

  /// e.g. "Lagos, Lagos, NG"
  String get displayName => [
        name,
        if (state != null && state!.isNotEmpty) state,
        if (country.isNotEmpty) country,
      ].join(', ');

  CityLocationModel toCityLocationModel() => CityLocationModel(
        id: '${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}',
        name: displayName,
        lat: lat,
        lon: lon,
      );

  @override
  List<Object?> get props => [name, country, state, lat, lon];
}
