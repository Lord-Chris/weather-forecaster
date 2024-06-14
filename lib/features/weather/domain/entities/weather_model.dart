import 'dart:convert';

class WeatherModel {
  final Coord coord;
  final List<Weather> weather;
  final String base;
  final Main main;
  final int visibility;
  final Wind wind;
  final Rain? rain;
  final Clouds clouds;
  final int dt;
  final Sys sys;
  final int timezone;
  final int id;
  final String name;
  final int cod;

  WeatherModel({
    required this.coord,
    required this.weather,
    required this.base,
    required this.main,
    required this.visibility,
    required this.wind,
    required this.rain,
    required this.clouds,
    required this.dt,
    required this.sys,
    required this.timezone,
    required this.id,
    required this.name,
    required this.cod,
  });

  Map<String, dynamic> toMap() {
    return {
      'coord': coord.toMap(),
      'weather': weather.map((x) => x.toMap()).toList(),
      'base': base,
      'main': main.toMap(),
      'visibility': visibility,
      'wind': wind.toMap(),
      'rain': rain?.toMap(),
      'clouds': clouds.toMap(),
      'dt': dt,
      'sys': sys.toMap(),
      'timezone': timezone,
      'id': id,
      'name': name,
      'cod': cod,
    };
  }

  factory WeatherModel.fromMap(Map<String, dynamic> map) {
    return WeatherModel(
      coord: Coord.fromMap(map['coord']),
      weather: List<Weather>.from(map['weather']?.map((x) => Weather.fromMap(x)) ?? const []),
      base: map['base'] ?? '',
      main: Main.fromMap(map['main']),
      visibility: map['visibility']?.toInt() ?? 0,
      wind: Wind.fromMap(map['wind']),
      rain: map['rain'] != null ? Rain.fromMap(map['rain']) : null,
      clouds: Clouds.fromMap(map['clouds']),
      dt: map['dt']?.toInt() ?? 0,
      sys: Sys.fromMap(map['sys']),
      timezone: map['timezone']?.toInt() ?? 0,
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      cod: map['cod']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory WeatherModel.fromJson(String source) =>
      WeatherModel.fromMap(json.decode(source));
}

class Clouds {
  final int all;
  Clouds({
    required this.all,
  });

  Map<String, dynamic> toMap() {
    return {
      'all': all,
    };
  }

  factory Clouds.fromMap(Map<String, dynamic> map) {
    return Clouds(
      all: map['all']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Clouds.fromJson(String source) => Clouds.fromMap(json.decode(source));
}

class Coord {
  final double lon;
  final double lat;

  Coord({
    required this.lon,
    required this.lat,
  });

  Map<String, dynamic> toMap() {
    return {
      'lon': lon,
      'lat': lat,
    };
  }

  factory Coord.fromMap(Map<String, dynamic> map) {
    return Coord(
      lon: map['lon']?.toDouble() ?? 0.0,
      lat: map['lat']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Coord.fromJson(String source) => Coord.fromMap(json.decode(source));
}

class Main {
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;
  final int seaLevel;
  final int grndLevel;

  Main({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.seaLevel,
    required this.grndLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'temp': temp,
      'feels_like': feelsLike,
      'temp_min': tempMin,
      'temp_max': tempMax,
      'pressure': pressure,
      'humidity': humidity,
      'sea_level': seaLevel,
      'grnd_level': grndLevel,
    };
  }

  factory Main.fromMap(Map<String, dynamic> map) {
    return Main(
      temp: map['temp']?.toDouble() ?? 0.0,
      feelsLike: map['feels_like']?.toDouble() ?? 0.0,
      tempMin: map['temp_min']?.toDouble() ?? 0.0,
      tempMax: map['temp_max']?.toDouble() ?? 0.0,
      pressure: map['pressure']?.toInt() ?? 0,
      humidity: map['humidity']?.toInt() ?? 0,
      seaLevel: map['sea_level']?.toInt() ?? 0,
      grndLevel: map['grnd_level']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Main.fromJson(String source) => Main.fromMap(json.decode(source));
}

class Rain {
  final double the1H;

  Rain({
    required this.the1H,
  });

  Map<String, dynamic> toMap() {
    return {
      'the1_h': the1H,
    };
  }

  factory Rain.fromMap(Map<String, dynamic> map) {
    return Rain(
      the1H: map['the1_h']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Rain.fromJson(String source) => Rain.fromMap(json.decode(source));
}

class Sys {
  final int type;
  final int id;
  final String country;
  final int sunrise;
  final int sunset;

  Sys({
    required this.type,
    required this.id,
    required this.country,
    required this.sunrise,
    required this.sunset,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'id': id,
      'country': country,
      'sunrise': sunrise,
      'sunset': sunset,
    };
  }

  factory Sys.fromMap(Map<String, dynamic> map) {
    return Sys(
      type: map['type']?.toInt() ?? 0,
      id: map['id']?.toInt() ?? 0,
      country: map['country'] ?? '',
      sunrise: map['sunrise']?.toInt() ?? 0,
      sunset: map['sunset']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Sys.fromJson(String source) => Sys.fromMap(json.decode(source));
}

class Weather {
  final int id;
  final String main;
  final String description;
  final String icon;

  Weather({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'main': main,
      'description': description,
      'icon': icon,
    };
  }

  factory Weather.fromMap(Map<String, dynamic> map) {
    return Weather(
      id: map['id']?.toInt() ?? 0,
      main: map['main'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Weather.fromJson(String source) =>
      Weather.fromMap(json.decode(source));
}

class Wind {
  final double speed;
  final int deg;
  final double gust;

  Wind({
    required this.speed,
    required this.deg,
    required this.gust,
  });

  Map<String, dynamic> toMap() {
    return {
      'speed': speed,
      'deg': deg,
      'gust': gust,
    };
  }

  factory Wind.fromMap(Map<String, dynamic> map) {
    return Wind(
      speed: map['speed']?.toDouble() ?? 0.0,
      deg: map['deg']?.toInt() ?? 0,
      gust: map['gust']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Wind.fromJson(String source) => Wind.fromMap(json.decode(source));
}
