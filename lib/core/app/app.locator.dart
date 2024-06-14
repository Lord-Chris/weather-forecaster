// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../../services/api/api_service.dart';
import '../../services/api/i_api.dart';
import '../../services/local_storage/i_local_storage.dart';
import '../../services/local_storage/local_storage_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => NavigationService());
  final localStorageService = LocalStorageService();
  await localStorageService.init();
  locator.registerSingleton<ILocalStorage>(localStorageService);

  locator.registerSingleton<IApi>(ApiService());
}
