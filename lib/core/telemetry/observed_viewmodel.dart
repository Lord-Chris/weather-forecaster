import 'package:stacked/stacked.dart';

import 'i_telemetry.dart';
import 'span.dart';
import 'telemetry.dart';
import 'telemetry_record.dart';
import 'telemetry_route_observer.dart';

/// Base view model that reports its work to telemetry. Stacked has no global
/// observer, so view models opt in by extending this instead of [BaseViewModel].
///
/// A span opens when a busy flag turns on and closes when it turns off. Errors
/// are logged by type only.
abstract class ObservedViewModel extends BaseViewModel {
  final ITelemetry _telemetry;
  final _spans = <Object?, Span>{};

  ObservedViewModel([ITelemetry? telemetry])
      : _telemetry = telemetry ?? Telemetry.instance;

  @override
  void setBusyForObject(Object? object, bool value) {
    if (value) {
      _spans.putIfAbsent(
        object,
        () => _telemetry.startSpan(
          '$runtimeType busy',
          parent: _telemetry.current ?? TelemetryRouteObserver.activeScreen,
          attributes: {'viewmodel': runtimeType.toString()},
        ),
      );
    } else {
      _spans.remove(object)?.end();
    }
    super.setBusyForObject(object, value);
  }

  /// Runs [work] as this view model's busy period: busy turns on, the span is
  /// [ITelemetry.current] for everything [work] calls (so HTTP spans become its
  /// children), and busy turns off afterwards.
  Future<T> observe<T>(Future<T> Function() work, {Object? key}) async {
    setBusyForObject(key, true);
    final span = _spans[key];
    try {
      return await (span == null ? work() : _telemetry.runWith(span, work));
    } finally {
      setBusyForObject(key, false);
    }
  }

  @override
  void setErrorForObject(Object object, dynamic value) {
    _reportError(object, value);
    super.setErrorForObject(object, value);
  }

  @override
  void onFutureError(dynamic error, Object? key) {
    _reportError(key, error);
    super.onFutureError(error, key);
  }

  void _reportError(Object? key, Object? error) {
    final type = error.runtimeType.toString();
    _spans[key]?.setError(error ?? 'unknown');
    _telemetry.log(TelemetryLevel.error, 'viewmodel error', {
      'viewmodel': runtimeType.toString(),
      'error.type': type,
    });
  }

  @override
  void dispose() {
    for (final span in _spans.values) {
      span.end();
    }
    _spans.clear();
    super.dispose();
  }
}
