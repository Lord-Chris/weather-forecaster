/// A set of extensions for the [StackTrace] class.
extension StackTraceExtension on StackTrace {
  /// Called when an error occurs within an isolate.
  ///
  /// Returns a new [StackTrace] with the first two lines of the stack trace
  /// within the isolate and the rest of the stack trace outside the isolate.
  ///
  /// The lines containing 'asynchronous suspension' are removed, as they are
  /// not useful for debugging.
  StackTrace get isolateStackTrace {
    final current = toString()
        .split('\n')
        .map((e) => e.split(RegExp(r'^#\d+\s+')).last)
        .take(2)
        .toList();

    final preIsolate = StackTrace.current
        .toString()
        .split(RegExp('\n'))
        .map((e) => e.split(RegExp(r'^#\d+\s+')).last)
        .skip(1)
        .toList();

    final data = [...current, ...preIsolate]..removeWhere(
        (e) => e.contains('asynchronous suspension') || e.trim().isEmpty);
    final res = [];

    for (int i = 0; i < data.length; i++) {
      res.add('#$i\t${data[i]}');
    }
    return StackTrace.fromString(res.join('\n'));
  }
}
