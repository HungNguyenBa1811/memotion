import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/onboarding_provider.dart';

/// Builder cho Step 1.1: Username/Phone Number input screen
/// Figma design: Bxer3DnXLQcxg5HSArHa8w node 453:1691
class Step1_1Builder extends ConsumerStatefulWidget {
  const Step1_1Builder({super.key});

  @override
  ConsumerState<Step1_1Builder> createState() => _Step1_1BuilderState();
}

class _Step1_1BuilderState extends ConsumerState<Step1_1Builder> {
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    _usernameController = TextEditingController(
      text: state.usernameOrPhone ?? '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    ref.read(onboardingProvider.notifier).setUsernameOrPhone(value);
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
                'Bác hãy nhập email để\nđăng nhập vào đây nhé',
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
            'Email',
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
              controller: _usernameController,
              onChanged: _onUsernameChanged,
              decoration: InputDecoration(
                hintText: 'Username',
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

          const SizedBox(height: 80),

          // Illustration at bottom - centered
          Center(
            child: Image.asset(
              'assets/images/onboarding/elderly4.png',
              width: 193,
              height: 220,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                width: 193,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),

          const SizedBox(height: 60), // Space for FAB
        ],
      ),
    );
  }
}
