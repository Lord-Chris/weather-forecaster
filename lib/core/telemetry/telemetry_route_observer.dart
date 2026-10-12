import 'package:flutter/widgets.dart';

import 'i_telemetry.dart';
import 'span.dart';
import 'telemetry.dart';

/// One span per screen: starts on push, ends on pop.
class TelemetryRouteObserver extends NavigatorObserver {
  final ITelemetry _telemetry;
  final _spans = <Route<dynamic>, Span>{};

  TelemetryRouteObserver([ITelemetry? telemetry])
      : _telemetry = telemetry ?? Telemetry.instance;

  /// The span of the screen currently on top, if any. Set by the most recent
  /// observer instance; view models use it as the parent of their spans.
  static Span? activeScreen;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name == null) return;
    _spans[route] =
        _telemetry.startSpan('screen $name', attributes: {'screen': name});
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _spans.remove(route)?.end();
    activeScreen = _spans.isEmpty ? null : _spans.values.last;
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _spans.remove(route)?.end();
    activeScreen = _spans.isEmpty ? null : _spans.values.last;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) _spans.remove(oldRoute)?.end();
    final name = newRoute?.settings.name;
    if (newRoute != null && name != null) {
      activeScreen = _spans[newRoute] =
          _telemetry.startSpan('screen $name', attributes: {'screen': name});
    }
  }
}
