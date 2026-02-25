import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import '../../models/onboarding_data.dart';
import '../../providers/onboarding_provider.dart';
import '../onboarding_text_input.dart';

/// Builder cho Step 11: Blood pressure / MAP score input
class Step11Builder extends ConsumerStatefulWidget {
  const Step11Builder({super.key});

  @override
  ConsumerState<Step11Builder> createState() => _Step11BuilderState();
}

class _Step11BuilderState extends ConsumerState<Step11Builder> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    _controller = TextEditingController(
      text: state.mapScore != null ? state.mapScore!.toInt().toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = const OnboardingStep11Config();

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
            SizedBox(
              height: 54,
              child: OnboardingTextInput(
                controller: _controller,
                hintText: 'Enter blood pressure',
                maxLines: 1,
                onChanged: (v) {
                  final parsed = double.tryParse(v);
                  if (parsed != null) {
                    ref.read(onboardingProvider.notifier).setMapScore(parsed);
                  }
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