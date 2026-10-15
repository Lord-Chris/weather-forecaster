import 'package:flutter/widgets.dart';

import 'i_telemetry.dart';
import 'span.dart';

/// One span per screen: starts on push, ends on pop.
class TelemetryRouteObserver extends NavigatorObserver {
  final Telemetry _telemetry;
  final _spans = <Route<dynamic>, Span>{};

  TelemetryRouteObserver(this._telemetry);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _start(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _spans.remove(route)?.end();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _spans.remove(route)?.end();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) _spans.remove(oldRoute)?.end();
    if (newRoute != null) _start(newRoute);
  }

  void _start(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null) return;
    _spans[route] = _telemetry.startSpan(
      'screen $name',
      attributes: {'screen': name},
    );
  }
}
