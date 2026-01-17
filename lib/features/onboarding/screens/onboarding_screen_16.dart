import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_notifier.dart';

class OnboardingScreen16 extends ConsumerWidget {
  const OnboardingScreen16({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Review & Submit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Patient: ${state.patientFullName ?? '-'}'),
            Text('Phone: ${state.patientPhone ?? '-'}'),
            const SizedBox(height: 16),

            const Text(
              'Assessment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Pain location: ${state.painLocation ?? '-'}'),
            Text('Pain scale: ${state.painScaleScore ?? '-'}'),
            Text('Pain character: ${state.painCharacter ?? '-'}'),
            const SizedBox(height: 16),

            const Text(
              'Physical Therapy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Gender: ${state.gender ?? '-'}'),
            Text('BMI: ${state.bmiScore?.toStringAsFixed(1) ?? '-'}'),
            Text('ADL: ${state.adlScore ?? '-'}'),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        final ok = await notifier.submitFinalProfile(context);
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Submission failed')),
                          );
                        }
                      },
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
