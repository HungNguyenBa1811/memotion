import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memotion/features/medication/data/pending_actions_queue.dart';
import 'package:memotion/features/medication/models/pending_action.dart';

// ─── helpers ──────────────────────────────────────────────────────────────────

PendingAction makeAction({
  String taskId = 'task-001',
  PendingActionType type = PendingActionType.complete,
  String? medicationName,
}) => PendingAction(
      taskId: taskId,
      type: type,
      queuedAt: DateTime.now(),
      medicationName: medicationName,
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PendingActionsQueue', () {
    late PendingActionsQueue queue;

    setUp(() => queue = PendingActionsQueue());

    // ─── enqueue / getPending ────────────────────────────────────────────────

    group('enqueue and getPending', () {
      test('empty queue returns empty list', () async {
        expect(await queue.getPending(), isEmpty);
      });

      test('enqueue adds action to queue', () async {
        await queue.enqueue(makeAction());
        expect(await queue.getPending(), hasLength(1));
      });

      test('enqueue multiple distinct actions preserves all', () async {
        await queue.enqueue(makeAction(taskId: 'a'));
        await queue.enqueue(makeAction(taskId: 'b'));
        await queue.enqueue(makeAction(taskId: 'c'));
        expect(await queue.getPending(), hasLength(3));
      });

      test('enqueue deduplicates same taskId + type', () async {
        await queue.enqueue(makeAction(taskId: 'task-001', type: PendingActionType.complete));
        await queue.enqueue(makeAction(taskId: 'task-001', type: PendingActionType.complete));
        expect(await queue.getPending(), hasLength(1));
      });

      test('enqueue replaces existing action with same taskId + type', () async {
        await queue.enqueue(makeAction(taskId: 'task-001', medicationName: 'Old'));
        await queue.enqueue(makeAction(taskId: 'task-001', medicationName: 'New'));

        final actions = await queue.getPending();
        expect(actions, hasLength(1));
        expect(actions.first.medicationName, 'New');
      });

      test('same taskId with different types are treated as distinct', () async {
        await queue.enqueue(makeAction(taskId: 'task-001', type: PendingActionType.complete));
        await queue.enqueue(makeAction(taskId: 'task-001', type: PendingActionType.skip));
        expect(await queue.getPending(), hasLength(2));
      });

      test('data survives across queue instances (persistent via SharedPreferences)', () async {
        await queue.enqueue(makeAction(taskId: 'task-001'));
        final other = PendingActionsQueue();
        expect(await other.getPending(), hasLength(1));
      });

      test('taskId and type round-trip correctly', () async {
        await queue.enqueue(makeAction(taskId: 'task-xyz', type: PendingActionType.skip));
        final action = (await queue.getPending()).first;
        expect(action.taskId, 'task-xyz');
        expect(action.type, PendingActionType.skip);
      });
    });

    // ─── remove ──────────────────────────────────────────────────────────────

    group('remove', () {
      test('removes a specific action from the queue', () async {
        final action = makeAction(taskId: 'task-001');
        await queue.enqueue(action);
        await queue.remove(action);
        expect(await queue.getPending(), isEmpty);
      });

      test('removing one action leaves others intact', () async {
        final a = makeAction(taskId: 'a');
        final b = makeAction(taskId: 'b');
        await queue.enqueue(a);
        await queue.enqueue(b);
        await queue.remove(a);

        final remaining = await queue.getPending();
        expect(remaining, hasLength(1));
        expect(remaining.first.taskId, 'b');
      });

      test('removing non-existent action is a no-op', () async {
        await queue.enqueue(makeAction(taskId: 'a'));
        await queue.remove(makeAction(taskId: 'ghost'));
        expect(await queue.getPending(), hasLength(1));
      });
    });

    // ─── clear ───────────────────────────────────────────────────────────────

    group('clear', () {
      test('removes all pending actions', () async {
        await queue.enqueue(makeAction(taskId: 'a'));
        await queue.enqueue(makeAction(taskId: 'b'));
        await queue.clear();
        expect(await queue.getPending(), isEmpty);
      });

      test('hasPending returns false after clear', () async {
        await queue.enqueue(makeAction());
        await queue.clear();
        expect(await queue.hasPending, isFalse);
      });
    });

    // ─── hasPending / pendingCount ───────────────────────────────────────────

    group('hasPending and pendingCount', () {
      test('hasPending is false when queue is empty', () async {
        expect(await queue.hasPending, isFalse);
      });

      test('hasPending is true after enqueue', () async {
        await queue.enqueue(makeAction());
        expect(await queue.hasPending, isTrue);
      });

      test('pendingCount is 0 for empty queue', () async {
        expect(await queue.pendingCount, 0);
      });

      test('pendingCount matches number of distinct actions', () async {
        await queue.enqueue(makeAction(taskId: 'a'));
        await queue.enqueue(makeAction(taskId: 'b'));
        await queue.enqueue(makeAction(taskId: 'c'));
        expect(await queue.pendingCount, 3);
      });

      test('pendingCount reflects deduplication', () async {
        await queue.enqueue(makeAction(taskId: 'a'));
        await queue.enqueue(makeAction(taskId: 'a')); // duplicate
        expect(await queue.pendingCount, 1);
      });
    });

    // ─── isQueued ────────────────────────────────────────────────────────────

    group('isQueued', () {
      test('returns false when queue is empty', () async {
        expect(await queue.isQueued('task-001', PendingActionType.complete), isFalse);
      });

      test('returns true after enqueue with matching taskId + type', () async {
        await queue.enqueue(makeAction(taskId: 'task-001', type: PendingActionType.complete));
        expect(await queue.isQueued('task-001', PendingActionType.complete), isTrue);
      });

      test('returns false for different type on same taskId', () async {
        await queue.enqueue(makeAction(taskId: 'task-001', type: PendingActionType.complete));
        expect(await queue.isQueued('task-001', PendingActionType.skip), isFalse);
      });

      test('returns false after action is removed', () async {
        final action = makeAction(taskId: 'task-001');
        await queue.enqueue(action);
        await queue.remove(action);
        expect(await queue.isQueued('task-001', PendingActionType.complete), isFalse);
      });
    });

    // ─── getActionsForTask ───────────────────────────────────────────────────

    group('getActionsForTask', () {
      test('returns empty list when no actions for task', () async {
        await queue.enqueue(makeAction(taskId: 'other'));
        expect(await queue.getActionsForTask('task-001'), isEmpty);
      });

      test('returns all actions for specified taskId', () async {
        await queue.enqueue(makeAction(taskId: 'task-001', type: PendingActionType.complete));
        await queue.enqueue(makeAction(taskId: 'task-001', type: PendingActionType.skip));
        await queue.enqueue(makeAction(taskId: 'other'));

        final actions = await queue.getActionsForTask('task-001');
        expect(actions, hasLength(2));
        expect(actions.map((a) => a.taskId).toSet(), {'task-001'});
      });
    });
  });
}