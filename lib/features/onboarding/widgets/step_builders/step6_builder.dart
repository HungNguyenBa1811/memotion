import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/onboarding_data.dart';
import '../../providers/onboarding_provider.dart';
import '../onboarding_choice_group.dart';

class Step6Builder extends ConsumerWidget {
  const Step6Builder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    const config = OnboardingStep6Config();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildHeader(context, config),
          const SizedBox(height: 24),
          _buildOptions(context, ref, state),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OnboardingStep6Config config) {
    return Text(
      config.title,
      textAlign: config.titleAlignment.textAlign,
      style: GoogleFonts.lexend(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: const Color(0xFF221F1F),
      ),
    );
  }

  Widget _buildOptions(
    BuildContext context,
    WidgetRef ref,
    OnboardingData state,
  ) {
    final notifier = ref.read(onboardingProvider.notifier);
    return OnboardingChoiceGroup<PainType>(
      choices: PainType.values
          .where((t) => t != PainType.other)
          .map((t) => OnboardingChoice(value: t, label: t.displayName))
          .toList(),
      selected: state.painType,
      isOtherSelected: state.painType == PainType.other,
      otherText: state.painTypeOther ?? '',
      onSelected: notifier.setPainType,
      onOtherSelected: () => notifier.setPainType(PainType.other),
      onOtherTextChanged: notifier.setPainTypeOther,
      otherHint: 'Describe the pain',
    );
  }
}
