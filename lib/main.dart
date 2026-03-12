import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/medication/providers/medication_provider.dart';
import 'features/medication/screens/medication_alarm_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  await Health().configure();
  runApp(const ProviderScope(child: MemotionApp()));
}

class MemotionApp extends ConsumerStatefulWidget {
  const MemotionApp({super.key});

  @override
  ConsumerState<MemotionApp> createState() => _MemotionAppState();
}

class _MemotionAppState extends ConsumerState<MemotionApp> {
  StreamSubscription<AlarmSet>? _ringSub;
  StreamSubscription<bool>? _networkSub;

  @override
  void initState() {
    super.initState();
    // Alarm listener placed at root so it fires regardless of current route.
    _ringSub = Alarm.ringing.listen(_onAlarmRing);
    _requestAlarmPermissions();
    // Initial sync: fetch all tasks, cache, schedule alarms. Fire-and-forget.
    _syncMedications();
    // Auto-refresh when the device comes back online.
    _listenNetworkRestore();
  }

  Future<void> _syncMedications() async {
    final syncService = ref.read(medicationSyncServiceProvider);
    final result = await syncService.syncOnAppLaunch();
    if (mounted) {
      ref.read(medicationSyncStatusProvider.notifier).state = result;
    }
  }

  void _listenNetworkRestore() {
    final connectivity = ref.read(connectivityServiceProvider);
    _networkSub = connectivity.onConnectivityRestored.listen((_) async {
      final syncService = ref.read(medicationSyncServiceProvider);
      final result = await syncService.refreshCache();
      if (mounted) {
        ref.read(medicationSyncStatusProvider.notifier).state = result;
        // Invalidate so the medication list screen re-fetches live data.
        ref.invalidate(medicationsProvider);
      }
    });
  }

  /// Yêu cầu các quyền cần thiết cho alarm:
  /// - POST_NOTIFICATIONS: Android 13+ (API 33+) bắt buộc runtime request
  /// - SCHEDULE_EXACT_ALARM: Android 12+ (API 31+)
  Future<void> _requestAlarmPermissions() async {
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
  }

  @override
  void dispose() {
    _ringSub?.cancel();
    _networkSub?.cancel();
    super.dispose();
  }

  void _onAlarmRing(AlarmSet alarmSet) {
    if (alarmSet.alarms.isEmpty) return;
    final alarmId = alarmSet.alarms.first.id;
    rootNavigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => MedicationAlarmScreen(alarmId: alarmId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Memotion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
