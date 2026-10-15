import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/models/_models.dart';
import '../../../../core/telemetry/_telemetry.dart';
import '../../data/dtos/city_location_model.dart';
import '../../data/repositories/weather_repo.dart';

// TODO(lab-3.2) Home load waterfall: extend ObservedViewModel instead of
class HomeViewModel extends ObservedViewModel {
  final _log = getLogger('HomeViewModel');
  final _weatherRepo = locator<WeatherRepo>();
  final _navigationService = locator<NavigationService>();
  final _telemetry = locator<ITelemetry>();

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
    _telemetry.log.d('search changed', {
      'query_length': value.length,
    });
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
    // TODO(lab-1.10) Wide event: home load. One `home.load` event for the whole
    final stopwatch = Stopwatch()..start();
    var savedCount = 0;
    try {
      try {
        final saved = await _weatherRepo.getSavedCities();
        savedCount = saved.length;
        allCities = [...AppConstants.cities, ...saved];
        // TODO(lab-2.7) Gauges, current level: `cities.saved` (saved cities loaded)
        _telemetry.metric('cities.saved', savedCount);
      } catch (e, s) {
        _log.e(e);
        _telemetry.logError('saved cities load failed', e,
            fields: {
              'viewmodel': 'HomeViewModel',
              'operation': 'init',
            },
            stackTrace: s);
      }
      await getCurrentWeather();
      _telemetry.metric('cities.displayed', cities.length);
    } finally {
      stopwatch.stop();
      final loaded = allCities.where((city) => city.weather != null).length;
      _telemetry.log.i('home.load', {
        'default_cities': AppConstants.cities.length,
        'saved_cities': savedCount,
        'cities_loaded': loaded,
        'cities_failed': allCities.length - loaded,
        'duration_ms': stopwatch.elapsedMilliseconds,
      });
      _telemetry.timing(
        'screen.load.duration',
        stopwatch.elapsed,
        {'screen': 'home'},
      );
    }
  }

  /// Opens the search screen and reloads the list if a city was added.
  Future<void> onAddCityTap() async {
    _telemetry.counter('ui.action', {'action': 'add_city'});
    _telemetry.log.d('add city tapped');
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
      // The try/catch stays outside observe() so a failure reaches the span.
      await observe(() async {
        final res = await Future.wait(
          allCities.map((city) => _weatherRepo.getCurrentWeather(city)),
        );
        var newCities = <CityLocationModel>[];

        for (var i = 0; i < allCities.length; i++) {
          newCities.add(allCities[i].copyWith(weather: res[i]));
        }
        allCities = newCities;
        // TODO(lab-3.6) Span attributes: inside observe(), add attributes to the
        _telemetry.current?.setAttribute('cities', allCities.length);
      });
    } on IAppException catch (e, s) {
      _log.e(e);
      // TODO(lab-1.1) Errors in view models, touch these first (rare, most
      _telemetry.logError('weather load failed', e,
          fields: {
            'viewmodel': 'HomeViewModel',
            'operation': 'getCurrentWeather',
          },
          stackTrace: s);
    }
  }

  void onCardTap(CityLocationModel city) {
    // TODO(lab-2.6) Counter, user actions: `ui.action` tagged action=card_tap
    _telemetry.counter('ui.action', {'action': 'card_tap'});
    // TODO(lab-1.7) Lifecycle: navigation. Replace the print here and in
    _telemetry.log.d('card tapped', {'city_id': city.id});
    _navigationService.navigateTo(
      Routes.weatherDetailsView,
      arguments: WeatherDetailsViewArguments(city: city),
    );
  }
}
