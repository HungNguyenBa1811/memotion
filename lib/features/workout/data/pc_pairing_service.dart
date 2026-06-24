import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/pc_session_model.dart';

/// WebSocket client that connects to the PC's local WebSocket server.
///
/// Lifecycle:
/// 1. [connect] → opens a WS connection to PC's LAN address
/// 2. [send] → sends JSON messages (pair_request, heartbeat_ping, etc.)
/// 3. [disconnect] → closes the connection
///
/// Singleton so the active connection survives across screens.
class PcPairingService {
  static PcPairingService? _instance;
  static PcPairingService get instance {
    _instance ??= PcPairingService._();
    return _instance!;
  }
  PcPairingService._();

  WebSocketChannel? _channel;
  bool _isConnected = false;

  final _messageController = StreamController<PcMessage>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<PcMessage> get messages => _messageController.stream;
  Stream<bool> get connectionState => _connectionController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect(String wsUrl) async {
    debugPrint('[PcPairing] 🔌 Connecting to $wsUrl');
    developer.log('[PcPairing] Connecting to $wsUrl');
    await _closeChannel();

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _channel!.stream.listen(
      _onData,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: false,
    );
    _isConnected = true;
    _connectionController.add(true);
    debugPrint('[PcPairing] ✅ WebSocket connected');
    developer.log('[PcPairing] Connected');
  }

  void send(String message) {
    if (!_isConnected || _channel == null) {
      debugPrint('[PcPairing] ⚠️ send() called but not connected — dropped: $message');
      return;
    }
    debugPrint('[PcPairing] → SEND: $message');
    developer.log('[PcPairing] → $message');
    _channel!.sink.add(message);
  }

  Future<void> disconnect() async {
    await _closeChannel();
  }

  // ── Private ──

  void _onData(dynamic raw) {
    debugPrint('[PcPairing] ← RAW: $raw');
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      final msg = PcMessage.fromJson(json);
      debugPrint('[PcPairing] ← RECV type=${msg.type} payload=${msg.payload}');
      developer.log('[PcPairing] ← ${msg.type}');
      _messageController.add(msg);
    } catch (e) {
      debugPrint('[PcPairing] ❌ Parse error: $e | raw=$raw');
      developer.log('[PcPairing] Parse error: $e');
    }
  }

  void _onError(Object error) {
    debugPrint('[PcPairing] ❌ WS error: $error');
    developer.log('[PcPairing] WS error: $error');
    _isConnected = false;
    _connectionController.add(false);
  }

  void _onDone() {
    debugPrint('[PcPairing] 🔴 Connection closed (onDone)');
    developer.log('[PcPairing] Connection closed');
    _isConnected = false;
    _connectionController.add(false);
  }

  Future<void> _closeChannel() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }
    if (_isConnected) {
      _isConnected = false;
      _connectionController.add(false);
    }
  }

  void disposeService() {
    _closeChannel();
    _messageController.close();
    _connectionController.close();
    _instance = null;
  }
}
