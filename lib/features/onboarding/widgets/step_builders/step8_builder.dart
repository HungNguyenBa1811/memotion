import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/onboarding_provider.dart';
import '../../models/onboarding_data.dart';
import '../onboarding_option_cell.dart';

class Step8Builder extends ConsumerWidget {
  const Step8Builder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    const config = OnboardingStep8Config();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildHeader(context, config),
          const SizedBox(height: 24),
          _buildOptions(context, ref, state), 
          _buildImage(context, config),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OnboardingStep8Config config) {
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
    return Column(
      children: StandAbility.values.map((ability) {
        final isSelected = state.standAbility == ability;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OnboardingOptionCell(
            text: ability.displayName,
            isSelected: isSelected,
            onTap: () =>
                ref.read(onboardingProvider.notifier).setStandAbility(ability),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImage(BuildContext context, OnboardingStep8Config config) {
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
