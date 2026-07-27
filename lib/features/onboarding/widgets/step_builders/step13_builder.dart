import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/onboarding_data.dart';
import '../../providers/onboarding_provider.dart';
import '../onboarding_text_input.dart';

/// Builder cho Step 13: Blood glucose input
class Step13Builder extends ConsumerStatefulWidget {
  const Step13Builder({super.key});

  @override
  ConsumerState<Step13Builder> createState() => _Step13BuilderState();
}

class _Step13BuilderState extends ConsumerState<Step13Builder> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    _controller = TextEditingController(
      text: state.bloodSugar != null ? state.bloodSugar.toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = const OnboardingStep13Config();

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
            const SizedBox(height: 16),

            // Single-line compact input per Figma
            SizedBox(
              height: 54,
              child: OnboardingTextInput(
                controller: _controller,
                maxLines: 1,
                hintText: 'Blood Glucose Level',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  final parsed = int.tryParse(v);
                  ref.read(onboardingProvider.notifier).setBloodSugar(parsed);
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
