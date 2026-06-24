import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Standard BLE Heart Rate Service / Characteristic UUIDs
const _kHrServiceUuid = '0000180d-0000-1000-8000-00805f9b34fb';
const _kHrMeasurementUuid = '00002a37-0000-1000-8000-00805f9b34fb';
const _kSavedDeviceKey = 'ble_hr_device_id';

enum BleHrStatus { disconnected, scanning, connecting, connected, error }

class BleHrState {
  final int bpm;
  final BleHrStatus status;
  final String? deviceName;
  final DateTime? lastUpdate;

  const BleHrState({
    this.bpm = 0,
    this.status = BleHrStatus.disconnected,
    this.deviceName,
    this.lastUpdate,
  });

  BleHrState copyWith({
    int? bpm,
    BleHrStatus? status,
    String? deviceName,
    DateTime? lastUpdate,
  }) =>
      BleHrState(
        bpm: bpm ?? this.bpm,
        status: status ?? this.status,
        deviceName: deviceName ?? this.deviceName,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );
}

class BleHeartRateService {
  final _stateController = StreamController<BleHrState>.broadcast();
  Stream<BleHrState> get stateStream => _stateController.stream;

  BleHrState _state = const BleHrState();
  BleHrState get currentState => _state;

  BluetoothDevice? _device;
  StreamSubscription<List<int>>? _hrSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  void _emit(BleHrState next) {
    _state = next;
    _stateController.add(next);
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Scan for devices advertising HR Service UUID 0x180D.
  /// Returns a stream of discovered devices for the UI to display.
  Stream<BluetoothDevice> scanForHrDevices({Duration timeout = const Duration(seconds: 10)}) {
    _emit(_state.copyWith(status: BleHrStatus.scanning));

    final controller = StreamController<BluetoothDevice>.broadcast();
    final seen = <String>{};

    void emit(BluetoothDevice d) {
      if (seen.add(d.remoteId.str)) controller.add(d);
    }

    // 1. Emit bonded/system devices immediately (already paired at OS level)
    FlutterBluePlus.systemDevices([]).then((devices) {
      for (final d in devices) {
        debugPrint('[BLE] System device: ${d.platformName} ${d.remoteId}');
        emit(d);
      }
    });

    // 2. Scan all nearby devices (no service filter — Galaxy Watch may not
    //    advertise HR UUID until GATT connection is established)
    FlutterBluePlus.startScan(timeout: timeout);

    final sub = FlutterBluePlus.scanResults
        .expand((results) => results)
        .listen((r) => emit(r.device));

    FlutterBluePlus.isScanning.where((s) => !s).first.then((_) {
      sub.cancel();
      controller.close();
    });

    return controller.stream;
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    if (_state.status == BleHrStatus.scanning) {
      _emit(_state.copyWith(status: BleHrStatus.disconnected));
    }
  }

  /// Connect to a specific device and start streaming HR.
  Future<void> connectToDevice(BluetoothDevice device) async {
    await stopScan();
    _emit(_state.copyWith(
      status: BleHrStatus.connecting,
      deviceName: device.platformName,
    ));

    try {
      await device.connect(autoConnect: false, timeout: const Duration(seconds: 15));
      _device = device;

      // Save device ID for auto-reconnect
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSavedDeviceKey, device.remoteId.str);
      debugPrint('[BLE] Saved device: ${device.remoteId.str}');

      await _subscribeToHr(device);
      _listenConnectionState(device);
    } catch (e) {
      debugPrint('[BLE] Connect error: $e');
      _emit(_state.copyWith(status: BleHrStatus.error));
    }
  }

