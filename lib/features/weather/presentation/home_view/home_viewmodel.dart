import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/models/_models.dart';
import '../../data/dtos/city_location_model.dart';
import '../../data/repositories/weather_repo.dart';

// TODO(lab-3.2) Home load waterfall: extend ObservedViewModel instead of
// BaseViewModel and wrap the work in getCurrentWeather() with
// `observe(() async { ... })`. You should see one view model span with one
// request span per city as its parallel children.
class HomeViewModel extends BaseViewModel {
  final _log = getLogger('HomeViewModel');
  final _weatherRepo = locator<WeatherRepo>();
  final _navigationService = locator<NavigationService>();

  List<CityLocationModel> allCities = AppConstants.cities;
  final searchedCities = <CityLocationModel>[];
  String searchQuery = '';

  /// Returns a list of [CityLocationModel] objects representing the cities to be displayed.
  /// If [searchQuery] is empty, it returns all cities. Otherwise, it returns the cities
  /// that match the search query.
  List<CityLocationModel> get cities =>
      searchQuery.isEmpty ? allCities : searchedCities;

  /// Callback function that is called when the search query is changed.
  ///
  /// Updates the [searchQuery] with the new value, clears the [searchedCities] list,
  /// and filters the [allCities] list based on the new search query.
  /// If the search query is empty, it notifies the listeners.
  /// Finally, it notifies the listeners again after updating the [searchedCities] list.
  void onSearchQueryChanged(String value) {
    searchQuery = value;
    // TODO(lab-1.6) Lifecycle: user input. Replace the print here, in
    // AddCityViewModel.onQueryChanged and onResultTap with a structured log and
    // named fields (query_length, city_id). Noisy, so touch these late.
    debugPrint('search changed length=${value.length}');
    searchedCities.clear();
    if (value.isNotEmpty) {
      searchedCities.addAll(
        allCities.where(
          (city) => city.name.toLowerCase().contains(value.toLowerCase()),
        ),
      );
    }
    notifyListeners();
  }

  /// Loads the cities the user added, then fetches the weather for all cities.
  Future<void> init() async {
    // TODO(lab-2.7) Gauges, current level: `cities.saved` (saved cities loaded)
    // and `cities.displayed` after the list is built; in the repo, a
    // `weather.fetch.in_flight` gauge that goes up when a fetch starts and down
    // when it ends. Gauges can go down, counters cannot.
    // TODO(lab-1.10) Wide event: home load. One `home.load` event for the whole
    // flow, logged once in a `finally`: default_cities, saved_cities,
    // cities_loaded, cities_failed, duration_ms. getCurrentWeather() runs one
    // fetch per city, so this event summarises many of the step 1.8 events.
    try {
      final saved = await _weatherRepo.getSavedCities();
      allCities = [...AppConstants.cities, ...saved];
    } catch (e) {
      _log.e(e);
    }
    await getCurrentWeather();
  }

  /// Opens the search screen and reloads the list if a city was added.
  Future<void> onAddCityTap() async {
    debugPrint('add city tapped');
    final added = await _navigationService.navigateTo(Routes.addCityView);
    if (added == true) await init();
  }

  /// Retrieves the current weather for multiple cities.
  ///
  /// This method sets the [busy] state to true, indicating that the operation is in progress.
  /// It then uses the [_weatherRepo] to fetch the current weather for each city in the [cities] list.
  /// The results are stored in a new list of [CityLocationModel] objects, with the weather data updated.
  /// Finally, the [allCities] property is updated with the new list of cities.
  ///
  /// If an [IAppException] is thrown during the process, it is logged using [_log].
  /// Regardless of whether an exception is thrown or not, the [busy] state is set to false.
  Future<void> getCurrentWeather() async {
    try {
      setBusy(true);
      final res = await Future.wait(
        allCities.map((city) => _weatherRepo.getCurrentWeather(city)),
      );
      var newCities = <CityLocationModel>[];

      for (var i = 0; i < allCities.length; i++) {
        newCities.add(allCities[i].copyWith(weather: res[i]));
      }
      allCities = newCities;
      // TODO(lab-3.6) Span attributes: inside observe(), add attributes to the
      // current span (`locator<ITelemetry>().current?.setAttribute('cities',
      // allCities.length)`). Counts and flags only: names, tokens and keys are
      // dropped by the privacy rules.
    } on IAppException catch (e) {
      _log.e(e);
      // TODO(lab-1.1) Errors in view models, touch these first (rare, most
      // valuable): add telemetry.log(...) (locator<ITelemetry>()) next to the
      // line above, and at the same kind of catch in HomeViewModel.init,
      // AddCityViewModel.search and onResultTap, AirQualityViewModel and
      // WeatherDetailsViewModel.fetchForecast. Fields: viewmodel, operation,
      // error.type. Never the message.
    } finally {
      setBusy(false);
    }
  }

  void onCardTap(CityLocationModel city) {
    // TODO(lab-2.6) Counter, user actions: `ui.action` tagged action=card_tap
    // here, add_city in onAddCityTap, air_quality in
    // WeatherDetailsViewModel.onAirQualityTap. A fixed set of values, never ids.
    // TODO(lab-1.7) Lifecycle: navigation. Replace the print here and in
    // onAddCityTap, WeatherDetailsViewModel.init and onAirQualityTap, and
    // AirQualityViewModel.init, with a structured log (screen, city_id).
    debugPrint('card tapped city_id=${city.id}');
    _navigationService.navigateTo(
      Routes.weatherDetailsView,
      arguments: WeatherDetailsViewArguments(city: city),
    );
  }
}
