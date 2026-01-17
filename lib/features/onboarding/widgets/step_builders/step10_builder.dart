import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/onboarding_data.dart';
import '../../providers/onboarding_notifier.dart';
import '../onboarding_option_cell.dart';

/// Builder cho Step 10: Living arrangement selection
class Step10Builder extends ConsumerWidget {
  const Step10Builder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const config = OnboardingStep10Config();
    final options = config.options ?? const <String>[];

    // Watch the current livingArrangement value from the onboarding state
    final current = ref.watch(
      onboardingNotifierProvider.select((s) => s.livingArrangement),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            if ((config.subtitle ?? '').isNotEmpty)
              Text(
                config.subtitle!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            if ((config.subtitle ?? '').isNotEmpty) const SizedBox(height: 20),

            // Render option cells if the step config provides options
            for (var i = 0; i < options.length; i++) ...[
              OnboardingOptionCell(
                text: options[i],
                isSelected: current == options[i],
                onTap: () {
                  // Update notifier with selected living arrangement
                  ref
                      .read(onboardingNotifierProvider.notifier)
                      .setLivingArrangement(options[i]);
                },
              ),
              if (i != options.length - 1) const SizedBox(height: 12),
            ],

            if (options.isNotEmpty) const SizedBox(height: 32),

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
