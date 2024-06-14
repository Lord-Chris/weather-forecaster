// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i4;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i6;
import 'package:weather_forecast/features/weather/domain/entities/city_location_model.dart'
    as _i5;
import 'package:weather_forecast/features/weather/presentation/home_view/home_view.dart'
    as _i2;
import 'package:weather_forecast/features/weather/presentation/weather_details_view/weather_details_view.dart'
    as _i3;

class Routes {
  static const homeView = '/';

  static const weatherDetailsView = '/weather-details-view';

  static const all = <String>{
    homeView,
    weatherDetailsView,
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
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.HomeView: (data) {
      return _i1.buildAdaptivePageRoute<dynamic>(
        builder: (context) => const _i2.HomeView(),
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
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class WeatherDetailsViewArguments {
  const WeatherDetailsViewArguments({
    this.key,
    required this.city,
  });

  final _i4.Key? key;

  final _i5.CityLocationModel city;

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

extension NavigatorStateExtension on _i6.NavigationService {
  Future<dynamic> navigateToHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToWeatherDetailsView({
    _i4.Key? key,
    required _i5.CityLocationModel city,
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

  Future<dynamic> replaceWithHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithWeatherDetailsView({
    _i4.Key? key,
    required _i5.CityLocationModel city,
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
}
