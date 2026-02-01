import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/onboarding_data.dart';
import '../../providers/onboarding_provider.dart';
import '../onboarding_option_cell.dart';

/// Builder cho Step 14: ADL (Activities of Daily Living) assessment
/// Options map to scores [2, 1, 0] in order:
/// - "Hoàn toàn tự làm được" = 2
/// - "Cần hỗ trợ một chút" = 1
/// - "Cần người làm giúp hoàn toàn" = 0
class Step14Builder extends ConsumerWidget {
  const Step14Builder({super.key});

  /// Scores for each option index: [2, 1, 0]
  static const List<int> optionScores = [2, 1, 0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = const OnboardingStep14Config();
    final options = config.options ?? const <String>[];

    // Watch current ADL score to highlight selected option
    final currentAdlScore = ref.watch(
      onboardingProvider.select((s) => s.adlScore),
    );

    // Determine selected index from score (reverse lookup)
    int? selectedIndex;
    if (currentAdlScore != null) {
      final idx = optionScores.indexOf(currentAdlScore);
      if (idx >= 0) selectedIndex = idx;
    }

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
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.35,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 12),
            if ((config.subtitle ?? '').isNotEmpty)
              Text(
                config.subtitle!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            if ((config.subtitle ?? '').isNotEmpty) const SizedBox(height: 16),

            for (var i = 0; i < options.length; i++) ...[
              OnboardingOptionCell(
                text: options[i],
                isSelected: selectedIndex == i,
                onTap: () {
                  // Set ADL score using option index -> score mapping [2,1,0]
                  ref
                      .read(onboardingProvider.notifier)
                      .setAdlScoreByOptionIndex(i);
                },
              ),
              if (i != options.length - 1) const SizedBox(height: 12),
            ],
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
