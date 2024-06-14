import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
  List _allCities = [];
  List _searchedCities = [];
  String searchQuery = '';

  List get cities => searchQuery.isEmpty ? _allCities : _searchedCities;

  void onSearchQueryChanged(String value) {
    searchQuery = value;
    notifyListeners();
  }
}
