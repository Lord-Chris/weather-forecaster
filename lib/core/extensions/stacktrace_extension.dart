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
    final current =
        toString().split('\n').map(_withoutFrameIndex).take(2).toList();

    final preIsolate = StackTrace.current
        .toString()
        .split('\n')
        .map(_withoutFrameIndex)
        .skip(1)
        .toList();

    final data = [...current, ...preIsolate]..removeWhere(
        (e) => e.contains('asynchronous suspension') || e.trim().isEmpty);
    final res = <String>[];

    for (int i = 0; i < data.length; i++) {
      res.add('#$i\t${data[i]}');
    }
    return StackTrace.fromString(res.join('\n'));
  }
}

/// Removes a leading frame index such as `#12   ` from a stack trace line.
/// Lines without one are returned unchanged.
String _withoutFrameIndex(String line) {
  if (!line.startsWith('#')) return line;

  var i = 1;
  while (i < line.length && _isDigit(line.codeUnitAt(i))) {
    i++;
  }
  if (i == 1) return line;

  final afterDigits = i;
  while (i < line.length && line[i].trim().isEmpty) {
    i++;
  }
  return i == afterDigits ? line : line.substring(i);
}

bool _isDigit(int codeUnit) => codeUnit >= 0x30 && codeUnit <= 0x39;
