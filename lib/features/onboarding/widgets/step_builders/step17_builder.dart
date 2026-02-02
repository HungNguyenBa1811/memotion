import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builder cho Step 17: Completion / Done screen
class Step17Builder extends ConsumerWidget {
  const Step17Builder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Green badge with target icon image
              Container(
                width: 81,
                height: 78,
                decoration: BoxDecoration(
                  color: const Color(0xFF42D599),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/onboarding/onboarding17_target.png',
                    width: 43,
                    height: 43,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title - centered, Lexend bold 22px, color #00695C
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Text(
                  'Recovery profile completed',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00695C),
                    height: 1.35,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Main illustration - 276x360
              Center(
                child: Image.asset(
                  'assets/images/onboarding/elderly2.png',
                  width: 276,
                  height: 360,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Container(
                    width: 276,
                    height: 360,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.celebration,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100), // Space for bottom FAB
            ],
          ),
        ),
      ],
    );
  }
}