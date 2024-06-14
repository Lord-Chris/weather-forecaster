import 'package:stacked/stacked.dart';

import '../../../../core/shared/constants/_constants.dart';
import '../../domain/entities/city_location_model.dart';

class HomeViewModel extends BaseViewModel {
  final List<CityLocationModel> _allCities = AppConstants.cities;
  final List<CityLocationModel> _searchedCities = [];
  String searchQuery = '';

  List<CityLocationModel> get cities =>
      searchQuery.isEmpty ? _allCities : _searchedCities;

  void onSearchQueryChanged(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void getCurrentWeather(CityLocationModel city) {}
}
