import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/shared/models/_models.dart';
import 'package:weather_forecast/services/_services.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('ApiService Tests - ', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late ApiService service;

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'request-origin': 'mobile-app',
      'Connection': 'keep-alive',
    };
    final routeUri = Uri.parse('https://example.com/api/fetch');
    final route = routeUri.toString();
    final data = {'feedback': 'It is nice!'};

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: routeUri.toString()));
      dioAdapter = DioAdapter(
        dio: dio,
        matcher: const FullHttpRequestMatcher(),
      );

      service = ApiService(dio);
    });

    group('get - ', () {
      test('result should be a Map<String, dynamic>', () async {
        final route = routeUri.toString();

        dioAdapter.onGet(
          route,
          (server) => server.reply(
            201,
            {'message': 'Feedback added successfully'},
            delay: const Duration(seconds: 1),
          ),
        );

        // Returns a response with 201 Created success status response code.
        final result = await service.get(routeUri);

        expect(result, isA<Map<String, dynamic>>());
      });

      test('should throw IAppException when error occurs', () async {
        final route = routeUri.toString();

        dioAdapter.onGet(
          route,
          (server) => server.throws(
            HttpStatus.notFound,
            DioException(requestOptions: RequestOptions(path: route)),
            delay: const Duration(seconds: 1),
          ),
        );

        // Returns a response with 201 Created success status response code.
        final call = service.get(routeUri);

        expect(() => call, throwsA(isA<IAppException>()));
      });
    });

    group('post - ', () {
      test('result should be a Map<String, dynamic>', () async {
        dioAdapter.onPost(
          route,
          (server) => server.reply(
            HttpStatus.ok,
            {'message': 'Feedback added successfully'},
            delay: const Duration(seconds: 1),
          ),
          data: data,
          headers: headers,
        );

        final result = await service.post(
          routeUri,
          headers: headers,
          body: data,
        );

        expect(result, isA<Map<String, dynamic>>());
      });

      test('should throw IAppException when error occurs', () async {
        final route = routeUri.toString();

        dioAdapter.onGet(
          route,
          (server) => server.throws(
            HttpStatus.notFound,
            DioException(requestOptions: RequestOptions(path: route)),
            delay: const Duration(seconds: 1),
          ),
        );

        // Returns a response with 201 Created success status response code.
        final call = service.get(routeUri);

        expect(() => call, throwsA(isA<IAppException>()));
      });
    });

    group('put - ', () {
      test('result should be a Map<String, dynamic>', () async {
        dioAdapter.onPut(
          route,
          (server) => server.reply(
            HttpStatus.ok,
            {'message': 'Feedback added successfully'},
            delay: const Duration(seconds: 1),
          ),
          data: data,
          headers: headers,
        );

        final result = await service.put(
          routeUri,
          headers: headers,
          body: data,
        );

        expect(result, isA<Map<String, dynamic>>());
      });

      test('should throw IAppException when error occurs', () async {
        final route = routeUri.toString();

        dioAdapter.onGet(
          route,
          (server) => server.throws(
            HttpStatus.notFound,
            DioException(requestOptions: RequestOptions(path: route)),
            delay: const Duration(seconds: 1),
          ),
        );

        // Returns a response with 201 Created success status response code.
        final call = service.get(routeUri);

        expect(() => call, throwsA(isA<IAppException>()));
      });
    });

    group('delete - ', () {
      test('result should be a Map<String, dynamic>', () async {
        dioAdapter.onDelete(
          route,
          (server) => server.reply(
            HttpStatus.ok,
            {'message': 'Feedback added successfully'},
            delay: const Duration(seconds: 1),
          ),
          data: data,
          headers: headers,
        );

        final result = await service.delete(
          routeUri,
          headers: headers,
          body: data,
        );

        expect(result, isA<Map<String, dynamic>>());
      });
      test('should throw IAppException when error occurs', () async {
        final route = routeUri.toString();

        dioAdapter.onGet(
          route,
          (server) => server.throws(
            HttpStatus.notFound,
            DioException(requestOptions: RequestOptions(path: route)),
            delay: const Duration(seconds: 1),
          ),
        );

        // Returns a response with 201 Created success status response code.
        final call = service.get(routeUri);

        expect(() => call, throwsA(isA<IAppException>()));
      });
    });

    group('convertDioException - ', () {
      test(
          'DioExceptionType.connectionTimeout should be mapped to InternetAppException',
          () {
        final error = service.convertDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        expect(error, isA<IAppException>());
        expect(error, isA<InternetAppException>());
      });

      test(
          'DioExceptionType.sendTimeout should be mapped to InternetAppException',
          () {
        final error = service.convertDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.sendTimeout,
          ),
        );

        expect(error, isA<IAppException>());
        expect(error, isA<InternetAppException>());
      });

      test(
          'DioExceptionType.receiveTimeout should be mapped to InternetAppException',
          () {
        final error = service.convertDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.receiveTimeout,
          ),
        );

        expect(error, isA<IAppException>());
        expect(error, isA<InternetAppException>());
      });

      test(
          'DioExceptionType.connectionError should be mapped to InternetAppException',
          () {
        final error = service.convertDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        );

        expect(error, isA<IAppException>());
        expect(error, isA<InternetAppException>());
      });

      test('DioExceptionType.badCertificate should be mapped to AppException',
          () {
        final error = service.convertDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.badCertificate,
          ),
        );

        expect(error, isA<IAppException>());
        expect(error, isA<AppException>());
      });

      test('DioExceptionType.cancel should be mapped to AppException', () {
        final error = service.convertDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.cancel,
          ),
        );

        expect(error, isA<IAppException>());
        expect(error, isA<AppException>());
      });

      test(
          'DioExceptionType.unknown should be mapped to the correct IAppException',
          () {
        final error = service.convertDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.unknown,
            error: const SocketException(''),
          ),
        );

        expect(error, isA<IAppException>());
        expect(error, isA<InternetAppException>());

        final error1 = service.convertDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.unknown,
            error: const HandshakeException(''),
          ),
        );

        expect(error1, isA<IAppException>());
        expect(error1, isA<InternetAppException>());

        final error2 = service.convertDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.unknown,
          ),
        );

        expect(error2, isA<IAppException>());
        expect(error2, isA<FallbackAppException>());
      });

      test(
          'DioExceptionType.badResponse should be mapped to the correct IAppException',
          () {
        var error = service.convertDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: HttpStatus.internalServerError,
              data: {'message': 'Internal server error'},
            ),
          ),
        );

        expect(error, isA<IAppException>());
        expect(error, isA<ServerAppException>());

        error = service.convertDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: HttpStatus.notFound,
              data: {'message': 'Not found'},
            ),
          ),
        );

        expect(error, isA<IAppException>());
        expect(error, isA<ServerAppException>());

        error = service.convertDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.badResponse,
          ),
        );

        expect(error, isA<IAppException>());
        expect(error, isA<AppException>());
      });
    });
  });
}
