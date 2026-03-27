import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../models/pc_session_model.dart';
import '../providers/pc_session_provider.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  final String workoutId;
  final String exerciseType;

  const QrScanScreen({
    super.key,
    required this.workoutId,
    required this.exerciseType,
  });

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    setState(() => _isProcessing = true);
    _scannerController.stop();

    try {
      final payload = PcQrPayload.fromRawString(raw);

      if (payload.isExpired) {
        _showError('QR code has expired. Please generate a new one on your PC.');
        return;
      }

      ref.read(pcSessionProvider.notifier).connectToPc(
            payload,
            workoutId: widget.workoutId,
            exerciseType: widget.exerciseType,
          );

      if (mounted) {
        context.pushReplacement(
          AppRoutes.pcStandby,
          extra: {
            'workoutId': widget.workoutId,
            'exerciseType': widget.exerciseType,
          },
        );
      }
    } catch (_) {
      _showError('Invalid QR code. Make sure you scan the code from the PC app.');
    }
  }

  void _showError(String message) {
    setState(() => _isProcessing = false);
    _scannerController.start();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: GoogleFonts.lexend()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // Dark cutout overlay
          _ScanOverlay(scanSize: 260),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Scan PC QR Code',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay while connecting
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.65),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      'Connecting to PC...',
                      style: GoogleFonts.lexend(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Semi-transparent dark overlay with a transparent scan box in the centre.
class _ScanOverlay extends StatelessWidget {
  final double scanSize;
  const _ScanOverlay({required this.scanSize});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final left = (constraints.maxWidth - scanSize) / 2;
        final top = (constraints.maxHeight - scanSize) / 2;

        return Stack(
          children: [
            // Dark overlay with a transparent cutout for the QR scan area.
            // Uses PathFillType.evenOdd so the inner rect becomes a genuine
            // transparent hole — reliable on all platforms including PlatformViews.
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _ScanOverlayPainter(
                scanRect: RRect.fromRectAndRadius(
                  Rect.fromLTWH(left, top, scanSize, scanSize),
                  const Radius.circular(16),
                ),
                overlayColor: Colors.black.withOpacity(0.62),
              ),
            ),

            // Corner brackets around the scan box
            Positioned(
              left: left,
              top: top,
              child: _CornerBrackets(size: scanSize),
            ),

            // Instructions below the scan box
            Positioned(
              left: 0,
              right: 0,
              top: top + scanSize + 32,
              child: Column(
                children: [
                  Text(
                    'Point camera at the QR code\ndisplayed on your PC',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.45)),
                    ),
                    child: Text(
                      'Valid for 10 minutes',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  final RRect scanRect;
  final Color overlayColor;

  const _ScanOverlayPainter({required this.scanRect, required this.overlayColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(scanRect);
    canvas.drawPath(path, Paint()..color = overlayColor);
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter old) =>
      old.scanRect != scanRect || old.overlayColor != overlayColor;
}

/// Four L-shaped corner brackets drawn with CustomPaint.
class _CornerBrackets extends StatelessWidget {
  final double size;
  const _CornerBrackets({required this.size});

  @override
  Widget build(BuildContext context) {
    const c = 24.0; // corner arm length
    const s = 3.0; // stroke width
    final color = AppColors.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0,
              child: _Corner(color: color, stroke: s, arm: c, isTop: true, isLeft: true)),
          Positioned(top: 0, right: 0,
              child: _Corner(color: color, stroke: s, arm: c, isTop: true, isLeft: false)),
          Positioned(bottom: 0, left: 0,
              child: _Corner(color: color, stroke: s, arm: c, isTop: false, isLeft: true)),
          Positioned(bottom: 0, right: 0,
              child: _Corner(color: color, stroke: s, arm: c, isTop: false, isLeft: false)),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final double stroke;
  final double arm;
  final bool isTop;
  final bool isLeft;

  const _Corner({
    required this.color,
    required this.stroke,
    required this.arm,
    required this.isTop,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: arm,
      height: arm,
      child: CustomPaint(
        painter: _CornerPainter(
            color: color, strokeWidth: stroke, isTop: isTop, isLeft: isLeft),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool isTop;
  final bool isLeft;

  const _CornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.isTop,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}
