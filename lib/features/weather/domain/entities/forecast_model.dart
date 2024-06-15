import 'dart:convert';

import 'package:intl/intl.dart';

import 'weather_model.dart';

class ForecastModel {
  final String cod;
  final int message;
  final int cnt;
  final List<ListElement> list;
  final City city;

  ForecastModel({
    required this.cod,
    required this.message,
    required this.cnt,
    required this.list,
    required this.city,
  });

  Map<String, dynamic> toMap() {
    return {
      'cod': cod,
      'message': message,
      'cnt': cnt,
      'list': list.map((x) => x.toMap()).toList(),
      'city': city.toMap(),
    };
  }

  factory ForecastModel.fromMap(Map<String, dynamic> map) {
    return ForecastModel(
      cod: map['cod'] ?? '',
      message: map['message']?.toInt() ?? 0,
      cnt: map['cnt']?.toInt() ?? 0,
      list: List<ListElement>.from(
          map['list']?.map((x) => ListElement.fromMap(x)) ?? const []),
      city: City.fromMap(map['city']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ForecastModel.fromJson(String source) =>
      ForecastModel.fromMap(json.decode(source));
}

class City {
  final int id;
  final String name;
  final Coord coord;
  final String country;
  final int population;
  final int timezone;
  final int sunrise;
  final int sunset;

  City({
    required this.id,
    required this.name,
    required this.coord,
    required this.country,
    required this.population,
    required this.timezone,
    required this.sunrise,
    required this.sunset,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'coord': coord.toMap(),
      'country': country,
      'population': population,
      'timezone': timezone,
      'sunrise': sunrise,
      'sunset': sunset,
    };
  }

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      coord: Coord.fromMap(map['coord']),
      country: map['country'] ?? '',
      population: map['population']?.toInt() ?? 0,
      timezone: map['timezone']?.toInt() ?? 0,
      sunrise: map['sunrise']?.toInt() ?? 0,
      sunset: map['sunset']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory City.fromJson(String source) => City.fromMap(json.decode(source));
}

class ListElement {
  final int dt;
  final Main main;
  final List<Weather> weather;
  final Clouds? clouds;
  final Wind? wind;
  final int visibility;
  final double pop;
  final Rain? rain;
  final Sys? sys;
  final DateTime? dtTxt;

  ListElement({
    required this.dt,
    required this.main,
    required this.weather,
    required this.clouds,
    required this.wind,
    required this.visibility,
    required this.pop,
    required this.rain,
    required this.sys,
    required this.dtTxt,
  });

  Map<String, dynamic> toMap() {
    return {
      'dt': dt,
      'main': main.toMap(),
      'weather': weather.map((x) => x.toMap()).toList(),
      'clouds': clouds?.toMap(),
      'wind': wind?.toMap(),
      'visibility': visibility,
      'pop': pop,
      'rain': rain?.toMap(),
      'sys': sys?.toMap(),
      'dt_txt': dtTxt?.toIso8601String(),
    };
  }

  factory ListElement.fromMap(Map<String, dynamic> map) {
    return ListElement(
      dt: map['dt']?.toInt() ?? 0,
      main: Main.fromMap(map['main']),
      weather: List<Weather>.from(
          map['weather']?.map((x) => Weather.fromMap(x)) ?? const []),
      clouds: map['clouds'] != null ? Clouds.fromMap(map['clouds']) : null,
      wind: map['wind'] != null ? Wind.fromMap(map['wind']) : null,
      visibility: map['visibility']?.toInt() ?? 0,
      pop: map['pop']?.toDouble() ?? 0.0,
      rain: map['rain'] != null ? Rain.fromMap(map['rain']) : null,
      sys: map['sys'] != null ? Sys.fromMap(map['sys']) : null,
      dtTxt: DateTime.tryParse(map['dt_txt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ListElement.fromJson(String source) =>
      ListElement.fromMap(json.decode(source));

  String get parsedDate => DateFormat.yMMMEd()
      .format(DateTime.fromMillisecondsSinceEpoch(dt * 1000));
  String get parsedTime =>
      DateFormat.jms().format(DateTime.fromMillisecondsSinceEpoch(dt * 1000));
}

class Rain {
  final double the3H;

  Rain({
    required this.the3H,
  });

  Map<String, dynamic> toMap() {
    return {
      'the3_h': the3H,
    };
  }

  factory Rain.fromMap(Map<String, dynamic> map) {
    return Rain(
      the3H: map['the3_h']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Rain.fromJson(String source) => Rain.fromMap(json.decode(source));
}

class Sys {
  final String pod;

  Sys({
    required this.pod,
  });

  Map<String, dynamic> toMap() {
    return {
      'pod': pod,
    };
  }

  factory Sys.fromMap(Map<String, dynamic> map) {
    return Sys(
      pod: map['pod'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Sys.fromJson(String source) => Sys.fromMap(json.decode(source));
}
