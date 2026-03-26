import 'dart:async';

/// Manages the ping/pong heartbeat between Android and the PC app.
///
/// - Sends [onPing] every [pingInterval] (default 5 s).
/// - Calls [onTimeout] if no pong is received within [timeout] (default 15 s).
///   Per spec: 3 missed pings → timeout (5 s × 3 = 15 s).
///
/// Usage:
/// ```dart
/// final hb = HeartbeatManager(
///   onPing: () => service.send(PcMessage.buildHeartbeatPing()),
///   onTimeout: () => handleDisconnect(),
/// );
/// hb.start();
/// // on pong received:
/// hb.receivedPong();
/// // on session end:
/// hb.stop();
/// ```
class HeartbeatManager {
  final Duration pingInterval;
  final Duration timeout;
  final void Function() onPing;
  final void Function() onTimeout;

  Timer? _pingTimer;
  Timer? _timeoutTimer;
  bool _active = false;

  HeartbeatManager({
    this.pingInterval = const Duration(seconds: 5),
    this.timeout = const Duration(seconds: 15),
    required this.onPing,
    required this.onTimeout,
  });

  void start() {
    stop();
    _active = true;
    _pingTimer = Timer.periodic(pingInterval, (_) {
      if (_active) onPing();
    });
    _resetTimeout();
  }

  /// Call when a heartbeat_pong message is received from PC.
  void receivedPong() {
    if (_active) _resetTimeout();
  }

  void stop() {
    _active = false;
    _pingTimer?.cancel();
    _timeoutTimer?.cancel();
    _pingTimer = null;
    _timeoutTimer = null;
  }

  void _resetTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(timeout, () {
      if (_active) onTimeout();
    });
  }
}
