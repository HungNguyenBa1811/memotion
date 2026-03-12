import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:memotion/core/network/api_exceptions.dart';
import 'package:memotion/core/network/services/task_api_service.dart';
import 'package:memotion/features/medication/data/alarm_schedule_engine.dart';
import 'package:memotion/features/medication/data/medication_cache_store.dart';
import 'package:memotion/features/medication/data/medication_sync_service.dart';
import 'package:memotion/features/medication/models/medication_task.dart';
import '../../helpers/test_data.dart';

// ─── mocks ────────────────────────────────────────────────────────────────────

class MockTaskApiService extends Mock implements TaskApiService {}

class MockCacheStore extends Mock implements MedicationCacheStore {}

class MockAlarmEngine extends Mock implements AlarmScheduleEngine {}

// ─── helpers ──────────────────────────────────────────────────────────────────

const _okSchedule = ScheduleResult(scheduled: 1, skipped: 0, failed: 0);

void main() {
  // mocktail requires fallback values for non-nullable custom types used with any().
  setUpAll(() {
    registerFallbackValue(const Duration());
    registerFallbackValue(<MedicationTask>[]);
  });

  late MockTaskApiService apiService;
  late MockCacheStore cacheStore;
  late MockAlarmEngine alarmEngine;
  late MedicationSyncService syncService;

  setUp(() {
    apiService = MockTaskApiService();
    cacheStore = MockCacheStore();
    alarmEngine = MockAlarmEngine();
    syncService = MedicationSyncService(
      apiService: apiService,
      cacheStore: cacheStore,
      alarmEngine: alarmEngine,
    );
  });

  // ─── syncOnAppLaunch — happy path ─────────────────────────────────────────

  group('syncOnAppLaunch — online', () {
    setUp(() {
      when(() => apiService.getAllMedicationTasks())
          .thenAnswer((_) async => [makeTaskDto()]);
      when(() => cacheStore.persist(any())).thenAnswer((_) async {});
      when(() => alarmEngine.rescheduleAll(any()))
          .thenAnswer((_) async => _okSchedule);
    });

    test('returns SyncSource.api with correct counts', () async {
      final result = await syncService.syncOnAppLaunch();

      expect(result.source, SyncSource.api);
      expect(result.taskCount, 1);
      expect(result.alarmsScheduled, 1);
      expect(result.error, isNull);
      expect(result.cachedAt, isNotNull);
    });

    test('persists tasks to cache', () async {
      await syncService.syncOnAppLaunch();
      verify(() => cacheStore.persist(any())).called(1);
    });

    test('reschedules alarms after caching', () async {
      await syncService.syncOnAppLaunch();
      verify(() => alarmEngine.rescheduleAll(any())).called(1);
    });

    test('skips tasks without medication_detail', () async {
      // makeTaskDto always has medicationDetail; a bare TaskDto without it should be filtered
      when(() => apiService.getAllMedicationTasks()).thenAnswer((_) async => [
            makeTaskDto(taskId: 'with-detail'),
          ]);

      final result = await syncService.syncOnAppLaunch();
      expect(result.taskCount, 1);
    });
  });

  // ─── syncOnAppLaunch — auth / profile errors ──────────────────────────────

  group('syncOnAppLaunch — not authenticated / no profile', () {
    test('returns SyncSource.none silently on UnauthorizedException', () async {
      when(() => apiService.getAllMedicationTasks())
          .thenThrow(const UnauthorizedException());

      final result = await syncService.syncOnAppLaunch();

      expect(result.source, SyncSource.none);
      expect(result.error, isNull);
      verifyNever(() => cacheStore.persist(any()));
      verifyNever(() => alarmEngine.rescheduleAll(any()));
    });

    test('returns SyncSource.none silently on PatientProfileNotFoundException', () async {
      when(() => apiService.getAllMedicationTasks())
          .thenThrow(const PatientProfileNotFoundException());

      final result = await syncService.syncOnAppLaunch();

      expect(result.source, SyncSource.none);
      verifyNever(() => cacheStore.persist(any()));
    });
  });

  // ─── syncOnAppLaunch — offline / cache fallback ───────────────────────────

  group('syncOnAppLaunch — offline cache fallback', () {
    setUp(() {
      when(() => apiService.getAllMedicationTasks())
          .thenThrow(const NetworkException());
    });

    test('falls back to cache and reschedules alarms', () async {
      final cached = [makeTask()];
      when(() => cacheStore.restore(maxAge: any(named: 'maxAge')))
          .thenAnswer((_) async => cached);
      when(() => alarmEngine.rescheduleAll(any()))
          .thenAnswer((_) async => _okSchedule);
      when(() => cacheStore.getMetadata()).thenAnswer((_) async => CacheMetadata(
            cachedAt: DateTime.now().subtract(const Duration(hours: 3)),
            taskCount: 1,
            source: 'api',
          ));

      final result = await syncService.syncOnAppLaunch();

      expect(result.source, SyncSource.cache);
      expect(result.taskCount, 1);
      expect(result.error, isNotNull);
      verify(() => alarmEngine.rescheduleAll(any())).called(1);
    });

    test('returns SyncSource.none when cache is also empty', () async {
      when(() => cacheStore.restore(maxAge: any(named: 'maxAge')))
          .thenAnswer((_) async => null);

      final result = await syncService.syncOnAppLaunch();

      expect(result.source, SyncSource.none);
      verifyNever(() => alarmEngine.rescheduleAll(any()));
    });

    test('returns SyncSource.none when cache returns empty list', () async {
      when(() => cacheStore.restore(maxAge: any(named: 'maxAge')))
          .thenAnswer((_) async => <MedicationTask>[]);

      final result = await syncService.syncOnAppLaunch();

      expect(result.source, SyncSource.none);
    });
  });

  // ─── syncOnAppLaunch — mutex guard ────────────────────────────────────────

  group('syncOnAppLaunch — mutex', () {
    test('concurrent call returns SyncSource.none while first is in progress', () async {
      when(() => apiService.getAllMedicationTasks()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return [makeTaskDto()];
      });
      when(() => cacheStore.persist(any())).thenAnswer((_) async {});
      when(() => alarmEngine.rescheduleAll(any()))
          .thenAnswer((_) async => _okSchedule);

      final first = syncService.syncOnAppLaunch();
      final second = syncService.syncOnAppLaunch(); // fires immediately while first is pending

      final results = await Future.wait([first, second]);
      final sources = results.map((r) => r.source).toList();

      expect(sources, containsOnce(SyncSource.api));
      expect(sources, containsOnce(SyncSource.none));
    });

    test('mutex is released after completion so a second call can succeed', () async {
      when(() => apiService.getAllMedicationTasks())
          .thenAnswer((_) async => [makeTaskDto()]);
      when(() => cacheStore.persist(any())).thenAnswer((_) async {});
      when(() => alarmEngine.rescheduleAll(any()))
          .thenAnswer((_) async => _okSchedule);

      await syncService.syncOnAppLaunch();
      final second = await syncService.syncOnAppLaunch();

      expect(second.source, SyncSource.api);
    });
  });

  // ─── refreshCache ─────────────────────────────────────────────────────────

  group('refreshCache', () {
    test('fetches fresh data and updates cache on success', () async {
      when(() => apiService.getAllMedicationTasks())
          .thenAnswer((_) async => [makeTaskDto()]);
      when(() => cacheStore.persist(any())).thenAnswer((_) async {});
      when(() => alarmEngine.rescheduleAll(any()))
          .thenAnswer((_) async => _okSchedule);

      final result = await syncService.refreshCache();

      expect(result.source, SyncSource.api);
      verify(() => cacheStore.persist(any())).called(1);
    });

    test('returns SyncSource.none with error on failure — no cache fallback', () async {
      when(() => apiService.getAllMedicationTasks())
          .thenThrow(const NetworkException());

      final result = await syncService.refreshCache();

      expect(result.source, SyncSource.none);
      expect(result.error, isNotNull);
      verifyNever(() => cacheStore.restore(maxAge: any(named: 'maxAge')));
    });

    test('concurrent call returns SyncSource.none while first is running', () async {
      when(() => apiService.getAllMedicationTasks()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return [makeTaskDto()];
      });
      when(() => cacheStore.persist(any())).thenAnswer((_) async {});
      when(() => alarmEngine.rescheduleAll(any()))
          .thenAnswer((_) async => _okSchedule);

      final first = syncService.refreshCache();
      final second = syncService.refreshCache();
      final results = await Future.wait([first, second]);

      expect(results.map((r) => r.source), containsOnce(SyncSource.none));
    });
  });

  // ─── getTasksForDate ──────────────────────────────────────────────────────

  group('getTasksForDate', () {
    test('returns only tasks matching the given date', () async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      when(() => cacheStore.restore(maxAge: any(named: 'maxAge'))).thenAnswer(
        (_) async => [
          makeTask(taskId: 'today', dueDate: today),
          makeTask(taskId: 'tomorrow', dueDate: tomorrow),
        ],
      );

      final result = await syncService.getTasksForDate(today);

      expect(result.length, 1);
      expect(result.first.taskId, 'today');
    });

    test('returns empty list when cache is null', () async {
      when(() => cacheStore.restore(maxAge: any(named: 'maxAge')))
          .thenAnswer((_) async => null);

      expect(await syncService.getTasksForDate(DateTime.now()), isEmpty);
    });

    test('returns empty list when no tasks match the date', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      when(() => cacheStore.restore(maxAge: any(named: 'maxAge')))
          .thenAnswer((_) async => [makeTask(dueDate: yesterday)]);

      final result = await syncService.getTasksForDate(DateTime.now());
      expect(result, isEmpty);
    });
  });
}
