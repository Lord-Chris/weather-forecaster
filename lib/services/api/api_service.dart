import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/interceptors/logger_interceptor.dart';
import '../../core/app/_app.dart';
import '../../core/shared/models/app_exception.dart';
import 'i_api.dart';

class ApiService extends IApi {
  final _log = getLogger('ApiService');
  final Dio _dio;

  ApiService([Dio? dio]) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    return Dio()
      ..options.responseType = ResponseType.json
      ..httpClientAdapter
      ..options.headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Connection': 'keep-alive',
      }
      ..interceptors.addAll([ApiLoggerInterceptor()]);
  }

  @override
  Future<Map<String, dynamic>> get(
    Uri uri, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _performRequest(
      _dio.get(
        uri.toString(),
        queryParameters: queryParameters,
        options: options ?? Options(headers: headers),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> post(
    Uri uri, {
    required dynamic body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _performRequest(
      _dio.post(
        uri.toString(),
        data: body,
        queryParameters: queryParameters,
        options: options ?? Options(headers: headers),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> delete(
    Uri uri, {
    required Map<String, dynamic> body,
    Map<String, dynamic>? headers,
    Options? options,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return await _performRequest(
      _dio.delete(
        uri.toString(),
        data: body,
        queryParameters: queryParameters,
        options: options ?? Options(headers: headers),
        cancelToken: cancelToken,
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> put(
    Uri uri, {
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _performRequest(
      _dio.put(
        uri.toString(),
        data: body,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        queryParameters: queryParameters,
        options: options ?? Options(headers: headers),
        cancelToken: cancelToken,
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> fetch(
    Uri uri, {
    String? method,
    Duration? sendTimeout,
    Duration? receiveTimeout,
    Duration? connectTimeout,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    String? baseUrl,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    String? contentType,
    ValidateStatus? validateStatus,
    bool? receiveDataWhenStatusError,
    bool? followRedirects,
    int? maxRedirects,
    RequestEncoder? requestEncoder,
    ResponseDecoder? responseDecoder,
    ListFormat? listFormat,
    bool? setRequestContentTypeWhenNoPayload,
  }) async {
    return await _performRequest(
      _dio.fetch(
        RequestOptions(
          path: uri.toString(),
          data: body,
          headers: headers,
          baseUrl: baseUrl,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          connectTimeout: connectTimeout,
          contentType: contentType,
          extra: extra,
          followRedirects: followRedirects,
          listFormat: listFormat,
          maxRedirects: maxRedirects,
          method: method,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onReceiveProgress,
          receiveDataWhenStatusError: receiveDataWhenStatusError,
          receiveTimeout: receiveTimeout,
          requestEncoder: requestEncoder,
          responseDecoder: responseDecoder,
          responseType: responseType,
          sendTimeout: sendTimeout,
          setRequestContentTypeWhenNoPayload:
              setRequestContentTypeWhenNoPayload,
          validateStatus: validateStatus,
        ),
      ),
    );
  }

  /// Try/catch to wrap api calls
  Future<Map<String, dynamic>> _performRequest(
      Future<Response<dynamic>> apiCall) async {
    try {
      final response = await apiCall;
      if (!response.statusCode.toString().startsWith('20')) {
        final exception =
            AppException.fromHttpErrorMap(json.decode(response.data));
        throw exception;
      }
      return response.data;
    } on DioException catch (e) {
      throw convertDioException(e);
    } catch (e) {
      _log.e(e);
      throw AppException(
        data: e,
        message:
            'There\'s a slight issue communicating with our server. Try again in a bit',
      );
    }
  }

  IAppException convertDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return InternetAppException(data: e);
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return AppException(
          message: e.response?.data['message'] ?? e.message ?? '',
          data: e.response?.data,
        );
      case DioExceptionType.unknown:
        if (e.error is SocketException) return InternetAppException(data: e);
        if (e.error is HandshakeException) return InternetAppException(data: e);
        if (e.error is HttpException) return InternetAppException(data: e);
        return FallbackAppException(data: e);
      case DioExceptionType.badResponse:
        if ((e.response?.statusCode ?? 0) >= HttpStatus.internalServerError) {
          return ServerAppException(data: e.response?.data);
        }
        if ((e.response?.statusCode ?? 0) == HttpStatus.unauthorized) {
          return UnauthorizedAppException(data: e.response?.data);
        }
        if (e.response?.statusCode == HttpStatus.notFound) {
          return ServerAppException(data: e.response?.data);
        }
        return AppException.fromHttpErrorMap(e.response?.data ?? {});
    }
  }
}
