import 'package:stacked/stacked.dart';

import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/models/_models.dart';
import '../../data/dtos/city_location_model.dart';
import '../../data/repositories/weather_repo.dart';

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
    searchedCities.clear();
    if (value.isEmpty) {
      notifyListeners();
    } else {
      searchedCities.addAll(
        allCities.where(
          (city) => city.name.toLowerCase().contains(value.toLowerCase()),
        ),
      );
    }
    notifyListeners();
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
        cities.map((city) => _weatherRepo.getCurrentWeather(city)),
      );
      var newCities = <CityLocationModel>[];

      for (var i = 0; i < cities.length; i++) {
        newCities.add(cities[i].copyWith(weather: res[i]));
      }
      allCities = newCities;
    } on IAppException catch (e) {
      _log.e(e);
    } finally {
      setBusy(false);
    }
  }

  void onCardTap(CityLocationModel city) {
    _navigationService.navigateTo(
      Routes.weatherDetailsView,
      arguments: WeatherDetailsViewArguments(city: city),
    );
  }
}
