import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/onboarding_data.dart';
import '../../providers/onboarding_notifier.dart';

class Step16Builder extends ConsumerStatefulWidget {
  final VoidCallback? onNext;

  const Step16Builder({super.key, this.onNext});

  @override
  ConsumerState<Step16Builder> createState() => _Step16BuilderState();
}

class _Step16BuilderState extends ConsumerState<Step16Builder> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _capturedImages = [];
  bool _isScanning = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => _capturedImages.add(File(picked.path)));
      await _submitScan();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'We could not open that photo. Please check photo access and try again.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _submitScan() async {
    if (_capturedImages.isEmpty) return;
    setState(() => _isScanning = true);

    final success = await ref
        .read(onboardingNotifierProvider.notifier)
        .scanMedicalRecord(_capturedImages);

    if (!mounted) return;
    setState(() => _isScanning = false);

    if (success) {
      widget.onNext?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'We could not read the medical document. Please use a clear photo and try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = const OnboardingStep16Config();
    final hasImages = _capturedImages.isNotEmpty;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: config.titleAlignment.crossAxisAlignment,
          children: [
            const SizedBox(height: 24),
            Text(
              config.title,
              textAlign: config.titleAlignment.textAlign,
              style: GoogleFonts.lexend(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.35,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 20),
            _buildImageArea(hasImages),
            const SizedBox(height: 20),
            _buildPrimaryButton(hasImages),
            const SizedBox(height: 12),
            _buildSecondaryButton(hasImages),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImageArea(bool hasImages) {
    return Container(
      width: double.infinity,
      height: 356,
      decoration: BoxDecoration(
        color: const Color(0xFFE7EBEF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          if (hasImages)
            PageView.builder(
              itemCount: _capturedImages.length,
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _capturedImages[index],
                  width: double.infinity,
                  height: 356,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            const Center(
              child: Icon(Icons.image, size: 48, color: Colors.grey),
            ),
          if (_isScanning)
            Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'Scanning...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          if (hasImages && !_isScanning)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_capturedImages.length} photo${_capturedImages.length > 1 ? 's' : ''}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(bool hasImages) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isScanning ? null : () => _pickImage(ImageSource.camera),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00695C),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          hasImages ? 'Take another photo' : 'Take photo',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(bool hasImages) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isScanning ? null : () => _pickImage(ImageSource.gallery),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF1B4332), width: 1),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          hasImages ? 'Choose more from gallery' : 'Choose from gallery',
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B4332),
          ),
        ),
      ),
    );
  }
}
