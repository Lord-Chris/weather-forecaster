import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/features/weather/presentation/home_view/home_viewmodel.dart';
import 'package:weather_forecast/features/weather/presentation/weather_details_view/weather_details_viewmodel.dart';

import 'helpers.dart';

class MockHomeViewModel extends Mock implements HomeViewModel {}

class MockWeatherDetialsViewModel extends Mock
    implements WeatherDetailsViewModel {}

HomeViewModel getAndRegisterHomeViewModel() {
  removeRegistrationIfExists<HomeViewModel>();
  final service = MockHomeViewModel();
  locator.registerSingleton<HomeViewModel>(service);
  return service;
}

WeatherDetailsViewModel getAndRegisterWeatherDetailsViewModel() {
  removeRegistrationIfExists<WeatherDetailsViewModel>();
  final service = MockWeatherDetialsViewModel();
  locator.registerSingleton<WeatherDetailsViewModel>(service);
  return service;
}

void registerViewModels() {
  getAndRegisterHomeViewModel();
  getAndRegisterWeatherDetailsViewModel();
}

void unregisterViewModels() {
  locator.unregister<HomeViewModel>();
  locator.unregister<WeatherDetailsViewModel>();
}
