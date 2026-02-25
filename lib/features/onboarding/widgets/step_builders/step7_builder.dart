import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/onboarding_data.dart';
import '../../providers/onboarding_provider.dart';

class Step7Builder extends ConsumerStatefulWidget {
  const Step7Builder({super.key});

  @override
  ConsumerState<Step7Builder> createState() => _Step7BuilderState();
}

class _Step7BuilderState extends ConsumerState<Step7Builder> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    // Initialize with existing value if any (using weaknessType displayName or empty)
    _controller = TextEditingController(
      text: state.weaknessType?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const config = OnboardingStep7Config();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Title - Lexend bold 22px, left-aligned
            Text(
              config.title,
              textAlign: TextAlign.left,
              style: GoogleFonts.lexend(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.35,
                color: const Color(0xFF221F1F),
              ),
            ),
            const SizedBox(height: 24),

            // Text field - single line, 54px height, white bg, border #BEBAB3, radius 16
            SizedBox(
              height: 54,
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter description...',
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
                  // Map text to WeaknessType or store as custom
                  if (value.toLowerCase().contains('yếu') || value.toLowerCase().contains('weak')) {
                    ref
                        .read(onboardingProvider.notifier)
                        .setWeaknessType(WeaknessType.weakness);
                  } else if (value.toLowerCase().contains('cứng') || value.toLowerCase().contains('stiff')) {
                    ref
                        .read(onboardingProvider.notifier)
                        .setWeaknessType(WeaknessType.stiffness);
                  } else if (value.isEmpty ||
                      value.toLowerCase().contains('không') || value.toLowerCase().contains('none')) {
                    ref
                        .read(onboardingProvider.notifier)
                        .setWeaknessType(WeaknessType.none);
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