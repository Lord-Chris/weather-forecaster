import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/core/shared/models/_models.dart';
import 'package:weather_forecast/services/_services.dart';

import '../helpers/service_helpers.dart';

class MockHiveInterface extends Mock implements HiveInterface {}

class MockBox<E> extends Mock implements Box<E> {}

void main() {
  group('LocalStorageService Tests - ', () {
    late ILocalStorage service;
    late HiveInterface hive;
    late Box box;

    setUp(() {
      registerServices();
      hive = MockHiveInterface();
      box = MockBox();
      service = LocalStorageService(hive: hive);
    });

    tearDown(() {
      verifyNoMoreInteractions(hive);
      verifyNoMoreInteractions(box);
      reset(hive);
      reset(box);
      unregisterServices();
    });

    group('delete - ', () {
      test('When called, should delete the key from the box', () async {
        // Arrange
        when(() => hive.openBox(any())).thenAnswer((_) => Future.value(box));
        when(() => box.delete(any())).thenAnswer((_) => Future.value(null));

        // Act
        await service.delete('box', key: 'key');

        // Assert
        verify(() => hive.openBox('box')).called(1);
        verify(() => box.delete('key')).called(1);
      });

      test('When called, should throw a Failure if the box is not found',
          () async {
        // Arrange
        when(() => hive.openBox('test')).thenThrow(Exception());

        // Act
        IAppException? failure;
        try {
          await service.delete('test', key: 'key');
        } on IAppException catch (e) {
          failure = e;
        }

        // Assert
        expect(failure, isA<DeviceAppException>());
        verify(() => hive.openBox('test')).called(1);
      });
    });

    group('get - ', () {
      test('When called, hive and box should be called once each', () async {
        // Arrange
        when(() => hive.openBox(any())).thenAnswer((_) => Future.value(box));
        when(() => box.get(any())).thenAnswer((_) => Future.value('null'));

        // Act
        final result = await service.get('box', key: 'key');

        // Assert
        expect(result, 'null');
        verify(() => hive.openBox('box')).called(1);
        verify(() => box.get('key')).called(1);
      });

      test(
          'When called, should  throw failure if error occurs with hive or box',
          () async {
        // Arrange
        when(() => hive.openBox(any())).thenAnswer((_) => Future.value(box));
        when(() => box.get(any())).thenThrow(Exception());

        // Act
        IAppException? failure;
        try {
          await service.get('test', key: 'key');
        } on IAppException catch (e) {
          failure = e;
        }

        // Assert
        expect(failure, isA<DeviceAppException>());
        verify(() => hive.openBox('test')).called(1);
        verify(() => box.get('key')).called(1);
      });
    });

    group('put - ', () {
      test('When called, should save the key and data to the box', () async {
        // Arrange
        when(() => hive.openBox(any())).thenAnswer((_) => Future.value(box));
        when(() => box.put(any(), any())).thenAnswer((_) => Future.value(null));
        when(() => box.get(any())).thenAnswer((_) => Future.value('null'));

        // Act
        await service.put('box', key: 'key', value: 'value');

        // Assert
        verify(() => hive.openBox('box')).called(1);
        verify(() => box.put('key', 'value')).called(1);
        verify(() => box.get('key')).called(1);
      });

      test('When called, should throw a Failure if the box is not found',
          () async {
        // Arrange
        when(() => hive.openBox(any())).thenThrow(Exception());

        // Act
        IAppException? failure;
        try {
          await service.put('box', key: 'key', value: 'value');
        } on IAppException catch (e) {
          failure = e;
        }

        // Assert
        expect(failure, isA<DeviceAppException>());
        verify(() => hive.openBox('box')).called(1);
      });
    });

    group('clear - ', () {
      test('When called, hive and box should be called once each', () async {
        // Arrange
        when(() => hive.openBox(any())).thenAnswer((_) => Future.value(box));
        when(() => box.clear()).thenAnswer((_) => Future.value(1));

        // Act
        final result = await service.clear('box');

        // Assert
        expect(result, 1);
        verify(() => hive.openBox('box')).called(1);
        verify(() => box.clear()).called(1);
      });

      test('When called, should throw a Failure if the box is not found',
          () async {
        // Arrange
        when(() => hive.openBox(any())).thenThrow(Exception());

        // Act
        IAppException? failure;
        try {
          await service.clear('box');
        } on IAppException catch (e) {
          failure = e;
        }

        // Assert
        expect(failure, isA<DeviceAppException>());
        verify(() => hive.openBox('box')).called(1);
      });
    });
  });
}
