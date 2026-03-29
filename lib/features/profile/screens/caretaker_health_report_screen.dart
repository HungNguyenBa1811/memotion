import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../health_connect/models/health_data.dart';
import '../../health_connect/providers/health_connect_providers.dart';
import '../../health_connect/providers/heart_rate_provider.dart';

/// Health Report Screen for Caretaker (Figma design node 538:4727)
/// Displays progress indicator, today's health metrics (calories, steps, heart rate)
/// and a summary card with vitals
class CaretakerHealthReportScreen extends ConsumerStatefulWidget {
  const CaretakerHealthReportScreen({super.key});

  @override
  ConsumerState<CaretakerHealthReportScreen> createState() =>
      _CaretakerHealthReportScreenState();
}

class _CaretakerHealthReportScreenState
    extends ConsumerState<CaretakerHealthReportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(healthDataProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final healthAsync = ref.watch(healthDataProvider);
    final health = healthAsync.valueOrNull ?? const HealthData();
    final isLoading = healthAsync.isLoading;
    final hrState = ref.watch(heartRateProvider);
    final hPad = ResponsiveUtils.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.lightGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.contentMaxWidth(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context, isLoading),
                  const SizedBox(height: 16),
                  _buildProgressCard(padding: hPad),
                  const SizedBox(height: 24),
                  _buildTodaysInfoSection(health, hrState, padding: hPad),
                  const SizedBox(height: 24),
                  SizedBox(height: ResponsiveUtils.bottomNavPadding(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isLoading) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.horizontalPadding(context),
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF00695C),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          Row(
            children: [
              // BLE connect button
              GestureDetector(
                onTap: () => _showBleScanDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.bluetooth, color: AppColors.primary, size: 32),
                ),
              ),
              const SizedBox(width: 12),
              // Refresh HC button
              GestureDetector(
                onTap: isLoading
                    ? null
                    : () => ref.read(healthDataProvider.notifier).fetch(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.refresh, color: AppColors.primary, size: 32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({required double padding}) {
    final textScale = ResponsiveUtils.textScaleFactor(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFF1B4332), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.5),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            // Left side: Progress text
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with icon
                  Row(
                    children: [
                      Icon(
                        Icons.data_thresholding_outlined,
                        color: AppColors.primary,
                        size: 24 * textScale,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Progress',
                        style: GoogleFonts.lexend(
                          fontSize: 16 * textScale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Percentage
                  Text(
                    '95%',
                    style: GoogleFonts.lexend(
                      fontSize: 48 * textScale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Date
                  Text(
                    DateFormat('dd MMMM yyyy').format(DateTime.now()),
                    style: GoogleFonts.lexend(
                      fontSize: 16 * textScale,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Right side: Circular progress
            Expanded(
              flex: 4,
              child: SizedBox(
                width: 110 * textScale,
                height: 110 * textScale,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    SizedBox(
                      width: 110 * textScale,
                      height: 110 * textScale,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.grey.shade200,
                        ),
                      ),
                    ),
                    // Progress circle
                    SizedBox(
                      width: 110 * textScale,
                      height: 110 * textScale,
                      child: CircularProgressIndicator(
                        value: 0.9, // 9/10 = 90%
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // Center text
                    Text(
                      '9/10',
                      style: GoogleFonts.nunito(
                        fontSize: 24 * textScale,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysInfoSection(HealthData health, HrState hrState, {required double padding}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildCaloriesCard(health.calories.toInt().toString()),
                  const SizedBox(height: 12),
                  _buildStepsCard(health.steps.toString()),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHeartCard(hrState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesCard(String value) {
    final textScale = ResponsiveUtils.textScaleFactor(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFBFBFBF).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Text(
                'Calories',
                style: GoogleFonts.sourceSans3(
                  fontSize: 14 * textScale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF040415),
                ),
              ),
              const Spacer(),
              // Flame icon
              Icon(
                Icons.local_fire_department,
                color: Colors.green.shade300,
                size: 24 * textScale,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Value
          Text(
            value,
            style: GoogleFonts.sourceSans3(
              fontSize: 18 * textScale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF040415),
            ),
          ),
          const SizedBox(height: 4),
          // Unit
          Text(
            'Kcal',
            style: GoogleFonts.mavenPro(
              fontSize: 12 * textScale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7F7F7F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard(String value) {
    final textScale = ResponsiveUtils.textScaleFactor(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFBFBFBF).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Text(
                'Steps',
                style: GoogleFonts.sourceSans3(
                  fontSize: 14 * textScale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF040415),
                ),
              ),
              const Spacer(),
              // Shoe icon
              Icon(Icons.directions_run, color: Colors.blue.shade300, size: 24 * textScale),
            ],
          ),
          const SizedBox(height: 12),
          // Value
          Text(
            value,
            style: GoogleFonts.sourceSans3(
              fontSize: 18 * textScale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF040415),
            ),
          ),
          const SizedBox(height: 4),
          // Unit
          Text(
            'Steps',
            style: GoogleFonts.mavenPro(
              fontSize: 12 * textScale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7F7F7F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartCard(HrState hrState) {
    final textScale = ResponsiveUtils.textScaleFactor(context);
    final bpmText = hrState.bpm > 0 ? '${hrState.bpm}' : '--';
    final isLive = hrState.isLive;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFBFBFBF).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Text(
                'Heart',
                style: GoogleFonts.sourceSans3(
                  fontSize: 14 * textScale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF040415),
                ),
              ),
              const Spacer(),
              Icon(Icons.favorite, color: Colors.red.shade300, size: 24 * textScale),
            ],
          ),
          // Source indicator
          if (hrState.source != HrSource.none) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLive ? const Color(0xFF66BB6A) : const Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  hrState.sourceLabel,
                  style: GoogleFonts.mavenPro(
                    fontSize: 10 * textScale,
                    color: isLive ? const Color(0xFF66BB6A) : const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          // Chart area
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: _HeartRateChartPainter(),
            ),
          ),
          const SizedBox(height: 8),
          // Value
          Text(
            bpmText,
            style: GoogleFonts.sourceSans3(
              fontSize: 18 * textScale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF040415),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'bpm',
            style: GoogleFonts.mavenPro(
              fontSize: 12 * textScale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7F7F7F),
            ),
          ),
        ],
      ),
    );
  }

  void _showBleScanDialog(BuildContext context) {
    final hrNotifier = ref.read(heartRateProvider.notifier);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _BleScanSheet(notifier: hrNotifier),
    );
  }
}

/// Custom painter for heart rate chart wave
class _HeartRateChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.shade200
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.red.shade100.withOpacity(0.5),
          Colors.red.shade100.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // Start from left
    path.moveTo(0, size.height * 0.6);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height * 0.6);

    // Create wave pattern
    final points = <Offset>[
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.1, size.height * 0.55),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.45),
      Offset(size.width * 0.4, size.height * 0.3),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.35),
      Offset(size.width * 0.7, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.45),
      Offset(size.width * 0.9, size.height * 0.5),
      Offset(size.width, size.height * 0.55),
    ];

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
      fillPath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── BLE Scan Bottom Sheet ─────────────────────────────────────────────────

class _BleScanSheet extends ConsumerStatefulWidget {
  const _BleScanSheet({required this.notifier});
  final HeartRateNotifier notifier;

  @override
  ConsumerState<_BleScanSheet> createState() => _BleScanSheetState();
}

class _BleScanSheetState extends ConsumerState<_BleScanSheet> {
  final _devices = <BluetoothDevice>[];
  bool _scanning = false;
  StreamSubscription<BluetoothDevice>? _scanSub;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    widget.notifier.stopScan();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _devices.clear();
      _scanning = true;
    });
    _scanSub = widget.notifier.scanForDevices().listen(
      (device) {
        if (!_devices.any((d) => d.remoteId == device.remoteId)) {
          setState(() => _devices.add(device));
        }
      },
      onDone: () => setState(() => _scanning = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        32 + ResponsiveUtils.bottomNavPadding(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Connect Watch',
                style: GoogleFonts.lexend(
                  fontSize: 16, fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_scanning)
                const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _startScan,
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_devices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  _scanning ? 'Scanning for HR devices…' : 'No devices found.\nMake sure Memotion HR app is running on your watch.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _devices.length,
              separatorBuilder: (context, i) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final device = _devices[i];
                final name = device.platformName.isNotEmpty
                    ? device.platformName
                    : device.remoteId.str;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.watch, color: AppColors.primary),
                  title: Text(name, style: GoogleFonts.lexend(fontSize: 14)),
                  subtitle: Text(device.remoteId.str,
                      style: GoogleFonts.lexend(fontSize: 11, color: Colors.grey)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    widget.notifier.connectToDevice(device);
                    Navigator.pop(context);
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}