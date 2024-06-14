import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/app/_app.dart';
import 'package:weather_forecast/services/_services.dart';

/// Stacked services mock
class MockNavigationService extends Mock implements NavigationService {}

class MockSnackbarService extends Mock implements SnackbarService {}

/// Services mock
class MockApiService extends Mock implements IApi {}

class MockConnectivityService extends Mock implements IConnectivityService {}

class MockLocalStorageService extends Mock implements ILocalStorage {}

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}

NavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

SnackbarService getAndRegisterSnackbarService() {
  _removeRegistrationIfExists<SnackbarService>();
  final service = MockSnackbarService();
  locator.registerSingleton<SnackbarService>(service);
  return service;
}

IApi getAndRegisterApiService() {
  _removeRegistrationIfExists<IApi>();
  final service = MockApiService();
  locator.registerSingleton<IApi>(service);
  return service;
}

IConnectivityService getAndRegisterConnectivityService() {
  _removeRegistrationIfExists<IConnectivityService>();
  final service = MockConnectivityService();
  locator.registerSingleton<IConnectivityService>(service);
  return service;
}

ILocalStorage getAndRegisterLocalStorageService() {
  _removeRegistrationIfExists<ILocalStorage>();
  final service = MockLocalStorageService();
  locator.registerSingleton<ILocalStorage>(service);
  return service;
}

void registerServices() {
  getAndRegisterNavigationService();
  getAndRegisterSnackbarService();
  getAndRegisterApiService();
  getAndRegisterConnectivityService();
  getAndRegisterLocalStorageService();
}

void unregisterServices() {
  locator.unregister<DialogService>();
  locator.unregister<BottomSheetService>();
  locator.unregister<NavigationService>();
  locator.unregister<SnackbarService>();
  locator.unregister<IApi>();
  locator.unregister<IConnectivityService>();
  locator.unregister<ILocalStorage>();
}
