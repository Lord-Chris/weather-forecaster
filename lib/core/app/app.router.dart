// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/foundation.dart' as _i6;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i8;
import 'package:weather_forecast/features/weather/data/dtos/city_location_model.dart'
    as _i7;
import 'package:weather_forecast/features/weather/presentation/add_city_view/add_city_view.dart'
    as _i5;
import 'package:weather_forecast/features/weather/presentation/air_quality_view/air_quality_view.dart'
    as _i4;
import 'package:weather_forecast/features/weather/presentation/home_view/home_view.dart'
    as _i2;
import 'package:weather_forecast/features/weather/presentation/weather_details_view/weather_details_view.dart'
    as _i3;

class Routes {
  static const homeView = '/';

  static const weatherDetailsView = '/weather-details-view';

  static const airQualityView = '/air-quality-view';

  static const addCityView = '/add-city-view';

  static const all = <String>{
    homeView,
    weatherDetailsView,
    airQualityView,
    addCityView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.homeView,
      page: _i2.HomeView,
    ),
    _i1.RouteDef(
      Routes.weatherDetailsView,
      page: _i3.WeatherDetailsView,
    ),
    _i1.RouteDef(
      Routes.airQualityView,
      page: _i4.AirQualityView,
    ),
    _i1.RouteDef(
      Routes.addCityView,
      page: _i5.AddCityView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.HomeView: (data) {
      final args = data.getArgs<HomeViewArguments>(
        orElse: () => const HomeViewArguments(),
      );
      return _i1.buildAdaptivePageRoute<dynamic>(
        builder: (context) => _i2.HomeView(key: args.key),
        settings: data,
      );
    },
    _i3.WeatherDetailsView: (data) {
      final args = data.getArgs<WeatherDetailsViewArguments>(nullOk: false);
      return _i1.buildAdaptivePageRoute<dynamic>(
        builder: (context) =>
            _i3.WeatherDetailsView(key: args.key, city: args.city),
        settings: data,
      );
    },
    _i4.AirQualityView: (data) {
      final args = data.getArgs<AirQualityViewArguments>(nullOk: false);
      return _i1.buildAdaptivePageRoute<dynamic>(
        builder: (context) =>
            _i4.AirQualityView(key: args.key, city: args.city),
        settings: data,
      );
    },
    _i5.AddCityView: (data) {
      final args = data.getArgs<AddCityViewArguments>(
        orElse: () => const AddCityViewArguments(),
      );
      return _i1.buildAdaptivePageRoute<dynamic>(
        builder: (context) => _i5.AddCityView(key: args.key),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class HomeViewArguments {
  const HomeViewArguments({this.key});

  final _i6.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant HomeViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class WeatherDetailsViewArguments {
  const WeatherDetailsViewArguments({
    this.key,
    required this.city,
  });

  final _i6.Key? key;

  final _i7.CityLocationModel city;

  @override
  String toString() {
    return '{"key": "$key", "city": "$city"}';
  }

  @override
  bool operator ==(covariant WeatherDetailsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.city == city;
  }

  @override
  int get hashCode {
    return key.hashCode ^ city.hashCode;
  }
}

class AirQualityViewArguments {
  const AirQualityViewArguments({
    this.key,
    required this.city,
  });

  final _i6.Key? key;

  final _i7.CityLocationModel city;

  @override
  String toString() {
    return '{"key": "$key", "city": "$city"}';
  }

  @override
  bool operator ==(covariant AirQualityViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.city == city;
  }

  @override
  int get hashCode {
    return key.hashCode ^ city.hashCode;
  }
}

class AddCityViewArguments {
  const AddCityViewArguments({this.key});

  final _i6.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AddCityViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

extension NavigatorStateExtension on _i8.NavigationService {
  Future<dynamic> navigateToHomeView({
    _i6.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.homeView,
        arguments: HomeViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToWeatherDetailsView({
    _i6.Key? key,
    required _i7.CityLocationModel city,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.weatherDetailsView,
        arguments: WeatherDetailsViewArguments(key: key, city: city),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAirQualityView({
    _i6.Key? key,
    required _i7.CityLocationModel city,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.airQualityView,
        arguments: AirQualityViewArguments(key: key, city: city),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAddCityView({
    _i6.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.addCityView,
        arguments: AddCityViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView({
    _i6.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.homeView,
        arguments: HomeViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithWeatherDetailsView({
    _i6.Key? key,
    required _i7.CityLocationModel city,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.weatherDetailsView,
        arguments: WeatherDetailsViewArguments(key: key, city: city),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAirQualityView({
    _i6.Key? key,
    required _i7.CityLocationModel city,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.airQualityView,
        arguments: AirQualityViewArguments(key: key, city: city),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAddCityView({
    _i6.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.addCityView,
        arguments: AddCityViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
