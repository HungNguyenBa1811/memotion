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
          const SizedBox(height: 24),
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
    return SizedBox(
      height: 54,
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Enter your answer',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFBEBAB3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFBEBAB3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFBEBAB3)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (value) {
          // Save to provider if needed
        },
      ),
    );
  }
}