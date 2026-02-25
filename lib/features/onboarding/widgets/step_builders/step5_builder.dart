import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/onboarding_provider.dart';
import '../../models/onboarding_data.dart';

class Step5Builder extends ConsumerStatefulWidget {
  const Step5Builder({super.key});

  @override
  ConsumerState<Step5Builder> createState() => _Step5BuilderState();
}

class _Step5BuilderState extends ConsumerState<Step5Builder> {
  final TextEditingController _painLevelController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _painLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      final state = ref.read(onboardingProvider);
      final initialValue = state.painLevel ?? 0;
      if (initialValue > 0) {
        _painLevelController.text = initialValue.toString();
      }
      _initialized = true;
    }

    const config = OnboardingStep5Config();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildHeader(context, config),
          const SizedBox(height: 24),
          _buildPainLevelInput(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OnboardingStep5Config config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        config.title,
        textAlign: config.titleAlignment.textAlign,
        style: GoogleFonts.lexend(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF221F1F),
          height: 1.35,
        ),
      ),
    );
  }

  Widget _buildPainLevelInput(BuildContext context) {
    return SizedBox(
      height: 54,
      child: TextField(
        controller: _painLevelController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Enter a number from 0 to 10',
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
          final intValue = int.tryParse(value);
          if (intValue != null && intValue >= 0 && intValue <= 10) {
            ref.read(onboardingProvider.notifier).setPainLevel(intValue);
          }
        },
      ),
    );
  }

}