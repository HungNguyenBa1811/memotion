import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pending_action.dart';

/// Result of draining the pending actions queue.
class DrainResult {
  final int succeeded;
  final int failed;
  final List<String> errors;

  const DrainResult({
    required this.succeeded,
    required this.failed,
    this.errors = const [],
  });

  bool get hasFailures => failed > 0;

  @override
  String toString() =>
      'DrainResult(succeeded: $succeeded, failed: $failed, errors: $errors)';
}

/// Manages a persistent queue of actions performed while offline.
///
/// When the user marks a medication as taken or skipped without connectivity,
/// the action is enqueued here. When the network is restored, the queue is
/// drained by sending each action to the backend API.
///
/// The queue is stored in SharedPreferences as a JSON array.
class PendingActionsQueue {
  static const _queueKey = 'medication_pending_actions';

  /// Adds an action to the queue.
  ///
  /// If an action for the same [taskId] and [type] already exists, it is
  /// replaced (deduplicated) to avoid duplicate API calls.
  Future<void> enqueue(PendingAction action) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getPending();

    // Remove any existing action for the same task/type combo
    current.removeWhere(
      (a) => a.taskId == action.taskId && a.type == action.type,
    );
    current.add(action);

    await _persist(prefs, current);
    developer.log(
      'Enqueued action: ${action.type.name} for task ${action.taskId}',
      name: 'PendingActionsQueue',
    );
  }

  /// Returns all pending actions in FIFO order.
  Future<List<PendingAction>> getPending() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => PendingAction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log(
        'Failed to parse pending actions: $e',
        name: 'PendingActionsQueue',
        level: 900,
      );
      return [];
    }
  }

  /// Returns the number of pending actions.
  Future<int> get pendingCount async {
    final actions = await getPending();
    return actions.length;
  }

  /// Returns true if there are pending actions.
  Future<bool> get hasPending async => (await pendingCount) > 0;

  /// Removes a specific action from the queue (after successful sync).
  Future<void> remove(PendingAction action) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getPending();
    current.removeWhere(
      (a) => a.taskId == action.taskId && a.type == action.type,
    );
    await _persist(prefs, current);
  }

  /// Removes all pending actions (e.g., after successful drain or logout).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
    developer.log('Cleared all pending actions', name: 'PendingActionsQueue');
  }

  /// Returns pending actions for a specific task.
  Future<List<PendingAction>> getActionsForTask(String taskId) async {
    final all = await getPending();
    return all.where((a) => a.taskId == taskId).toList();
  }

  /// Checks if a specific action is already queued.
  Future<bool> isQueued(String taskId, PendingActionType type) async {
    final all = await getPending();
    return all.any((a) => a.taskId == taskId && a.type == type);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _persist(
    SharedPreferences prefs,
    List<PendingAction> actions,
  ) async {
    final jsonList = actions.map((a) => a.toJson()).toList();
    await prefs.setString(_queueKey, jsonEncode(jsonList));
  }
}
