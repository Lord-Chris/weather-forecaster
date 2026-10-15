import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/core/telemetry/_telemetry.dart';
import 'package:weather_forecast/services/_services.dart';

import 'helpers.dart';

/// Stacked services mock
class MockNavigationService extends Mock implements NavigationService {}

class MockSnackbarService extends Mock implements SnackbarService {}

/// Services mock
class MockApiService extends Mock implements IApi {}

class MockConnectivityService extends Mock implements IConnectivityService {}

class MockLocalStorageService extends Mock implements ILocalStorage {}

NavigationService getAndRegisterNavigationService() {
  removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

SnackbarService getAndRegisterSnackbarService() {
  removeRegistrationIfExists<SnackbarService>();
  final service = MockSnackbarService();
  locator.registerSingleton<SnackbarService>(service);
  return service;
}

IApi getAndRegisterApiService() {
  removeRegistrationIfExists<IApi>();
  final service = MockApiService();
  locator.registerSingleton<IApi>(service);
  return service;
}

IConnectivityService getAndRegisterConnectivityService() {
  removeRegistrationIfExists<IConnectivityService>();
  final service = MockConnectivityService();
  locator.registerSingleton<IConnectivityService>(service);
  return service;
}

ILocalStorage getAndRegisterLocalStorageService() {
  removeRegistrationIfExists<ILocalStorage>();
  final service = MockLocalStorageService();
  locator.registerSingleton<ILocalStorage>(service);
  return service;
}

/// Registers a real [TelemetryImpl] backed by an [InMemoryExporter] and returns
/// the exporter so tests can assert on what was recorded.
/// The exporter behind the telemetry most recently registered by
/// [getAndRegisterTelemetry]; read it in tests after [registerServices].
InMemoryExporter telemetryExporter = InMemoryExporter();

InMemoryExporter getAndRegisterTelemetry() {
  removeRegistrationIfExists<Telemetry>();
  final exporter = telemetryExporter = InMemoryExporter();
  locator.registerSingleton<Telemetry>(
    TelemetryImpl(exporter: exporter, attendee: 'tester'),
  );
  return exporter;
}

void registerServices() {
  getAndRegisterTelemetry();
  getAndRegisterNavigationService();
  getAndRegisterSnackbarService();
  getAndRegisterApiService();
  getAndRegisterConnectivityService();
  getAndRegisterLocalStorageService();
}

void unregisterServices() {
  locator.unregister<NavigationService>();
  locator.unregister<SnackbarService>();
  locator.unregister<IApi>();
  locator.unregister<IConnectivityService>();
  locator.unregister<ILocalStorage>();
  removeRegistrationIfExists<Telemetry>();
}
