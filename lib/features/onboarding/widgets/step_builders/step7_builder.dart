import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/onboarding_data.dart';
import '../../providers/onboarding_provider.dart';
import '../onboarding_choice_group.dart';

/// Builder cho Step 7: Weakness / stiffness question
class Step7Builder extends ConsumerWidget {
  const Step7Builder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const config = OnboardingStep7Config();
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

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

            OnboardingChoiceGroup<WeaknessType>(
              choices: WeaknessType.values
                  .where((t) => t != WeaknessType.other)
                  .map((t) => OnboardingChoice(value: t, label: t.displayName))
                  .toList(),
              selected: state.weaknessType,
              isOtherSelected: state.weaknessType == WeaknessType.other,
              otherText: state.weaknessOther ?? '',
              onSelected: notifier.setWeaknessType,
              onOtherSelected: () =>
                  notifier.setWeaknessType(WeaknessType.other),
              onOtherTextChanged: notifier.setWeaknessOther,
              otherHint: 'Describe what they struggle with',
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
