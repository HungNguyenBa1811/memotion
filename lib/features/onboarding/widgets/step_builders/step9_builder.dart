import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/onboarding_data.dart';

/// Builder cho Step 9: Balance/dizziness question
class Step9Builder extends ConsumerStatefulWidget {
  const Step9Builder({super.key});

  @override
  ConsumerState<Step9Builder> createState() => _Step9BuilderState();
}

class _Step9BuilderState extends ConsumerState<Step9Builder> {
  final TextEditingController _controller = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      // Initialize from state if needed
      _initialized = true;
    }

    const config = OnboardingStep9Config();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildHeader(context, config),
          const SizedBox(height: 24),
          _buildInput(context),
          const SizedBox(height: 40),
          _buildImage(context, config),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OnboardingStep9Config config) {
    return Text(
      config.title,
      textAlign: config.titleAlignment.textAlign,
      style: GoogleFonts.lexend(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: const Color(0xFF221F1F),
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBEBAB3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.left,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3C3A36),
              height: 26 / 16,
              letterSpacing: -0.5,
            ),
            decoration: InputDecoration(
              hintText: 'Nhập câu trả lời',
              hintStyle: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF3C3A36).withAlpha(128),
                height: 26 / 16,
                letterSpacing: -0.5,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              // Save to provider if needed
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, OnboardingStep9Config config) {
    return Center(
      child: Image.asset(
        config.imagePath ?? 'assets/images/onboarding/elderly3.png',
        width: 270,
        height: 270,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 270,
          height: 270,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
