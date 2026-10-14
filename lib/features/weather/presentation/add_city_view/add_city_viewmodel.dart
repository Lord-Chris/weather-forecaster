import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import '../../../../core/app/_app.dart';
import '../../../../core/shared/models/_models.dart';
import '../../data/dtos/geo_location_model.dart';
import '../../data/repositories/weather_repo.dart';

class AddCityViewModel extends BaseViewModel {
  final _log = getLogger('AddCityViewModel');
  final _weatherRepo = locator<WeatherRepo>();
  final _navigationService = locator<NavigationService>();

  static const debounceDuration = Duration(milliseconds: 400);

  Timer? _debounce;
  String query = '';
  String? errorMessage;
  List<GeoLocationModel> results = [];

  /// Whether a search was run and returned nothing.
  bool get hasNoResults =>
      query.trim().length >= 2 &&
      !isBusy &&
      errorMessage == null &&
      results.isEmpty;

  /// Debounces typing, then searches for [value].
  void onQueryChanged(String value) {
    query = value;
    debugPrint('add city query changed length=${value.trim().length}');
    _debounce?.cancel();
    if (value.trim().length < 2) {
      results = [];
      errorMessage = null;
      notifyListeners();
      return;
    }
    _debounce = Timer(debounceDuration, search);
  }

  /// Searches for places matching [query].
  Future<void> search() async {
    // TODO(lab-1.9) Wide event: city search. One `city.search` event per search,
    // logged once in a `finally`: query_length, result_count, stale_discarded,
    // success, error.type, duration_ms. It replaces the separate start, result
    // and stale-response logs you would otherwise write for this method.
    final searched = query.trim();
    try {
      setBusy(true);
      errorMessage = null;
      final found = await _weatherRepo.searchCities(searched);
      // Ignore a stale response when the user kept typing.
      if (searched != query.trim()) return;
      results = found;
    } on IAppException catch (e) {
      _log.e(e);
      results = [];
      errorMessage = e.message;
    } finally {
      setBusy(false);
    }
  }

  /// Saves [location] to the home list and returns to the previous screen.
  Future<void> onResultTap(GeoLocationModel location) async {
    debugPrint(
        'add city result tapped city_id=${location.toCityLocationModel().id}');
    try {
      await _weatherRepo.saveCity(location.toCityLocationModel());
      _navigationService.back(result: true);
    } catch (e) {
      _log.e(e);
      errorMessage = 'Could not save this city. Try again.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
