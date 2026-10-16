import 'package:flutter/widgets.dart';

import 'i_telemetry.dart';
import 'span.dart';

/// One span per screen: starts on push, ends on pop. Also tells [Telemetry]
/// which screen is visible so every span, log and metric carries it.
class TelemetryRouteObserver extends NavigatorObserver {
  final Telemetry _telemetry;
  final _spans = <Route<dynamic>, Span>{};

  TelemetryRouteObserver(this._telemetry);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _start(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _end(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _end(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) _end(oldRoute);
    if (newRoute != null) _start(newRoute);
  }

  void _start(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null) return;
    _telemetry.enterScreen(name);
    _spans[route] = _telemetry.startSpan(
      'screen $name',
      attributes: {'screen': name},
    );
  }

  void _end(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null) _telemetry.leaveScreen(name);
    _spans.remove(route)?.end();
  }
}
