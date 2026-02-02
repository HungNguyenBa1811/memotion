import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/onboarding_data.dart';
import '../../providers/onboarding_provider.dart';
import '../onboarding_option_cell.dart';

/// Builder cho Step 3: Health Objectives
///
/// Hiển thị:
/// - Title: Mục tiêu phục hồi
/// - List các mục tiêu (radio buttons - chỉ chọn 1)
/// - Image minh họa
class Step3Builder extends ConsumerWidget {
  const Step3Builder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildContent(context, ref, onboardingState),
          const SizedBox(height: 32),
          _buildImage(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const config = OnboardingStep3Config();
    return Column(
      crossAxisAlignment: config.titleAlignment.crossAxisAlignment,
      children: [
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
        if (config.subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            config.subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    OnboardingData state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: HealthObjective.values.map((objective) {
        final isSelected = state.selectedObjectives.contains(objective);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OnboardingOptionCell(
            text: objective.displayNameEn,
            isSelected: isSelected,
            onTap: () {
              ref
                  .read(onboardingProvider.notifier)
                  .toggleHealthObjective(objective);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImage(BuildContext context) {
    const config = OnboardingStep3Config();
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          config.imagePath ?? 'assets/images/placeholder.png',
          width: 240,
          height: 240,
          fit: BoxFit.cover,
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
      ),
    );
  }
}