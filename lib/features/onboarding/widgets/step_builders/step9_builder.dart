import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/onboarding_data.dart';
import '../../providers/onboarding_provider.dart';
import '../onboarding_choice_group.dart';

/// Builder cho Step 9: Balance/dizziness question
class Step9Builder extends ConsumerWidget {
  const Step9Builder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const config = OnboardingStep9Config();
    final state = ref.watch(onboardingProvider);

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

  Widget _buildOptions(
    BuildContext context,
    WidgetRef ref,
    OnboardingData state,
  ) {
    final notifier = ref.read(onboardingProvider.notifier);
    return OnboardingChoiceGroup<BalanceStatus>(
      choices: BalanceStatus.values
          .where((s) => s != BalanceStatus.other)
          .map((s) => OnboardingChoice(value: s, label: s.displayName))
          .toList(),
      selected: state.balanceStatus,
      isOtherSelected: state.balanceStatus == BalanceStatus.other,
      otherText: state.balanceOther ?? '',
      onSelected: notifier.setBalanceStatus,
      onOtherSelected: () => notifier.setBalanceStatus(BalanceStatus.other),
      onOtherTextChanged: notifier.setBalanceOther,
      otherHint: 'Describe how they feel when walking',
    );
  }
}
