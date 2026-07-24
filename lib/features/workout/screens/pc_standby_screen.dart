import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../models/pc_session_model.dart';
import '../providers/pc_session_provider.dart';

/// Standby screen shown on Android while the PC app runs the exercise session.
///
/// Lifecycle:
///   connecting → paired → session_started → session_complete
///
/// Android stays here as the lifecycle anchor: if this screen is closed,
/// the PC is notified via the disconnect flow.
class PcStandbyScreen extends ConsumerStatefulWidget {
  final String workoutId;
  final String exerciseType;

  const PcStandbyScreen({
    super.key,
    required this.workoutId,
    required this.exerciseType,
  });

  @override
  ConsumerState<PcStandbyScreen> createState() => _PcStandbyScreenState();
}

class _PcStandbyScreenState extends ConsumerState<PcStandbyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(pcSessionProvider);

    ref.listen<PcSessionState>(pcSessionProvider, (_, next) {
      if (next.status == PcSessionStatus.sessionComplete && mounted) {
        // Session done — results are saved by PC via backend REST.
        // Navigate home so user can pull fresh workout data.
        context.go(AppRoutes.home);
      }
      if ((next.status == PcSessionStatus.sessionFailed ||
              next.status == PcSessionStatus.disconnected) &&
          mounted) {
        _showErrorAndPop(next.errorMessage ?? 'Session ended unexpectedly.');
      }
    });

    final isActive =
        session.status == PcSessionStatus.paired ||
        session.status == PcSessionStatus.sessionStarted;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final confirmed = await _confirmDisconnect();
          if (confirmed == true && context.mounted) {
            ref.read(pcSessionProvider.notifier).reset();
            context.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(),

                // Animated PC icon
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isActive ? _pulseAnim.value : 1.0,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.computer_rounded,
                      size: 58,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Status title
                Text(
                  _statusTitle(session.status),
                  style: GoogleFonts.lexend(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Status subtitle
                Text(
                  _statusSubtitle(session),
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Step progress list
                _StepList(status: session.status),

                const Spacer(),

                // Disconnect button
                GestureDetector(
                  onTap: () async {
                    final confirmed = await _confirmDisconnect();
                    if (confirmed == true && context.mounted) {
                      ref.read(pcSessionProvider.notifier).reset();
                      context.pop();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Disconnect from PC',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusTitle(PcSessionStatus status) => switch (status) {
    PcSessionStatus.connecting => 'Connecting to PC...',
    PcSessionStatus.paired => 'Connected to PC',
    PcSessionStatus.sessionStarted => 'Session in Progress',
    PcSessionStatus.sessionComplete => 'Session Complete!',
    PcSessionStatus.sessionFailed => 'Session Could Not Start',
    PcSessionStatus.disconnected => 'Disconnected',
    _ => 'Connecting...',
  };

  String _statusSubtitle(PcSessionState session) => switch (session.status) {
    PcSessionStatus.connecting => 'Establishing connection with your PC...',
    PcSessionStatus.paired => 'Waiting for PC to start the exercise session...',
    PcSessionStatus.sessionStarted =>
      'Exercise session is running on your PC.\nYou can monitor progress here.',
    PcSessionStatus.sessionComplete => 'Your workout data has been saved.',
    PcSessionStatus.sessionFailed || PcSessionStatus.disconnected =>
      session.errorMessage ??
          'We could not complete the exercise session. Please try again.',
    _ => '',
  };

  Future<bool?> _confirmDisconnect() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Disconnect from PC?',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will stop the active session on the PC.',
          style: GoogleFonts.lexend(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Disconnect', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showErrorAndPop(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.lexend()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && context.canPop()) context.pop();
    });
  }
}

class _StepList extends StatelessWidget {
  final PcSessionStatus status;
  const _StepList({required this.status});

  static const _steps = ['Paired', 'Session Started', 'Complete'];

  int get _currentIndex => switch (status) {
    PcSessionStatus.connecting => 0,
    PcSessionStatus.paired => 0,
    PcSessionStatus.sessionStarted => 1,
    PcSessionStatus.sessionComplete => 3, // all done
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_steps.length, (i) {
        final isDone = i < _currentIndex;
        final isCurrent = i == _currentIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? AppColors.primary
                      : isCurrent
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.15),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : isCurrent
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Text(
                          '${i + 1}',
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                _steps[i],
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  color: isDone || isCurrent
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
