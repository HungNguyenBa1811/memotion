import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/token_storage.dart';
import '../data/heartbeat_manager.dart';
import '../data/pc_pairing_service.dart';
import '../models/pc_session_model.dart';

class PcSessionState {
  final PcSessionStatus status;
  final String? sessionId;
  final String? errorMessage;
  final PcQrPayload? qrPayload;

  const PcSessionState({
    this.status = PcSessionStatus.idle,
    this.sessionId,
    this.errorMessage,
    this.qrPayload,
  });

  PcSessionState copyWith({
    PcSessionStatus? status,
    String? sessionId,
    String? errorMessage,
    PcQrPayload? qrPayload,
  }) {
    return PcSessionState(
      status: status ?? this.status,
      sessionId: sessionId ?? this.sessionId,
      errorMessage: errorMessage,
      qrPayload: qrPayload ?? this.qrPayload,
    );
  }
}

class PcSessionNotifier extends StateNotifier<PcSessionState> {
  final PcPairingService _service = PcPairingService.instance;
  late final HeartbeatManager _heartbeat;

  StreamSubscription<PcMessage>? _messageSub;
  StreamSubscription<bool>? _connSub;

  PcSessionNotifier() : super(const PcSessionState()) {
    _heartbeat = HeartbeatManager(
      onPing: () => _service.send(PcMessage.buildHeartbeatPing()),
      onTimeout: _onHeartbeatTimeout,
    );
  }

  /// Connects to PC via [payload.wsUrl], sends pair_request with JWT + workout config.
  Future<void> connectToPc(
    PcQrPayload payload, {
    required String workoutId,
    required String exerciseType,
  }) async {
    state = state.copyWith(
      status: PcSessionStatus.connecting,
      qrPayload: payload,
      errorMessage: null,
    );

    try {
      await _service.connect(payload.wsUrl);

      _messageSub = _service.messages.listen(_onMessage);
      _connSub = _service.connectionState.listen(_onConnectionChange);

      final jwt = await TokenStorage.instance.getAccessToken() ?? '';
      _service.send(PcMessage.buildPairRequest(
        jwt: jwt,
        workoutId: workoutId,
        exerciseType: exerciseType,
      ));
    } catch (e) {
      state = state.copyWith(
        status: PcSessionStatus.sessionFailed,
        errorMessage: 'Cannot connect to PC: $e',
      );
    }
  }

  /// Resets state and disconnects — call when user taps "Disconnect" or session ends.
  void reset() {
    _cleanupConnections();
    state = const PcSessionState();
  }

  // ── Private ──

  void _onMessage(PcMessage msg) {
    switch (msg.type) {
      case 'pair_confirmed':
        state = state.copyWith(status: PcSessionStatus.paired);
        _heartbeat.start();

      case 'session_started':
        final sid = msg.payload['session_id'] as String?;
        state = state.copyWith(
          status: PcSessionStatus.sessionStarted,
          sessionId: sid,
        );

      case 'session_complete':
        _heartbeat.stop();
        state = state.copyWith(status: PcSessionStatus.sessionComplete);

      case 'session_failed':
        _heartbeat.stop();
        state = state.copyWith(
          status: PcSessionStatus.sessionFailed,
          errorMessage:
              msg.payload['reason'] as String? ?? 'Session failed on PC',
        );

      case 'heartbeat_pong':
        _heartbeat.receivedPong();
    }
  }

  void _onConnectionChange(bool connected) {
    if (!connected &&
        state.status != PcSessionStatus.sessionComplete &&
        state.status != PcSessionStatus.idle) {
      _heartbeat.stop();
      state = state.copyWith(
        status: PcSessionStatus.disconnected,
        errorMessage: 'Lost connection to PC.',
      );
    }
  }

  void _onHeartbeatTimeout() {
    _cleanupConnections();
    state = state.copyWith(
      status: PcSessionStatus.disconnected,
      errorMessage: 'PC did not respond. Connection timed out.',
    );
  }

  void _cleanupConnections() {
    _heartbeat.stop();
    _messageSub?.cancel();
    _connSub?.cancel();
    _service.disconnect();
    _messageSub = null;
    _connSub = null;
  }

  @override
  void dispose() {
    _cleanupConnections();
    super.dispose();
  }
}

final pcSessionProvider =
    StateNotifierProvider<PcSessionNotifier, PcSessionState>((ref) {
  return PcSessionNotifier();
});
