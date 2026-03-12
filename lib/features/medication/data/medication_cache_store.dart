import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/medication_task.dart';

/// Metadata about the current medication cache snapshot.
class CacheMetadata {
  final DateTime cachedAt;
  final int taskCount;
  final String source; // 'api' | 'manual'
  final int version;

  const CacheMetadata({
    required this.cachedAt,
    required this.taskCount,
    required this.source,
    required this.version,
  });

  Map<String, dynamic> toJson() => {
    'cached_at': cachedAt.toIso8601String(),
    'task_count': taskCount,
    'source': source,
    'version': version,
  };

  factory CacheMetadata.fromJson(Map<String, dynamic> json) => CacheMetadata(
    cachedAt: DateTime.parse(json['cached_at'] as String),
    taskCount: json['task_count'] as int,
    source: json['source'] as String,
    version: (json['version'] as int?) ?? 0,
  );
}

/// Persists and restores the full list of medication tasks locally.
///
/// This store is the source of truth for offline alarm scheduling.
/// Data is stored as a JSON array in SharedPreferences with a TTL of 24 hours.
///
/// Bump [_currentVersion] whenever [MedicationTask] serialization changes
/// in a breaking way. On version mismatch the stale cache is automatically
/// cleared so the app fetches fresh data instead of crashing on bad JSON.
class MedicationCacheStore {
  static const _cacheKey = 'medication_all_tasks_cache';
  static const _metaKey = 'medication_cache_meta';
  static const defaultTtl = Duration(hours: 24);

  /// Increment this constant whenever the cached JSON schema changes in a
  /// breaking way (e.g. renamed/removed fields in [MedicationTask]).
  static const int _currentVersion = 1;

  /// Persist [tasks] to local storage. [source] indicates origin ('api' or 'manual').
  Future<void> persist(
    List<MedicationTask> tasks, {
    String source = 'api',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = tasks.map((t) => t.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(jsonList));
    final meta = CacheMetadata(
      cachedAt: DateTime.now(),
      taskCount: tasks.length,
      source: source,
      version: _currentVersion,
    );
    await prefs.setString(_metaKey, jsonEncode(meta.toJson()));
  }

  /// Restore cached tasks. Returns null if cache is absent, expired, or the
  /// stored version does not match [_currentVersion] (schema changed).
  ///
  /// On version mismatch the stale cache is automatically cleared so the next
  /// online sync can repopulate it with the new schema.
  Future<List<MedicationTask>?> restore({
    Duration maxAge = defaultTtl,
  }) async {
    final meta = await getMetadata();
    if (meta == null) return null;

    // Version mismatch — clear stale data and force a fresh API fetch.
    if (meta.version != _currentVersion) {
      await clear();
      return null;
    }

    if (DateTime.now().difference(meta.cachedAt) > maxAge) return null;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => MedicationTask.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Returns true when cached data exists and is within [maxAge].
  Future<bool> isValid({Duration maxAge = defaultTtl}) async {
    final meta = await getMetadata();
    if (meta == null) return false;
    return DateTime.now().difference(meta.cachedAt) <= maxAge;
  }

  /// Returns metadata for the current cache, or null if cache is absent.
  Future<CacheMetadata?> getMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_metaKey);
    if (raw == null) return null;
    try {
      return CacheMetadata.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Removes all cached data (call on logout or reset).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_metaKey);
  }
}
