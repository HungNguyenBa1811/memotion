import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/onboarding_data.dart';
import '../../providers/onboarding_provider.dart';
import '../onboarding_text_input.dart';

/// Builder cho Step 12: Resting heart rate input
class Step12Builder extends ConsumerStatefulWidget {
  const Step12Builder({super.key});

  @override
  ConsumerState<Step12Builder> createState() => _Step12BuilderState();
}

class _Step12BuilderState extends ConsumerState<Step12Builder> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    _controller = TextEditingController(
      text: state.heartRate != null ? state.heartRate.toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(onboardingProvider);
    final config = const OnboardingStep12Config();

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
            const SizedBox(height: 12),

            // Single-line compact input per Figma
            SizedBox(
              height: 54,
              child: OnboardingTextInput(
                controller: _controller,
                maxLines: 1,
                hintText: 'RHR Score',
                onChanged: (v) {
                  final parsed = int.tryParse(v);
                  ref.read(onboardingProvider.notifier).setHeartRate(parsed);
                },
              ),
            ),

            const SizedBox(height: 32),
            if (config.imagePath != null && config.imagePath!.isNotEmpty)
              Center(
                child: Image.asset(
                  config.imagePath!,
                  width: 270,
                  height: 270,
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
