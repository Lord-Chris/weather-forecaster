import 'dart:async';

import 'package:stacked/stacked.dart';

import '../../../../core/app/_app.dart';
import '../../../../core/shared/models/_models.dart';
import '../../../../core/telemetry/_telemetry.dart';
import '../../data/dtos/geo_location_model.dart';
import '../../data/repositories/weather_repo.dart';

class AddCityViewModel extends BaseViewModel {
  final _log = getLogger('AddCityViewModel');
  final _weatherRepo = locator<WeatherRepo>();
  final _navigationService = locator<NavigationService>();
  final _telemetry = locator<Telemetry>();

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
    _telemetry.log.d('add city query changed', {
      'query_length': value.trim().length,
    });
    _debounce?.cancel();
    if (value.trim().length < 2) {
      _telemetry.log.d('search skipped', {
        'reason': 'query_too_short',
        'query_length': value.trim().length,
      });
      results = [];
      errorMessage = null;
      notifyListeners();
      return;
    }
    _debounce = Timer(debounceDuration, search);
  }

  /// Searches for places matching [query].
  Future<void> search() async {
    // TODO(lab-2.5) Search metrics: counter `city.search.stale_discarded` for
    // TODO(lab-1.9) Wide event: city search. One `city.search` event per search,
    final searched = query.trim();
    final stopwatch = Stopwatch()..start();
    final event = <String, Object?>{
      'operation': 'city.search',
      'query_length': searched.length,
      'stale_discarded': false,
      'success': true,
    };
    errorMessage = null;
    try {
      setBusy(true);
      final found = await _weatherRepo.searchCities(searched);
      event['result_count'] = found.length;
      // Ignore a stale response when the user kept typing.
      if (searched != query.trim()) {
        event['stale_discarded'] = true;
        _telemetry.counter('city.search.stale_discarded');
        _telemetry.log.i('search response discarded', {
          'reason': 'stale',
          'query_length': searched.length,
        });
        return;
      }
      results = found;
    } on IAppException catch (e, s) {
      _log.e(e);
      event['success'] = false;
      event['error.type'] = e.runtimeType.toString();
      _telemetry.logError('city search failed', e,
          fields: {
            'viewmodel': 'AddCityViewModel',
            'operation': 'search',
          },
          stackTrace: s);
      results = [];
      errorMessage = e.message;
    } finally {
      setBusy(false);
      stopwatch.stop();
      event['duration_ms'] = stopwatch.elapsedMilliseconds;
      if (event['success'] == true) {
        _telemetry.log.i('city.search', event);
      } else {
        _telemetry.log.e('city.search', event);
      }
    }
  }

  /// Saves [location] to the home list and returns to the previous screen.
  Future<void> onResultTap(GeoLocationModel location) async {
    final city = location.toCityLocationModel();
    _telemetry.log.d('add city result tapped', {
      'city_id': city.id,
    });
    try {
      await _weatherRepo.saveCity(city);
      _navigationService.back(result: true);
    } catch (e, s) {
      _log.e(e);
      _telemetry.logError('city save failed', e,
          fields: {
            'viewmodel': 'AddCityViewModel',
            'operation': 'onResultTap',
          },
          stackTrace: s);
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