  /// Auto-reconnect to previously paired device (called on app start).
  Future<bool> reconnectSavedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_kSavedDeviceKey);
    if (savedId == null) return false;

    debugPrint('[BLE] Attempting auto-reconnect to $savedId');
    _emit(_state.copyWith(status: BleHrStatus.connecting));

    try {
      // Check if already connected
      final connected = FlutterBluePlus.connectedDevices;
      BluetoothDevice? device = connected.where((d) => d.remoteId.str == savedId).firstOrNull;

      if (device == null) {
        // Scan briefly to find the saved device
        final completer = Completer<BluetoothDevice?>();
        final sub = FlutterBluePlus.scanResults
            .expand((r) => r)
            .where((r) => r.device.remoteId.str == savedId)
            .map((r) => r.device)
            .listen((d) {
          if (!completer.isCompleted) completer.complete(d);
        });

        FlutterBluePlus.startScan(
          withServices: [Guid(_kHrServiceUuid)],
          timeout: const Duration(seconds: 8),
        );

        device = await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () => null,
        );
        await sub.cancel();
        await FlutterBluePlus.stopScan();
      }

      if (device == null) {
        debugPrint('[BLE] Saved device not found during auto-reconnect');
        _emit(_state.copyWith(status: BleHrStatus.disconnected));
        return false;
      }

      await connectToDevice(device);
      return true;
    } catch (e) {
      debugPrint('[BLE] Auto-reconnect error: $e');
      _emit(_state.copyWith(status: BleHrStatus.disconnected));
      return false;
    }
  }

  Future<void> disconnect() async {
    await _hrSubscription?.cancel();
    await _connectionSubscription?.cancel();
    await _device?.disconnect();
    _device = null;
    _emit(const BleHrState(status: BleHrStatus.disconnected));
  }

  Future<void> dispose() async {
    await disconnect();
    await _stateController.close();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _subscribeToHr(BluetoothDevice device) async {
    final services = await device.discoverServices();

    // Debug: print all discovered services
    debugPrint('[BLE] Discovered ${services.length} services:');
    for (final s in services) {
      debugPrint('[BLE]   service: ${s.uuid}');
      for (final c in s.characteristics) {
        debugPrint('[BLE]     char: ${c.uuid} props: ${c.properties}');
      }
    }

    final hrService = services.where((s) => s.uuid == Guid(_kHrServiceUuid)).firstOrNull;

    if (hrService == null) {
      debugPrint('[BLE] HR service not found on device');
      _emit(_state.copyWith(status: BleHrStatus.error));
      return;
    }

    final hrChar = hrService.characteristics
        .where((c) => c.uuid == Guid(_kHrMeasurementUuid))
        .firstOrNull;

    if (hrChar == null) {
      debugPrint('[BLE] HR measurement characteristic not found');
      _emit(_state.copyWith(status: BleHrStatus.error));
      return;
    }

    await hrChar.setNotifyValue(true);
    _emit(_state.copyWith(status: BleHrStatus.connected));
    debugPrint('[BLE] Subscribed to HR notifications');

    _hrSubscription = hrChar.lastValueStream.listen((data) {
      final bpm = _parseHrMeasurement(data);
      if (bpm > 0) {
        debugPrint('[BLE] HR: $bpm bpm');
        _emit(_state.copyWith(bpm: bpm, lastUpdate: DateTime.now()));
      }
    });
  }

  void _listenConnectionState(BluetoothDevice device) {
    _connectionSubscription = device.connectionState.listen((state) {
      debugPrint('[BLE] Connection state: $state');
      if (state == BluetoothConnectionState.disconnected) {
        _hrSubscription?.cancel();
        _emit(_state.copyWith(status: BleHrStatus.disconnected, bpm: 0));
      }
    });
  }

  /// Parse BLE Heart Rate Measurement characteristic (0x2A37).
  /// Byte 0 = flags. Bit 0: 0 = uint8 format, 1 = uint16 format.
  int _parseHrMeasurement(List<int> data) {
    if (data.isEmpty) return 0;
    final flags = data[0];
    final isUint16 = (flags & 0x01) != 0;
    if (data.length < 2) return 0;
    return isUint16
        ? ByteData.view(Uint8List.fromList(data.sublist(1, 3)).buffer).getUint16(0, Endian.little)
        : data[1];
  }
}
