import 'package:dio/dio.dart';

abstract class IApi {
  Future<Map<String, dynamic>> get(
    Uri uri, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onReceiveProgress,
  });

  Future<Map<String, dynamic>> post(
    Uri uri, {
    required dynamic body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<Map<String, dynamic>> put(
    Uri uri, {
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<Map<String, dynamic>> delete(
    Uri uri, {
    required Map<String, dynamic> body,
    Map<String, dynamic>? headers,
    Options? options,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  });
}
