import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive_utils.dart';
import '../models/sos_alert.dart';

class PatientSosAlertView extends StatelessWidget {
  const PatientSosAlertView({
    super.key,
    required this.isNotified,
    required this.remainingSeconds,
    required this.isBusy,
    required this.isRetryingConnection,
    required this.onCancel,
    required this.onDismiss,
    this.alert,
    this.errorMessage,
  });

  final bool isNotified;
  final int remainingSeconds;
  final bool isBusy;
  final bool isRetryingConnection;
  final SosAlert? alert;
  final String? errorMessage;
  final VoidCallback onCancel;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveUtils.textScaleFactor(context);
    final acknowledged = alert?.status == SosAlertStatus.acknowledged;
    final background = isNotified
        ? const Color(0xFF0D5D56)
        : const Color(0xFF9B2C20);

    return Material(
      color: background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.horizontalPadding(context),
            vertical: ResponsiveUtils.verticalPadding(context),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 112 * scale,
                    height: 112 * scale,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.55),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      isNotified
                          ? Icons.mark_email_read_outlined
                          : Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 64 * scale,
                    ),
                  ),
                  SizedBox(height: 28 * scale),
                  Semantics(
                    liveRegion: true,
                    label: isNotified
                        ? acknowledged
                              ? 'Your caregiver has seen the SOS alert.'
                              : 'Your caregiver has been notified.'
                        : 'SOS alert in $remainingSeconds seconds.',
                    child: Text(
                      isNotified
                          ? acknowledged
                                ? 'Your caregiver is responding'
                                : 'Your caregiver has been notified'
                          : 'We detected something unusual',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline1.copyWith(
                        color: Colors.white,
                        fontSize: 30 * scale,
                        height: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  if (!isNotified) ...[
                    Text(
                      'An SOS alert will be sent unless you cancel.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18 * scale,
                      ),
                    ),
                    SizedBox(height: 28 * scale),
                    Container(
                      width: 150 * scale,
                      height: 150 * scale,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.22),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Text(
                        '$remainingSeconds',
                        key: const Key('sos-countdown'),
                        style: AppTextStyles.headline1.copyWith(
                          color: background,
                          fontSize: 64 * scale,
                          height: 1,
                        ),
                      ),
                    ),
                  ] else
                    Text(
                      acknowledged
                          ? 'Help is being coordinated now. Stay somewhere safe and keep your phone nearby.'
                          : 'Stay somewhere safe and keep your phone nearby while your caregiver responds.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18 * scale,
                        height: 1.5,
                      ),
                    ),
                  if (isRetryingConnection) ...[
                    SizedBox(height: 24 * scale),
                    _StatusMessage(
                      icon: Icons.cloud_sync_outlined,
                      message:
                          'Connection interrupted. We will keep trying automatically.',
                    ),
                  ],
                  if (errorMessage != null) ...[
                    SizedBox(height: 16 * scale),
                    _StatusMessage(
                      icon: Icons.info_outline,
                      message: errorMessage!,
                    ),
                  ],
                  SizedBox(height: 36 * scale),
                  SizedBox(
                    width: double.infinity,
                    height: 60 * scale,
                    child: FilledButton.icon(
                      key: const Key('sos-cancel-button'),
                      onPressed: isBusy ? null : onCancel,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: background,
                        disabledBackgroundColor: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16 * scale),
                        ),
                      ),
                      icon: isBusy
                          ? SizedBox.square(
                              dimension: 22 * scale,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: background,
                              ),
                            )
                          : const Icon(Icons.cancel_outlined),
                      label: Text(
                        isNotified ? 'This was a false alarm' : 'Cancel SOS',
                        style: AppTextStyles.buttonLarge.copyWith(
                          color: background,
                          fontSize: 18 * scale,
                        ),
                      ),
                    ),
                  ),
                  if (isNotified) ...[
                    SizedBox(height: 12 * scale),
                    TextButton(
                      onPressed: isBusy ? null : onDismiss,
                      child: Text(
                        'Return to home',
                        style: AppTextStyles.buttonLarge.copyWith(
                          color: Colors.white,
                          fontSize: 16 * scale,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CaregiverSosAlertView extends StatelessWidget {
  const CaregiverSosAlertView({
    super.key,
    required this.alert,
    required this.isBusy,
    required this.onCallEmergencyServices,
    required this.onResolve,
    required this.onFalseAlarm,
    required this.onMinimize,
    this.errorMessage,
  });

  final SosAlert alert;
  final bool isBusy;
  final String? errorMessage;
  final VoidCallback onCallEmergencyServices;
  final VoidCallback onResolve;
  final VoidCallback onFalseAlarm;
  final VoidCallback onMinimize;

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveUtils.textScaleFactor(context);
    final time = alert.createdAt == null
        ? 'Just now'
        : DateFormat.jm().format(alert.createdAt!.toLocal());

    return Material(
      color: const Color(0xFF8F1D18),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.horizontalPadding(context),
            vertical: ResponsiveUtils.verticalPadding(context),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  SizedBox(height: 32 * scale),
                  Icon(
                    Icons.sos_rounded,
                    color: Colors.white,
                    size: 104 * scale,
                    semanticLabel: 'SOS emergency alert',
                  ),
                  SizedBox(height: 20 * scale),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      'Your care recipient needs help',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline1.copyWith(
                        color: Colors.white,
                        fontSize: 34 * scale,
                        height: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Text(
                    'SOS triggered at $time',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18 * scale,
                    ),
                  ),
                  SizedBox(height: 28 * scale),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18 * scale),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Text(
                      'Check on them now. Call emergency services if there may be immediate danger.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontSize: 17 * scale,
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    SizedBox(height: 16 * scale),
                    _StatusMessage(
                      icon: Icons.info_outline,
                      message: errorMessage!,
                    ),
                  ],
                  SizedBox(height: 28 * scale),
                  SizedBox(
                    width: double.infinity,
                    height: 58 * scale,
                    child: FilledButton.icon(
                      onPressed: isBusy ? null : onCallEmergencyServices,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF8F1D18),
                      ),
                      icon: const Icon(Icons.phone_in_talk_outlined),
                      label: Text(
                        'Call emergency services (115)',
                        style: AppTextStyles.buttonLarge.copyWith(
                          color: const Color(0xFF8F1D18),
                          fontSize: 17 * scale,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  SizedBox(
                    width: double.infinity,
                    height: 58 * scale,
                    child: FilledButton.icon(
                      key: const Key('sos-resolve-button'),
                      onPressed: isBusy ? null : onResolve,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                      icon: isBusy
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        'Resolved',
                        style: AppTextStyles.buttonLarge.copyWith(
                          fontSize: 17 * scale,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  SizedBox(
                    width: double.infinity,
                    height: 56 * scale,
                    child: OutlinedButton.icon(
                      key: const Key('sos-false-alarm-button'),
                      onPressed: isBusy ? null : onFalseAlarm,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      icon: const Icon(Icons.notifications_off_outlined),
                      label: Text(
                        'False alarm',
                        style: AppTextStyles.buttonLarge.copyWith(
                          fontSize: 16 * scale,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  TextButton(
                    onPressed: isBusy ? null : onMinimize,
                    child: Text(
                      'Continue handling in the app',
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: Colors.white,
                        fontSize: 15 * scale,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PatientSosStatusBanner extends StatelessWidget {
  const PatientSosStatusBanner({
    super.key,
    required this.alert,
    required this.isRetryingConnection,
    required this.onOpen,
  });

  final SosAlert? alert;
  final bool isRetryingConnection;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final acknowledged = alert?.status == SosAlertStatus.acknowledged;
    final isSending = alert == null || isRetryingConnection;
    final title = isSending
        ? 'Sending your SOS alert'
        : acknowledged
        ? 'Your caregiver is responding'
        : 'Your caregiver has been notified';
    final message = isSending
        ? 'Connection interrupted. We will keep trying automatically.'
        : acknowledged
        ? 'They have seen the alert and are coordinating help.'
        : 'Keep your phone nearby while they respond.';
    final background = isSending
        ? const Color(0xFF9B5D12)
        : const Color(0xFF0D5D56);

    return SafeArea(
      minimum: const EdgeInsets.all(12),
      child: Material(
        color: background,
        elevation: 12,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: const Key('patient-sos-status-banner'),
          onTap: onOpen,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isSending
                      ? Icons.cloud_sync_outlined
                      : acknowledged
                      ? Icons.volunteer_activism_outlined
                      : Icons.mark_email_read_outlined,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.headline3.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CaregiverSosBanner extends StatelessWidget {
  const CaregiverSosBanner({
    super.key,
    required this.isBusy,
    required this.onOpen,
    required this.onResolve,
    required this.onFalseAlarm,
  });

  final bool isBusy;
  final VoidCallback onOpen;
  final VoidCallback onResolve;
  final VoidCallback onFalseAlarm;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(12),
      child: Material(
        color: const Color(0xFF8F1D18),
        elevation: 12,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.sos_rounded, color: Colors.white, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: onOpen,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Responding to your care recipient’s SOS',
                      style: AppTextStyles.headline3.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Mark resolved',
                onPressed: isBusy ? null : onResolve,
                color: Colors.white,
                icon: const Icon(Icons.check_circle_outline),
              ),
              IconButton(
                tooltip: 'Mark as false alarm',
                onPressed: isBusy ? null : onFalseAlarm,
                color: Colors.white,
                icon: const Icon(Icons.notifications_off_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
