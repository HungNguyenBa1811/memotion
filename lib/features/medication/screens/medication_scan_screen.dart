import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../providers/medication_provider.dart';
import '../models/medication.dart';

class MedicationScanScreen extends ConsumerStatefulWidget {
  const MedicationScanScreen({super.key});

  @override
  ConsumerState<MedicationScanScreen> createState() =>
      _MedicationScanScreenState();
}

class _MedicationScanScreenState extends ConsumerState<MedicationScanScreen> {
  bool _isScanning = false;
  Medication? _scannedMedication;

  @override
  void initState() {
    super.initState();
    // Simulate auto-scanning when screen opens
    _startScanning();
  }

  void _startScanning() async {
    setState(() => _isScanning = true);

    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 2));

    // Get scanned medication from provider
    final medication = await ref
        .read(medicationNotifierProvider.notifier)
        .scanMedication('fake_path');

    setState(() {
      _isScanning = false;
      _scannedMedication = medication;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Scanner area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Scanner frame
                    _buildScannerFrame(),

                    const SizedBox(height: 24),

                    // Scanned medication card
                    if (_scannedMedication != null)
                      _buildScannedMedicationCard(_scannedMedication!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          ),
          Text(
            'Scan Medication',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Stack(
            children: [
              const Icon(Icons.notifications_outlined, size: 24),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD87659),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScannerFrame() {
    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          // Corner brackets
          Positioned(
            top: 0,
            left: 0,
            child: _buildCornerBracket(CornerPosition.topLeft),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _buildCornerBracket(CornerPosition.topRight),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: _buildCornerBracket(CornerPosition.bottomLeft),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildCornerBracket(CornerPosition.bottomRight),
          ),

          // Scanner area (camera preview placeholder)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(29),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Center(
                child: _isScanning
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Scanning...',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Point camera at medication',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _startScanning,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Scan Again'),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBracket(CornerPosition position) {
    const bracketColor = Color(0xFFD87659);
    const size = 57.0;
    const thickness = 4.0;

    Widget bracket = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerBracketPainter(
          color: bracketColor,
          thickness: thickness,
          position: position,
        ),
      ),
    );

    return bracket;
  }

  Widget _buildScannedMedicationCard(Medication medication) {
    return Container(
      height: 147,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(70),
          topRight: Radius.circular(70),
          bottomLeft: Radius.circular(27),
          bottomRight: Radius.circular(27),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Medication image placeholder
          Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(27),
            ),
            child: const Icon(
              Icons.medication,
              size: 50,
              color: AppColors.primary,
            ),
          ),

          // Medication info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    medication.name,
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${medication.dosage} Capsules',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        medication.time,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF353535),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '|',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        medication.frequency,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: const Color(0xFF353535),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Detail button
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {
                // Navigate to medication detail or add to list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Medication added!')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(27),
                ),
                child: Text(
                  'Chi tiết',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

class _CornerBracketPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final CornerPosition position;

  _CornerBracketPainter({
    required this.color,
    required this.thickness,
    required this.position,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const radius = 15.0;

    switch (position) {
      case CornerPosition.topLeft:
        path.moveTo(0, size.height);
        path.lineTo(0, radius);
        path.quadraticBezierTo(0, 0, radius, 0);
        path.lineTo(size.width, 0);
        break;
      case CornerPosition.topRight:
        path.moveTo(0, 0);
        path.lineTo(size.width - radius, 0);
        path.quadraticBezierTo(size.width, 0, size.width, radius);
        path.lineTo(size.width, size.height);
        break;
      case CornerPosition.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, size.height - radius);
        path.quadraticBezierTo(0, size.height, radius, size.height);
        path.lineTo(size.width, size.height);
        break;
      case CornerPosition.bottomRight:
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height - radius);
        path.quadraticBezierTo(
          size.width,
          size.height,
          size.width - radius,
          size.height,
        );
        path.lineTo(0, size.height);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
