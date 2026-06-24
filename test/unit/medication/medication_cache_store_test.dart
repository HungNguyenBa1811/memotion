import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memotion/features/medication/data/medication_cache_store.dart';
import '../../helpers/test_data.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MedicationCacheStore', () {
    late MedicationCacheStore store;

    setUp(() => store = MedicationCacheStore());

    // ─── persist & restore ───────────────────────────────────────────────────

    group('persist and restore', () {
      test('roundtrips a list of tasks correctly', () async {
        final tasks = [
          makeTask(taskId: 'task-001'),
          makeTask(taskId: 'task-002'),
        ];
        await store.persist(tasks);

        final restored = await store.restore();
        expect(restored, isNotNull);
        expect(restored!.length, 2);
        expect(restored[0].taskId, 'task-001');
        expect(restored[1].taskId, 'task-002');
      });

      test('preserves medication detail fields', () async {
        await store.persist([
          makeTask(medicationName: 'Vitamin D3', dosage: '2 viên', notes: 'Uống buổi tối'),
        ]);

        final task = (await store.restore())!.first;
        expect(task.medicationDetail.name, 'Vitamin D3');
        expect(task.medicationDetail.dosage, '2 viên');
        expect(task.medicationDetail.notes, 'Uống buổi tối');
      });

      test('returns null when nothing has been persisted', () async {
        expect(await store.restore(), isNull);
      });

      test('returns null when cache is older than maxAge', () async {
        await store.persist([makeTask()]);
        // Wait so that elapsed time > Duration.zero, satisfying the > check.
        await Future.delayed(const Duration(milliseconds: 5));
        expect(await store.restore(maxAge: Duration.zero), isNull);
      });

      test('accepts stale data when maxAge is very large', () async {
        await store.persist([makeTask()]);
        expect(
          await store.restore(maxAge: const Duration(days: 365)),
          isNotNull,
        );
      });

      test('second store instance reads data written by first', () async {
        await store.persist([makeTask()]);
        final result = await MedicationCacheStore().restore();
        expect(result, isNotNull);
        expect(result!.first.taskId, 'task-001');
      });

      test('overwriting cache replaces all previous tasks', () async {
        await store.persist([makeTask(taskId: 'old')]);
        await store.persist([makeTask(taskId: 'new-1'), makeTask(taskId: 'new-2')]);

        final result = await store.restore();
        expect(result!.length, 2);
        expect(result.map((t) => t.taskId), containsAll(['new-1', 'new-2']));
      });
    });

    // ─── isValid ─────────────────────────────────────────────────────────────

    group('isValid', () {
      test('returns false when no cache exists', () async {
        expect(await store.isValid(), isFalse);
      });

      test('returns true immediately after persist', () async {
        await store.persist([makeTask()]);
        expect(await store.isValid(), isTrue);
      });

      test('returns false when maxAge is zero', () async {
        await store.persist([makeTask()]);
        await Future.delayed(const Duration(milliseconds: 5));
        expect(await store.isValid(maxAge: Duration.zero), isFalse);
      });
    });

    // ─── metadata ────────────────────────────────────────────────────────────

    group('metadata', () {
      test('returns null before first persist', () async {
        expect(await store.getMetadata(), isNull);
      });

      test('records taskCount', () async {
        await store.persist([makeTask(), makeTask(taskId: 'task-002')]);
        final meta = await store.getMetadata();
        expect(meta!.taskCount, 2);
      });

      test('defaults source to api', () async {
        await store.persist([makeTask()]);
        expect((await store.getMetadata())!.source, 'api');
      });

      test('records custom source', () async {
        await store.persist([makeTask()], source: 'manual');
        expect((await store.getMetadata())!.source, 'manual');
      });

      test('cachedAt is within 2 seconds of now', () async {
        final before = DateTime.now();
        await store.persist([makeTask()]);
        final cachedAt = (await store.getMetadata())!.cachedAt;
        expect(!cachedAt.isBefore(before), isTrue); // >= before
        expect(cachedAt.difference(before).inSeconds, lessThanOrEqualTo(2));
      });
    });

    // ─── clear ───────────────────────────────────────────────────────────────

    group('clear', () {
      test('removes tasks and metadata', () async {
        await store.persist([makeTask()]);
        await store.clear();
        expect(await store.restore(), isNull);
        expect(await store.getMetadata(), isNull);
      });

      test('isValid returns false after clear', () async {
        await store.persist([makeTask()]);
        await store.clear();
        expect(await store.isValid(), isFalse);
      });
    });

    // ─── cache versioning ────────────────────────────────────────────────────

    group('cache versioning', () {
      test('persist stores a non-zero version in metadata', () async {
        await store.persist([makeTask()]);
        final meta = await store.getMetadata();
        expect(meta!.version, greaterThan(0));
      });

      test('restore succeeds when persisted version matches current', () async {
        await store.persist([makeTask()]);
        expect(await store.restore(), isNotNull);
      });

      test('restore returns null and clears cache on version mismatch', () async {
        // Write stale metadata with version 0 directly into SharedPreferences,
        // simulating data written by an older build of the app.
        final prefs = await SharedPreferences.getInstance();
        final staleTask = makeTask();
        final staleMeta = jsonEncode({
          'cached_at': DateTime.now().toIso8601String(),
          'task_count': 1,
          'source': 'api',
          'version': 0, // does not match _currentVersion = 1
        });
        await prefs.setString('medication_all_tasks_cache', jsonEncode([staleTask.toJson()]));
        await prefs.setString('medication_cache_meta', staleMeta);

        final result = await store.restore();
        expect(result, isNull);
      });

      test('cache is cleared after version mismatch so next persist works', () async {
        final prefs = await SharedPreferences.getInstance();
        final staleMeta = jsonEncode({
          'cached_at': DateTime.now().toIso8601String(),
          'task_count': 1,
          'source': 'api',
          'version': 0,
        });
        await prefs.setString('medication_all_tasks_cache', jsonEncode([makeTask().toJson()]));
        await prefs.setString('medication_cache_meta', staleMeta);

        // Trigger version check → should clear
        await store.restore();
        expect(await store.getMetadata(), isNull);

        // A fresh persist should work normally afterwards
        await store.persist([makeTask(taskId: 'fresh')]);
        final result = await store.restore();
        expect(result, isNotNull);
        expect(result!.first.taskId, 'fresh');
      });

      test('CacheMetadata.fromJson defaults version to 0 when field is absent', () {
        final meta = CacheMetadata.fromJson({
          'cached_at': DateTime.now().toIso8601String(),
          'task_count': 1,
          'source': 'api',
          // 'version' intentionally omitted — old format
        });
        expect(meta.version, 0);
      });
    });
  });
}
