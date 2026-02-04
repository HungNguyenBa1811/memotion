import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/theme/theme.dart';
import '../providers/scan_medication_notifier.dart';
import '../models/medication_scan_dto.dart';

class MedicationScanScreen extends ConsumerStatefulWidget {
  const MedicationScanScreen({super.key});

  @override
  ConsumerState<MedicationScanScreen> createState() =>
      _MedicationScanScreenState();
}

class _MedicationScanScreenState extends ConsumerState<MedicationScanScreen>
    with WidgetsBindingObserver {
  bool _isScanning = false;
  MedicationDto? _scannedMedication;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      ref.read(scanMedicationNotifierProvider.notifier).reset();
    });
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _cameraController = null;
      if (mounted) {
        setState(() => _isCameraInitialized = false);
      }
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (!mounted) return;
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (!mounted) return;
        setState(() {
          _isCameraInitialized = true;
        });
      } else {
        setState(() {
          _cameraError = 'No camera found';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = 'Camera initialization error: $e';
      });
    }
  }

  Future<void> _startScanning() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() => _isScanning = true);

    try {
      final XFile image = await _cameraController!.takePicture();
      if (!mounted) return;
      final imageFile = File(image.path);

      await ref
          .read(scanMedicationNotifierProvider.notifier)
          .scanMedication(imageFile);
      if (!mounted) return;

      final scanState = ref.read(scanMedicationNotifierProvider);

      setState(() {
        _isScanning = false;
        _scannedMedication = scanState.scannedMedication;
      });

      if (scanState.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(scanState.errorMessage!)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Scan error: $e')));
    }
  }

  void _resetScan() {
    setState(() {
      _scannedMedication = null;
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

                    const SizedBox(height: 16),

                    // Capture button OR Back button after scan
                    _buildCaptureButton(),

                    const SizedBox(height: 16),

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
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
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

          // Camera preview area
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(29),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: _buildCameraPreview(),
              ),
            ),
          ),

          // Scanning overlay
          if (_isScanning)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(29),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        'Scanning...',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          color: Colors.white,
                        ),
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

  Widget _buildCameraPreview() {
    if (_cameraError != null) {
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.grey[600]),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _cameraError!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Initializing camera...',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CameraPreview(_cameraController!);
  }

  Widget _buildCaptureButton() {
    if (!_isCameraInitialized || _isScanning) {
      return const SizedBox.shrink();
    }

    // Show "Retake" button if we already have a result
    if (_scannedMedication != null) {
      return GestureDetector(
        onTap: _resetScan,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.primary, width: 4),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
            ],
          ),
          child: const Icon(Icons.refresh, color: AppColors.primary, size: 32),
        ),
      );
    }

    // Show capture button when no result yet
    return GestureDetector(
      onTap: _startScanning,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: AppColors.primary, width: 4),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
          ],
        ),
        child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 32),
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

  Widget _buildScannedMedicationCard(MedicationDto medication) {
    final pillImages = [
      'assets/images/medication/pill_1.png',
      'assets/images/medication/pill_2.png',
      'assets/images/medication/pill_3.png',
    ];
    final imageIndex = medication.medicationId.hashCode % pillImages.length;
    final hasApiImage = medication.imagePath.isNotEmpty;
    final fullImageUrl =
        hasApiImage ? '${ApiConstants.baseUrl}${medication.imagePath}' : null;

    return Container(
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image on left side
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: SizedBox(
                width: 86,
                height: 86,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: fullImageUrl != null
                      ? Image.network(
                          fullImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              pillImages[imageIndex],
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, err, st) {
                                return _buildIconPlaceholder();
                              },
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        )
                      : Image.asset(
                          pillImages[imageIndex],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildIconPlaceholder();
                          },
                        ),
                ),
              ),
            ),
          ),

          // Title and Description
          Positioned(
            left: 120,
            top: 15,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  medication.description,
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.medication,
        size: 40,
        color: AppColors.primary,
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