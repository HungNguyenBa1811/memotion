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
          const SizedBox(height: 40),
          _buildImage(context, config),
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
            controller: _painLevelController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.left,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3C3A36),
              height: 26 / 16,
              letterSpacing: -0.5,
            ),
            decoration: InputDecoration(
              hintText: 'Nhập số từ 0 đến 10',
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
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              final intValue = int.tryParse(value);
              if (intValue != null && intValue >= 0 && intValue <= 10) {
                ref.read(onboardingProvider.notifier).setPainLevel(intValue);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, OnboardingStep5Config config) {
    return Center(
      child: Image.asset(
        config.imagePath ?? 'assets/images/onboarding/elderly3.png',
        width: 240,
        height: 240,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 240,
          height: 240,
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
