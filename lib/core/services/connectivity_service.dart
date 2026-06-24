import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps [Connectivity] from connectivity_plus.
///
/// Provides:
/// - [isOnline] — one-shot current status check.
/// - [onConnectivityChanged] — stream of booleans (true = online).
/// - [onConnectivityRestored] — filtered stream that only emits when the
///   device transitions from offline → online.
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Returns true if any non-none connectivity result is active right now.
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Stream of current online status. Emits on every change.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) => results.any((r) => r != ConnectivityResult.none),
    );
  }

  /// Stream that emits only when connectivity is restored (offline → online).
  ///
  /// Uses a captured boolean to track the previous state across events.
  Stream<bool> get onConnectivityRestored {
    bool lastWasOnline = true; // assume online until proven otherwise
    return onConnectivityChanged.where((isOnline) {
      final wasOffline = !lastWasOnline;
      lastWasOnline = isOnline;
      return isOnline && wasOffline;
    });
  }
}
