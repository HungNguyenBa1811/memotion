import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/sos_controller.dart';
import '../screens/sos_alert_views.dart';

class SosCoordinator extends ConsumerStatefulWidget {
  const SosCoordinator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SosCoordinator> createState() => _SosCoordinatorState();
}

class _SosCoordinatorState extends ConsumerState<SosCoordinator>
    with WidgetsBindingObserver {
  static const _notConfigured = Object();
  Object? _scheduledRole = _notConfigured;
  String? _configuredRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isForeground = state == AppLifecycleState.resumed;
    ref.read(sosControllerProvider.notifier).setForeground(isForeground);
  }

  void _scheduleRoleConfiguration(String? role) {
    if (_scheduledRole == role) return;
    _scheduledRole = role;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _configuredRole == role) return;
      _configuredRole = role;
      unawaited(ref.read(sosControllerProvider.notifier).configureRole(role));
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final role = authState.status == AuthStatus.authenticated
        ? authState.role?.toUpperCase()
        : null;
    _scheduleRoleConfiguration(role);

    final sosState = ref.watch(sosControllerProvider);
    final controller = ref.read(sosControllerProvider.notifier);
    final alert = sosState.alert;

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        if (sosState.display == SosDisplay.patientCountdown ||
            sosState.display == SosDisplay.patientNotified)
          Positioned.fill(
            child: PatientSosAlertView(
              isNotified: sosState.display == SosDisplay.patientNotified,
              remainingSeconds: sosState.remainingSeconds,
              isBusy: sosState.isBusy,
              isRetryingConnection: sosState.isRetryingConnection,
              alert: alert,
              errorMessage: sosState.errorMessage,
              onCancel: () => unawaited(controller.cancelPatientAlert()),
              onDismiss: controller.dismissPatientStatus,
            ),
          ),
        if (sosState.display == SosDisplay.patientBanner)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: PatientSosStatusBanner(
              alert: alert,
              isRetryingConnection: sosState.isRetryingConnection,
              onOpen: controller.showPatientStatus,
            ),
          ),
        if (sosState.display == SosDisplay.caregiverEmergency && alert != null)
          Positioned.fill(
            child: CaregiverSosAlertView(
              alert: alert,
              isBusy: sosState.isBusy,
              errorMessage: sosState.errorMessage,
              onCallEmergencyServices: _callEmergencyServices,
              onResolve: () => unawaited(controller.resolveCaregiverAlert()),
              onFalseAlarm: () => unawaited(controller.cancelCaregiverAlert()),
              onMinimize: controller.minimizeCaregiverAlert,
            ),
          ),
        if (sosState.display == SosDisplay.caregiverBanner && alert != null)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: CaregiverSosBanner(
              isBusy: sosState.isBusy,
              onOpen: () {
                controller.showCaregiverAlert();
              },
              onResolve: () => unawaited(controller.resolveCaregiverAlert()),
              onFalseAlarm: () => unawaited(controller.cancelCaregiverAlert()),
            ),
          ),
      ],
    );
  }

  Future<void> _callEmergencyServices() async {
    final uri = Uri(scheme: 'tel', path: '115');
    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) _showCallError();
    } catch (_) {
      if (mounted) _showCallError();
    }
  }

  void _showCallError() {
    final messengerContext = rootNavigatorKey.currentContext ?? context;
    ScaffoldMessenger.maybeOf(messengerContext)?.showSnackBar(
      const SnackBar(
        content: Text('This device could not open the phone dialer.'),
      ),
    );
  }
}
