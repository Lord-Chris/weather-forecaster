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

  List<CityLocationModel> get cities =>
      searchQuery.isEmpty ? allCities : searchedCities;

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
