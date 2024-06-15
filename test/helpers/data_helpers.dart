import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/features/weather/data/datasources/weather_local_source.dart';
import 'package:weather_forecast/features/weather/data/datasources/weather_remote_source.dart';
import 'package:weather_forecast/features/weather/data/repositories/weather_repo.dart';

import 'helpers.dart';

class MockWeatherLocalSource extends Mock implements WeatherLocalSource {}

class MockRemoteDataSource extends Mock implements WeatherRemoteSource {}

class MockWeatherRepo extends Mock implements WeatherRepo {}

WeatherLocalSource getAndRegisterWeatherLocalSource() {
  removeRegistrationIfExists<WeatherLocalSource>();
  final service = MockWeatherLocalSource();
  locator.registerSingleton<WeatherLocalSource>(service);
  return service;
}

WeatherRemoteSource getAndRegisterWeatherRemoteSource() {
  removeRegistrationIfExists<WeatherRemoteSource>();
  final service = MockRemoteDataSource();
  locator.registerSingleton<WeatherRemoteSource>(service);
  return service;
}

WeatherRepo getAndRegisterWeatherRepo() {
  removeRegistrationIfExists<WeatherRepo>();
  final service = MockWeatherRepo();
  locator.registerSingleton<WeatherRepo>(service);
  return service;
}

void registerDataLayers() {
  getAndRegisterWeatherLocalSource();
  getAndRegisterWeatherRemoteSource();
  getAndRegisterWeatherRepo();
}

void unregisterDataLayers() {
  locator.unregister<WeatherLocalSource>();
  locator.unregister<WeatherRemoteSource>();
  locator.unregister<WeatherRepo>();
}
