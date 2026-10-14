import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/core/extensions/stacktrace_extension.dart';

void main() {
  group('isolateStackTrace', () {
    test('renumbers frames from zero and strips the old frame index', () {
      final trace = StackTrace.fromString(
        '#0      first (package:a/a.dart:1:1)\n'
        '#1      second (package:a/a.dart:2:2)\n'
        '#2      third (package:a/a.dart:3:3)',
      );

      final lines = trace.isolateStackTrace.toString().split('\n');

      expect(lines[0], '#0\tfirst (package:a/a.dart:1:1)');
      expect(lines[1], '#1\tsecond (package:a/a.dart:2:2)');
      expect(lines.every((l) => !l.contains('#0      ')), isTrue);
    });

    test('drops asynchronous suspension and blank lines', () {
      final trace = StackTrace.fromString(
        '#0      first (package:a/a.dart:1:1)\n'
        '<asynchronous suspension>\n'
        '\n'
        '#1      second (package:a/a.dart:2:2)',
      );

      final result = trace.isolateStackTrace.toString();

      expect(result, isNot(contains('asynchronous suspension')));
      expect(result.split('\n').every((l) => l.trim().isNotEmpty), isTrue);
    });
  });
}
