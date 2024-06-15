import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../features/weather/data/datasources/weather_local_source.dart';
import '../../features/weather/data/datasources/weather_remote_source.dart';
import '../../features/weather/data/repositories/weather_repo.dart';
import '../../features/weather/presentation/home_view/home_view.dart';
import '../../features/weather/presentation/home_view/home_viewmodel.dart';
import '../../features/weather/presentation/weather_details_view/weather_details_view.dart';
import '../../features/weather/presentation/weather_details_view/weather_details_viewmodel.dart';
import '../../services/_services.dart';

/// Run "flutter pub run build_runner build --delete-conflicting-outputs"
/// Run "flutter pub run build_runner watch --delete-conflicting-outputs"

@StackedApp(
  routes: [
    AdaptiveRoute(page: HomeView, initial: true),
    AdaptiveRoute(page: WeatherDetailsView),
  ],
  dependencies: [
    /// Services
    LazySingleton(classType: NavigationService),
    InitializableSingleton(
      classType: LocalStorageService,
      asType: ILocalStorage,
    ),
    Singleton(classType: ApiService, asType: IApi),
    Singleton(classType: ConnectivityService, asType: IConnectivityService),

    /// Repositories
    LazySingleton(classType: WeatherRepo),

    /// Data sources
    Factory(classType: WeatherRemoteSource),
    Factory(classType: WeatherLocalSource),

    /// View models
    Factory(classType: HomeViewModel),
    Factory(classType: WeatherDetailsViewModel),
  ],
  logger: StackedLogger(),
)
class App {}
