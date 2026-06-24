import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:memotion/core/services/connectivity_service.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  late StreamController<List<ConnectivityResult>> controller;
  late ConnectivityService service;

  setUp(() {
    mockConnectivity = MockConnectivity();
    controller = StreamController<List<ConnectivityResult>>.broadcast();
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => controller.stream);
    service = ConnectivityService(connectivity: mockConnectivity);
  });

  tearDown(() => controller.close());

  // ─── isOnline ─────────────────────────────────────────────────────────────

  group('isOnline', () {
    test('returns true for wifi', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      expect(await service.isOnline(), isTrue);
    });

    test('returns true for mobile data', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);
      expect(await service.isOnline(), isTrue);
    });

    test('returns true for ethernet', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.ethernet]);
      expect(await service.isOnline(), isTrue);
    });

    test('returns false when connectivity is none', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      expect(await service.isOnline(), isFalse);
    });

    test('returns true when at least one result is non-none', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none, ConnectivityResult.wifi]);
      expect(await service.isOnline(), isTrue);
    });
  });

  // ─── onConnectivityChanged ────────────────────────────────────────────────

  group('onConnectivityChanged', () {
    test('emits true when wifi comes up', () {
      expect(service.onConnectivityChanged, emitsInOrder([true]));
      controller.add([ConnectivityResult.wifi]);
    });

    test('emits false when connectivity is lost', () {
      expect(service.onConnectivityChanged, emitsInOrder([false]));
      controller.add([ConnectivityResult.none]);
    });

    test('emits multiple events in order', () {
      expect(
        service.onConnectivityChanged,
        emitsInOrder([true, false, true]),
      );
      controller.add([ConnectivityResult.wifi]);
      controller.add([ConnectivityResult.none]);
      controller.add([ConnectivityResult.mobile]);
    });
  });

  // ─── onConnectivityRestored ───────────────────────────────────────────────

  group('onConnectivityRestored', () {
    Future<List<bool>> collectEmissions(
      Future<void> Function() act,
    ) async {
      final emitted = <bool>[];
      final sub = service.onConnectivityRestored.listen(emitted.add);
      await act();
      // Give the stream a microtask to flush.
      await Future.delayed(Duration.zero);
      await sub.cancel();
      return emitted;
    }

    test('does not emit when starting online and staying online', () async {
      final emitted = await collectEmissions(() async {
        controller.add([ConnectivityResult.wifi]);
        await Future.delayed(Duration.zero);
        controller.add([ConnectivityResult.mobile]);
      });
      expect(emitted, isEmpty);
    });

    test('does not emit when going offline', () async {
      final emitted = await collectEmissions(() async {
        controller.add([ConnectivityResult.none]);
      });
      expect(emitted, isEmpty);
    });

    test('emits true on offline → online transition', () async {
      final emitted = await collectEmissions(() async {
        // First go offline
        controller.add([ConnectivityResult.none]);
        await Future.delayed(Duration.zero);
        // Then come back online
        controller.add([ConnectivityResult.wifi]);
        await Future.delayed(Duration.zero);
      });
      expect(emitted.length, 1);
      expect(emitted.first, isTrue);
    });

    test('emits only once for repeated online events after restoration', () async {
      final emitted = await collectEmissions(() async {
        controller.add([ConnectivityResult.none]);
        await Future.delayed(Duration.zero);
        controller.add([ConnectivityResult.wifi]);
        await Future.delayed(Duration.zero);
        // Another online event — should not emit again
        controller.add([ConnectivityResult.mobile]);
        await Future.delayed(Duration.zero);
      });
      expect(emitted.length, 1);
    });

    test('emits twice for two separate disconnection/restore cycles', () async {
      final emitted = await collectEmissions(() async {
        // First cycle
        controller.add([ConnectivityResult.none]);
        await Future.delayed(Duration.zero);
        controller.add([ConnectivityResult.wifi]);
        await Future.delayed(Duration.zero);
        // Second cycle
        controller.add([ConnectivityResult.none]);
        await Future.delayed(Duration.zero);
        controller.add([ConnectivityResult.mobile]);
        await Future.delayed(Duration.zero);
      });
      expect(emitted.length, 2);
    });
  });
}
