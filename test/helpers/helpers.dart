import 'package:flutter/material.dart';
import 'package:weather_forecast/core/app/_app.dart';

void removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}

Widget buildTestableWidget(Widget child) {
  return MaterialApp(home: child);
}
