import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/onboarding_data.dart';

/// Builder cho Step 1: Welcome / Intro screen
class Step1Builder extends StatelessWidget {
  const Step1Builder({super.key});

  @override
  Widget build(BuildContext context) {
    final config = const OnboardingStep1Config();
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // Header banner - full width, overlaps edges
        Transform.translate(
          offset: const Offset(0, -16),
          child: Image.asset(
            'assets/images/onboarding/onboarding_logo.png',
            width: screenWidth + 10,
            height: 210,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(height: 210),
          ),
        ),

        // Illustration - centered 270x270
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/onboarding/elderly_couple.png',
              width: 180,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 180,
                height: 180,
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
        ),

        const SizedBox(height: 20),

        // Title at bottom - Lexend bold 22px, left-aligned
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              config.title,
              textAlign: TextAlign.left,
              style: GoogleFonts.lexend(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF221F1F),
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
