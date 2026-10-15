import 'package:flutter/material.dart';

import 'core/app/_app.dart';
import 'core/shared/constants/_constants.dart';
import 'core/telemetry/_telemetry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initServices();
  runApp(const WeatherForecastApp());
}

Future<void> _initServices() async {
  await setupLocator();
}

class WeatherForecastApp extends StatelessWidget {
  const WeatherForecastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorObservers: [
        StackedService.routeObserver,
        TelemetryRouteObserver(locator<Telemetry>()),
      ],
    );
  }
}
