import 'dart:async';

import 'package:flutter/foundation.dart';
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
    String? videoUrl,
  }) async {
    state = state.copyWith(
      status: PcSessionStatus.connecting,
      qrPayload: payload,
      errorMessage: null,
    );

    try {
      debugPrint('[PcSession] 🔌 Connecting to wsUrl=${payload.wsUrl}');
      await _service.connect(payload.wsUrl);

      _messageSub = _service.messages.listen(_onMessage);
      _connSub = _service.connectionState.listen(_onConnectionChange);

      final jwt = await TokenStorage.instance.getAccessToken() ?? '';
      debugPrint('[PcSession] 🔑 JWT ${jwt.isEmpty ? "EMPTY (unauthenticated!)" : "present (len=${jwt.length})"}');
      debugPrint('[PcSession] → pair_request workoutId=$workoutId exerciseType=$exerciseType videoUrl=$videoUrl');
      _service.send(PcMessage.buildPairRequest(
        jwt: jwt,
        workoutId: workoutId,
        exerciseType: exerciseType,
        videoUrl: videoUrl,
      ));
    } catch (e) {
      debugPrint('[PcSession] ❌ Connect failed: $e');
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
    debugPrint('[PcSession] ← msg type=${msg.type} payload=${msg.payload}');
    switch (msg.type) {
      case 'pair_confirmed':
        debugPrint('[PcSession] ✅ Paired! Starting heartbeat.');
        state = state.copyWith(status: PcSessionStatus.paired);
        _heartbeat.start();

      case 'session_started':
        final sid = msg.payload['session_id'] as String?;
        debugPrint('[PcSession] ▶️ Session started sessionId=$sid');
        state = state.copyWith(
          status: PcSessionStatus.sessionStarted,
          sessionId: sid,
        );

      case 'session_complete':
        debugPrint('[PcSession] 🏁 Session complete');
        _heartbeat.stop();
        state = state.copyWith(status: PcSessionStatus.sessionComplete);

      case 'session_failed':
        final reason = msg.payload['reason'] as String? ?? 'Session failed on PC';
        debugPrint('[PcSession] ❌ session_failed reason=$reason');
        _heartbeat.stop();
        state = state.copyWith(
          status: PcSessionStatus.sessionFailed,
          errorMessage: reason,
        );

      case 'heartbeat_pong':
        debugPrint('[PcSession] 💓 pong');
        _heartbeat.receivedPong();
    }
  }

  void _onConnectionChange(bool connected) {
    debugPrint('[PcSession] 🔗 connectionChange connected=$connected status=${state.status}');
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
    debugPrint('[PcSession] ⏱️ Heartbeat timeout');
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
