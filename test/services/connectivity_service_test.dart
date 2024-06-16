import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/shared/models/app_exception.dart';
import 'package:weather_forecast/services/_services.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late Connectivity connectivity;
  late ConnectivityService connectivityService;

  setUp(() {
    connectivity = MockConnectivity();
    connectivityService = ConnectivityService(connectivity);
  });

  group('ConnectivityPlusService -', () {
    group('checkInternetConnection -', () {
      test('when called, should return true if connectivity is mobile',
          () async {
        when(() => connectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.mobile]);

        final result = await connectivityService.checkInternetConnection();

        expect(result, true);
        verify(() => connectivity.checkConnectivity()).called(1);
      });

      test('when called, should return true if connectivity is wifi', () async {
        when(() => connectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);

        final result = await connectivityService.checkInternetConnection();

        expect(result, true);
        verify(() => connectivity.checkConnectivity()).called(1);
      });

      test('when called, should return true if connectivity is ethernet',
          () async {
        when(() => connectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.ethernet]);

        final result = await connectivityService.checkInternetConnection();

        expect(result, true);
        verify(() => connectivity.checkConnectivity()).called(1);
      });

      test('when called, should return false if connectivity is vpn', () async {
        when(() => connectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.vpn]);

        final result = await connectivityService.checkInternetConnection();

        expect(result, false);
        verify(() => connectivity.checkConnectivity()).called(1);
      });

      test('when called, should return false if connectivity is bluetooth',
          () async {
        when(() => connectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.bluetooth]);

        final result = await connectivityService.checkInternetConnection();

        expect(result, false);
        verify(() => connectivity.checkConnectivity()).called(1);
      });

      test('when called, should return false if connectivity is other',
          () async {
        when(() => connectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.other]);

        final result = await connectivityService.checkInternetConnection();

        expect(result, false);
        verify(() => connectivity.checkConnectivity()).called(1);
      });

      test('when called, should return false if connectivity is none',
          () async {
        when(() => connectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);

        final result = await connectivityService.checkInternetConnection();

        expect(result, false);
        verify(() => connectivity.checkConnectivity()).called(1);
      });

      test(
          'when called, and connectivity throws an error, should throw an InternetAppException',
          () async {
        final error = Exception('Connectivity Error');
        when(() => connectivity.checkConnectivity()).thenThrow(error);

        expect(() => connectivityService.checkInternetConnection(),
            throwsA(isA<InternetAppException>()));
      });
    });

    group('connectionStream -', () {
      final values = [
        [ConnectivityResult.mobile],
        [ConnectivityResult.wifi],
        [ConnectivityResult.ethernet],
        [ConnectivityResult.vpn],
        [ConnectivityResult.bluetooth],
        [ConnectivityResult.other],
        [ConnectivityResult.none],
      ];
      test('should return a stream of booleans', () {
        when(() => connectivity.onConnectivityChanged)
            .thenAnswer((_) => Stream.fromIterable(values));

        final stream = connectivityService.connectionStream;

        expect(stream, isA<Stream<bool>>());
        expect(stream,
            emitsInOrder([true, true, true, false, false, false, false]));
      });

      test('should throw an error if the stream throws an error', () {
        final error = Exception('Stream Error');
        when(() => connectivity.onConnectivityChanged)
            .thenAnswer((_) => Stream.error(error));

        expect(connectivityService.connectionStream, emitsError(error));
      });
    });
  });
}
