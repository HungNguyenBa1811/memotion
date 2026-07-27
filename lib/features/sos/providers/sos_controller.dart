import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../data/sos_api_service.dart';
import '../data/sos_repository.dart';
import '../models/sos_alert.dart';
import 'sos_effects.dart';

enum SosDisplay {
  none,
  patientCountdown,
  patientNotified,
  patientBanner,
  caregiverEmergency,
  caregiverBanner,
}

const _unchanged = Object();

class SosState {
  const SosState({
    this.display = SosDisplay.none,
    this.alert,
    this.remainingSeconds = 0,
    this.isBusy = false,
    this.isRetryingConnection = false,
    this.errorMessage,
  });

  final SosDisplay display;
  final SosAlert? alert;
  final int remainingSeconds;
  final bool isBusy;
  final bool isRetryingConnection;
  final String? errorMessage;

  SosState copyWith({
    SosDisplay? display,
    Object? alert = _unchanged,
    int? remainingSeconds,
    bool? isBusy,
    bool? isRetryingConnection,
    Object? errorMessage = _unchanged,
  }) {
    return SosState(
      display: display ?? this.display,
      alert: identical(alert, _unchanged) ? this.alert : alert as SosAlert?,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isBusy: isBusy ?? this.isBusy,
      isRetryingConnection: isRetryingConnection ?? this.isRetryingConnection,
      errorMessage: identical(errorMessage, _unchanged)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

final sosApiServiceProvider = Provider<SosApiService>((ref) {
  return SosApiService();
});

final sosRepositoryProvider = Provider<SosRepository>((ref) {
  return ApiSosRepository(ref.watch(sosApiServiceProvider));
});

final sosEffectsProvider = Provider<SosEffects>((ref) {
  final effects = DeviceSosEffects();
  ref.onDispose(() {
    unawaited(effects.dispose());
  });
  return effects;
});

final sosControllerProvider = StateNotifierProvider<SosController, SosState>((
  ref,
) {
  return SosController(
    ref.watch(sosRepositoryProvider),
    ref.watch(sosEffectsProvider),
  );
});

class SosController extends StateNotifier<SosState> {
  SosController(
    this._repository,
    this._effects, {
    this.pollInterval = const Duration(seconds: 5),
    this.retryInterval = const Duration(seconds: 2),
  }) : super(const SosState());

  final SosRepository _repository;
  final SosEffects _effects;
  final Duration pollInterval;
  final Duration retryInterval;

  String _role = '';
  bool _isForeground = true;
  bool _triggerInFlight = false;
  bool _acknowledgeInFlight = false;
  bool _patientTriggerPending = false;
  bool _patientCancelRequested = false;
  bool _patientStatusMinimized = false;
  int _pollFailureCount = 0;
  int _stateVersion = 0;
  int _pollSequence = 0;
  int? _activePollId;
  String? _announcedCaregiverAlertId;
  DateTime? _localDeadline;
  Timer? _countdownTimer;
  Timer? _pollTimer;
  Timer? _retryTimer;

  bool get _isPatient => _role == 'PATIENT';
  bool get _isCaregiver => _role == 'CARETAKER' || _role == 'CAREGIVER';

  Future<void> configureRole(String? role) async {
    final normalized = role?.trim().toUpperCase() ?? '';
    if (_role == normalized) return;

    _stateVersion++;
    _role = normalized;
    _activePollId = null;
    _cancelTimers();
    _resetLocalFlags();
    state = const SosState();
    await _effects.stop();

    if (_isPatient || _isCaregiver) {
      await _refreshActive();
    }
  }

  void setForeground(bool isForeground) {
    if (_isForeground == isForeground) return;
    _isForeground = isForeground;

    // Timers (countdown, trigger retry, caregiver polling) keep running in
    // the background so an SOS is never missed while the process is alive.
    if (!isForeground) return;

    unawaited(_resumeFromForeground());
  }

  Future<void> _resumeFromForeground() async {
    if (!_isPatient && !_isCaregiver) return;
    await _refreshActive();
    if (_isPatient && _patientTriggerPending && _localDeadline == null) {
      _scheduleTriggerRetry();
    }
  }

  Future<void> triggerPatientAlert() async {
    if (!_isPatient || !_isForeground || state.isBusy) return;
    if (state.display == SosDisplay.patientCountdown) return;

    _patientCancelRequested = false;
    _patientStatusMinimized = false;
    _patientTriggerPending = true;
    _stateVersion++;
    _localDeadline = clock.now().add(const Duration(seconds: 10));
    state = state.copyWith(
      display: SosDisplay.patientCountdown,
      alert: null,
      remainingSeconds: 10,
      isBusy: false,
      isRetryingConnection: false,
      errorMessage: null,
    );
    // The countdown is fully local: the trigger request is only sent once the
    // 10 seconds elapse without a cancel (see _updateCountdown).
    _startCountdown();
  }

  Future<void> _attemptTrigger() async {
    if (_triggerInFlight || !_patientTriggerPending) return;
    // Never send before the local countdown has finished.
    if (_secondsUntilDeadline() > 0) return;
    _triggerInFlight = true;
    final requestVersion = _stateVersion;

    try {
      // countdown_seconds: 0 -> the server activates the alert immediately;
      // the cancel window already happened on-device.
      final result = await _repository.trigger(
        triggerSource: 'HIDDEN_BUTTON',
        message: 'Triggered from the hidden home-screen bell gesture',
        countdownSeconds: 0,
      );

      if (_patientCancelRequested) {
        await _cancelLateTrigger(result.alert);
        return;
      }
      if (requestVersion != _stateVersion || !_isPatient) return;

      _patientTriggerPending = false;
      _retryTimer?.cancel();
      _handlePatientAlert(result.alert);
    } catch (error) {
      if (_patientCancelRequested ||
          requestVersion != _stateVersion ||
          !_isPatient) {
        return;
      }
      state = state.copyWith(
        isBusy: false,
        isRetryingConnection: true,
        errorMessage:
            'Connection interrupted. We will keep trying to send the alert.',
      );
      _scheduleTriggerRetry();
      debugPrint('[SOS] Trigger failed; retry scheduled: $error');
    } finally {
      _triggerInFlight = false;
    }
  }

  void _handlePatientAlert(SosAlert alert) {
    if (alert.status == SosAlertStatus.pending && alert.remainingSeconds > 0) {
      _localDeadline = clock.now().add(
        Duration(seconds: alert.remainingSeconds),
      );
      state = state.copyWith(
        display: SosDisplay.patientCountdown,
        alert: alert,
        remainingSeconds: alert.remainingSeconds,
        isBusy: false,
        isRetryingConnection: false,
        errorMessage: null,
      );
      _startCountdown();
      return;
    }

    if (alert.needsSupport ||
        (alert.status == SosAlertStatus.pending &&
            alert.remainingSeconds <= 0)) {
      _countdownTimer?.cancel();
      _localDeadline = null;
      final activeAlert = alert.status == SosAlertStatus.pending
          ? alert.copyWith(status: SosAlertStatus.active, remainingSeconds: 0)
          : alert;
      state = state.copyWith(
        display: _patientStatusMinimized
            ? SosDisplay.patientBanner
            : SosDisplay.patientNotified,
        alert: activeAlert,
        remainingSeconds: 0,
        isBusy: false,
        isRetryingConnection: false,
        errorMessage: null,
      );
      unawaited(_effects.stop());
      _schedulePoll(failed: false);
      return;
    }

    _clearAlert();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final remaining = _secondsUntilDeadline();
    if (remaining > 0) {
      if (state.remainingSeconds != remaining) {
        state = state.copyWith(remainingSeconds: remaining);
      }
      return;
    }

    _countdownTimer?.cancel();
    _localDeadline = null;
    final localAlert = state.alert?.copyWith(
      status: SosAlertStatus.active,
      remainingSeconds: 0,
    );
    state = state.copyWith(
      display: _patientStatusMinimized
          ? SosDisplay.patientBanner
          : SosDisplay.patientNotified,
      alert: localAlert,
      remainingSeconds: 0,
      isBusy: false,
    );
    unawaited(_effects.stop());
    if (_patientTriggerPending) {
      // Countdown finished without a cancel: send the SOS request now.
      unawaited(_attemptTrigger());
    } else {
      // Countdown restored from a server-side PENDING alert: the server
      // promotes it itself, so just refresh the status.
      unawaited(_refreshActive());
    }
  }

  int _secondsUntilDeadline() {
    final deadline = _localDeadline;
    if (deadline == null) return 0;
    final milliseconds = deadline.difference(clock.now()).inMilliseconds;
    if (milliseconds <= 0) return 0;
    return (milliseconds + 999) ~/ 1000;
  }

  void _scheduleTriggerRetry() {
    _retryTimer?.cancel();
    if (!_patientTriggerPending || _patientCancelRequested) {
      return;
    }
    _retryTimer = Timer(retryInterval, () {
      unawaited(_attemptTrigger());
    });
  }

  Future<void> cancelPatientAlert() async {
    if (!_isPatient || state.isBusy) return;
    _patientCancelRequested = true;
    _patientTriggerPending = false;
    _stateVersion++;
    _countdownTimer?.cancel();
    _retryTimer?.cancel();
    state = state.copyWith(isBusy: true, errorMessage: null);

    final alert = state.alert;
    if (alert == null) {
      state = const SosState();
      await _effects.stop();
      unawaited(_cancelAnyServerAlert());
      return;
    }

    try {
      await _repository.cancel(alert.id);
      _clearAlert();
    } catch (error) {
      if (_isTerminalActionError(error)) {
        _clearAlert();
        return;
      }
      _patientCancelRequested = false;
      state = state.copyWith(
        isBusy: false,
        errorMessage:
            'We could not cancel the alert yet. Check your connection and try again.',
      );
      if (state.display == SosDisplay.patientCountdown) _startCountdown();
    }
  }

  Future<void> _cancelLateTrigger(SosAlert alert) async {
    try {
      if (alert.isOpen) await _repository.cancel(alert.id);
    } catch (error) {
      debugPrint('[SOS] Late trigger cancellation failed: $error');
    }
  }

  Future<void> _cancelAnyServerAlert() async {
    try {
      final active = await _repository.getActive();
      if (active.alert?.isOpen == true) {
        await _repository.cancel(active.alert!.id);
      }
    } catch (error) {
      debugPrint(
        '[SOS] Could not verify a late trigger after cancellation: $error',
      );
    }
  }

  void dismissPatientStatus() {
    if (!_isPatient || state.display != SosDisplay.patientNotified) return;
    _patientStatusMinimized = true;
    state = state.copyWith(
      display: SosDisplay.patientBanner,
      errorMessage: null,
    );
  }

  void showPatientStatus() {
    if (!_isPatient || state.display != SosDisplay.patientBanner) return;
    _patientStatusMinimized = false;
    state = state.copyWith(
      display: SosDisplay.patientNotified,
      errorMessage: null,
    );
  }

  Future<void> _refreshActive() async {
    if (_activePollId != null || (!_isPatient && !_isCaregiver)) {
      return;
    }
    final pollId = ++_pollSequence;
    final requestVersion = _stateVersion;
    _activePollId = pollId;
    _pollTimer?.cancel();

    var failed = false;
    try {
      final result = await _repository.getActive();
      if (requestVersion != _stateVersion) return;
      _pollFailureCount = 0;
      if (_isPatient) {
        _handlePatientActiveResult(result);
      } else {
        _handleCaregiverActiveResult(result);
      }
    } catch (error) {
      if (requestVersion != _stateVersion) return;
      failed = true;
      _pollFailureCount++;
      if (state.display != SosDisplay.none) {
        state = state.copyWith(
          errorMessage:
              'Live SOS status is temporarily unavailable. Retrying automatically.',
        );
      }
      debugPrint('[SOS] Active alert poll failed: $error');
    } finally {
      if (_activePollId == pollId) {
        _activePollId = null;
        _schedulePoll(failed: failed);
      }
    }
  }

  void _handlePatientActiveResult(SosActiveResult result) {
    final alert = result.alert;
    if (alert == null) {
      if (!_patientTriggerPending) _clearAlert();
      return;
    }
    _patientTriggerPending = false;
    _handlePatientAlert(alert);
  }

  void _handleCaregiverActiveResult(SosActiveResult result) {
    final alert = result.alert;
    if (!result.needsSupport || alert == null) {
      _announcedCaregiverAlertId = null;
      _clearAlert();
      return;
    }

    if (alert.status == SosAlertStatus.active) {
      final isNewAlert = _announcedCaregiverAlertId != alert.id;
      if (isNewAlert) {
        _announcedCaregiverAlertId = alert.id;
        state = state.copyWith(
          display: SosDisplay.caregiverEmergency,
          alert: alert,
          remainingSeconds: 0,
          isBusy: false,
          errorMessage: null,
        );
        unawaited(_effects.playCaregiverAlarm());
        unawaited(_acknowledge(alert));
      } else {
        state = state.copyWith(alert: alert, errorMessage: null);
      }
      return;
    }

    if (alert.status == SosAlertStatus.acknowledged) {
      final keepEmergency =
          state.display == SosDisplay.caregiverEmergency &&
          state.alert?.id == alert.id;
      state = state.copyWith(
        display: keepEmergency
            ? SosDisplay.caregiverEmergency
            : SosDisplay.caregiverBanner,
        alert: alert,
        isBusy: false,
        errorMessage: null,
      );
      return;
    }

    _clearAlert();
  }

  Future<void> _acknowledge(SosAlert alert) async {
    if (_acknowledgeInFlight) return;
    _acknowledgeInFlight = true;
    try {
      final acknowledged = await _repository.acknowledge(alert.id);
      if (state.alert?.id == acknowledged.id) {
        state = state.copyWith(alert: acknowledged, errorMessage: null);
      }
    } catch (error) {
      state = state.copyWith(
        errorMessage:
            'The alert is visible, but acknowledgement could not be sent yet.',
      );
      debugPrint('[SOS] Acknowledgement failed: $error');
    } finally {
      _acknowledgeInFlight = false;
    }
  }

  void minimizeCaregiverAlert() {
    if (!_isCaregiver || state.alert == null) return;
    unawaited(_effects.stop());
    state = state.copyWith(
      display: SosDisplay.caregiverBanner,
      errorMessage: null,
    );
  }

  void showCaregiverAlert() {
    if (!_isCaregiver || state.alert == null) return;
    state = state.copyWith(
      display: SosDisplay.caregiverEmergency,
      errorMessage: null,
    );
  }

  Future<void> resolveCaregiverAlert() => _finishCaregiverAlert(
    (id) => _repository.resolve(id),
    failureMessage:
        'We could not mark this alert as resolved. Please try again.',
  );

  Future<void> cancelCaregiverAlert() => _finishCaregiverAlert(
    (id) => _repository.cancel(id),
    failureMessage:
        'We could not mark this as a false alarm. Please try again.',
  );

  Future<void> _finishCaregiverAlert(
    Future<SosAlert> Function(String id) action, {
    required String failureMessage,
  }) async {
    if (!_isCaregiver || state.alert == null || state.isBusy) return;
    final alertId = state.alert!.id;
    _stateVersion++;
    state = state.copyWith(isBusy: true, errorMessage: null);
    try {
      await action(alertId);
      _announcedCaregiverAlertId = null;
      _clearAlert();
      _schedulePoll(failed: false);
    } catch (error) {
      if (_isTerminalActionError(error)) {
        _clearAlert();
        _schedulePoll(failed: false);
        return;
      }
      state = state.copyWith(isBusy: false, errorMessage: failureMessage);
    }
  }

  bool _isTerminalActionError(Object error) {
    return error is ApiException &&
        (error.statusCode == 400 || error.statusCode == 404);
  }

  bool get _shouldPoll {
    if (_isCaregiver) return true;
    if (!_isPatient) return false;
    return state.alert?.needsSupport == true ||
        state.display == SosDisplay.patientNotified ||
        state.display == SosDisplay.patientBanner;
  }

  void _schedulePoll({required bool failed}) {
    _pollTimer?.cancel();
    if (!_shouldPoll) return;
    final delay = failed ? _backoffDelay() : pollInterval;
    _pollTimer = Timer(delay, () => unawaited(_refreshActive()));
  }

  Duration _backoffDelay() {
    const seconds = [5, 10, 20, 30];
    final index = (_pollFailureCount - 1).clamp(0, seconds.length - 1).toInt();
    return Duration(seconds: seconds[index]);
  }

  void _clearAlert() {
    _countdownTimer?.cancel();
    _retryTimer?.cancel();
    _localDeadline = null;
    _patientTriggerPending = false;
    _patientCancelRequested = false;
    _patientStatusMinimized = false;
    state = const SosState();
    unawaited(_effects.stop());
  }

  void _resetLocalFlags() {
    _activePollId = null;
    _triggerInFlight = false;
    _acknowledgeInFlight = false;
    _patientTriggerPending = false;
    _patientCancelRequested = false;
    _patientStatusMinimized = false;
    _pollFailureCount = 0;
    _announcedCaregiverAlertId = null;
    _localDeadline = null;
  }

  void _cancelTimers() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    _retryTimer?.cancel();
    _countdownTimer = null;
    _pollTimer = null;
    _retryTimer = null;
  }

  @override
  void dispose() {
    _cancelTimers();
    unawaited(_effects.stop());
    super.dispose();
  }
}
