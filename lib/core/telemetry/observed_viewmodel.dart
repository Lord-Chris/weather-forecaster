import 'package:stacked/stacked.dart';

import '../app/_app.dart';
import 'i_telemetry.dart';
import 'traced.dart';

/// Base view model with one extra method, [observe]. Stacked has no global
/// observer, so view models opt in by extending this instead of [BaseViewModel].
abstract class ObservedViewModel extends BaseViewModel {
  final ITelemetry _telemetry;

  ObservedViewModel([ITelemetry? telemetry])
      : _telemetry = telemetry ?? locator<ITelemetry>();

  /// Runs [work] as this view model's busy period: busy turns on, [work] runs
  /// inside a span (so HTTP spans become its children), and busy turns off.
  Future<T> observe<T>(Future<T> Function() work, {Object? key}) async {
    final busyKey = key ?? this;
    setBusyForObject(busyKey, true);
    try {
      return await traced(
        '$runtimeType',
        work,
        telemetry: _telemetry,
        attributes: {'viewmodel': runtimeType.toString()},
      );
    } finally {
      setBusyForObject(busyKey, false);
    }
  }
}
