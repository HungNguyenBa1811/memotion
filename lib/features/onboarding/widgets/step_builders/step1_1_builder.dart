import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/onboarding_provider.dart';

/// Builder cho Step 1.1: Email input screen
/// Figma design: Bxer3DnXLQcxg5HSArHa8w node 453:1691
class OnboardingEmailStepBuilder extends ConsumerStatefulWidget {
  const OnboardingEmailStepBuilder({super.key});

  @override
  ConsumerState<OnboardingEmailStepBuilder> createState() =>
      _OnboardingEmailStepBuilderState();
}

class _OnboardingEmailStepBuilderState
    extends ConsumerState<OnboardingEmailStepBuilder> {
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    _emailController = TextEditingController(text: state.email ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    ref.read(onboardingProvider.notifier).setEmail(value);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // Title - centered, Lexend bold 22px
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Center(
              child: Text(
                'Enter your email address\nto continue',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF221F1F),
                  height: 1.35,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Label - Lexend medium 16px
          Text(
            'Email address',
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF222222),
              height: 1.25,
            ),
          ),

          const SizedBox(height: 12),

          // Text field - 54px height, white bg, gray border, radius 16
          SizedBox(
            height: 54,
            child: TextField(
              controller: _emailController,
              onChanged: _onEmailChanged,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              decoration: InputDecoration(
                hintText: 'Email address',
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
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
