import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ble_heart_rate_service.dart';
import 'health_connect_providers.dart';

// ── State ─────────────────────────────────────────────────────────────────

enum HrSource { ble, healthConnect, none }

class HrState {
  final int bpm;
  final HrSource source;
  final DateTime? lastUpdate;
  final BleHrStatus bleStatus;

  const HrState({
    this.bpm = 0,
    this.source = HrSource.none,
    this.lastUpdate,
    this.bleStatus = BleHrStatus.disconnected,
  });

  /// "Live" when BLE connected, "Synced X ago" when HC, "" when none.
  String get sourceLabel {
    switch (source) {
      case HrSource.ble:
        return 'Live';
      case HrSource.healthConnect:
        if (lastUpdate == null) return 'Synced';
        final diff = DateTime.now().difference(lastUpdate!);
        if (diff.inSeconds < 60) return 'Synced ${diff.inSeconds}s ago';
        return 'Synced ${diff.inMinutes}m ago';
      case HrSource.none:
        return '';
    }
  }

  bool get isLive => source == HrSource.ble && bleStatus == BleHrStatus.connected;

  HrState copyWith({
    int? bpm,
    HrSource? source,
    DateTime? lastUpdate,
    BleHrStatus? bleStatus,
  }) =>
      HrState(
        bpm: bpm ?? this.bpm,
        source: source ?? this.source,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        bleStatus: bleStatus ?? this.bleStatus,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────

class HeartRateNotifier extends StateNotifier<HrState> {
  HeartRateNotifier(this._ble, this._ref) : super(const HrState());

  final BleHeartRateService _ble;
  final Ref _ref;

  StreamSubscription<BleHrState>? _bleSub;
  Timer? _hcPollTimer;
  Timer? _labelRefreshTimer;

  // ── BLE ───────────────────────────────────────────────────────────────────

  /// Try auto-reconnect on app start (only if not already connecting/connected).
  Future<void> init() async {
    _listenBleStream();
    _startHcPolling(); // start HC immediately as baseline
    await _ble.reconnectSavedDevice();
  }


  void _listenBleStream() {
    _bleSub = _ble.stateStream.listen((bleState) {
      debugPrint('[HrNotifier] BLE state: ${bleState.status}, bpm: ${bleState.bpm}');

      if (bleState.status == BleHrStatus.connected) {
        // BLE active → stop HC polling
        _stopHcPolling();
        state = state.copyWith(
          bpm: bleState.bpm,
          source: HrSource.ble,
          lastUpdate: bleState.lastUpdate,
          bleStatus: BleHrStatus.connected,
        );
      } else if (bleState.status == BleHrStatus.disconnected) {
        // BLE lost → fallback to HC polling
        state = state.copyWith(
          bleStatus: BleHrStatus.disconnected,
          source: state.bpm > 0 ? HrSource.healthConnect : HrSource.none,
        );
        _startHcPolling();
      } else {
        // connecting / scanning / error
        state = state.copyWith(bleStatus: bleState.status);
      }
    });
  }

  Stream<BluetoothDevice> scanForDevices() => _ble.scanForHrDevices();
  Future<void> stopScan() => _ble.stopScan();
  Future<void> connectToDevice(BluetoothDevice device) => _ble.connectToDevice(device);
  Future<void> disconnectBle() => _ble.disconnect();

  // ── Health Connect fallback (5s poll) ────────────────────────────────────

  void _startHcPolling() {
    if (_hcPollTimer?.isActive == true) return;
    debugPrint('[HrNotifier] Starting HC polling (5s interval)');
    _fetchFromHc(); // immediate fetch
    _hcPollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchFromHc());

    // Refresh "Synced Xs ago" label every second
    _labelRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.source == HrSource.healthConnect) {
        state = state.copyWith(); // trigger rebuild
      }
    });
  }

  void _stopHcPolling() {
    _hcPollTimer?.cancel();
    _labelRefreshTimer?.cancel();
  }

  Future<void> _fetchFromHc() async {
    try {
      await _ref.read(healthDataProvider.notifier).fetch();
      final hcData = _ref.read(healthDataProvider).valueOrNull;
      if (hcData != null && hcData.heartRate > 0) {
        state = state.copyWith(
          bpm: hcData.heartRate,
          source: HrSource.healthConnect,
          lastUpdate: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('[HrNotifier] HC fetch error: $e');
    }
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _bleSub?.cancel();
    _stopHcPolling();
    _ble.dispose();
    super.dispose();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

final bleHeartRateServiceProvider = Provider<BleHeartRateService>(
  (ref) => BleHeartRateService(),
);

final heartRateProvider = StateNotifierProvider<HeartRateNotifier, HrState>((ref) {
  final notifier = HeartRateNotifier(
    ref.watch(bleHeartRateServiceProvider),
    ref,
  );
  notifier.init();
  return notifier;
});
