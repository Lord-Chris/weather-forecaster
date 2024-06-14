import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../features/weather/presentation/home_view/home_view.dart';
import '../../features/weather/presentation/weather_details_view/weather_details_view.dart';

/// Run "flutter pub run build_runner build --delete-conflicting-outputs"
/// Run "flutter pub run build_runner watch --delete-conflicting-outputs"

@StackedApp(
  routes: [
    AdaptiveRoute(page: HomeView, initial: true),
    AdaptiveRoute(page: WeatherDetailsView),
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
  ],
  logger: StackedLogger(),
)
class App {}
