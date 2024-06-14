import 'dart:isolate';

import '../extensions/stacktrace_extension.dart';
import '../shared/models/_models.dart';

typedef Transformer<T> = T Function(Map<String, dynamic>);
typedef DataMap = Map<String, dynamic>;

/// This function is a helper function used to transform the API response to a
/// model object in a separate isolate to prevent the main isolate from being
/// blocked by the parsing process.
///
/// The [data] parameter is the JSEND format response data from the API which
/// has a map object as its [data].data value.
///
/// The [transformer] parameter is a function that takes a map object and
/// returns a model object.
///
/// The function returns a Future of the model object.
Future<T> transformApiResponse<T>(
  DataMap data,
  Transformer<T> transformer,
) async {
  try {
    return await Isolate.run(
      () => transformer(data),
    );
  } on TypeError catch (e, s) {
    throw ObjectParserAppException(data: e, stackTrace: s.isolateStackTrace);
  } on Exception catch (e) {
    throw FallbackAppException(data: e);
  }
}

/// This function is a helper function used to transform the API response to a
/// list of model objects in a separate isolate to prevent the main isolate from
/// being blocked by the parsing process.
///
/// The [data] parameter is the JSEND format response data from the API which
/// has a list object as its [data].data value.
///
/// The [transformer] parameter is a function that takes a map object and
/// returns a model object.
///
/// The function returns a Future of the list of model objects.
Future<List<T>> transformListApiResponse<T>(
  DataMap data,
  Transformer<T> transformer,
) async {
  try {
    return await Isolate.run(
      () => (data as List?)?.map((e) => transformer(e)).toList() ?? [],
    );
  } on TypeError catch (e, s) {
    throw ObjectParserAppException(data: e, stackTrace: s.isolateStackTrace);
  } on Exception catch (e) {
    throw FallbackAppException(data: e);
  }
}
