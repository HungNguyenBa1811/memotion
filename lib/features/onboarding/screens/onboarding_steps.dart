import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/router/app_router.dart';

/// Onboarding step screen following the Figma design:
/// - 1.1: Introduction with elderly image
/// - 1.2: Choose rehabilitation function type
/// - 1.3: Body pain location selection
/// - 1.4: Doctor's advice input
class OnboardingStepScreen extends StatefulWidget {
  final int step;
  const OnboardingStepScreen({super.key, required this.step});

  @override
  State<OnboardingStepScreen> createState() => _OnboardingStepScreenState();
}

class _OnboardingStepScreenState extends State<OnboardingStepScreen> {
  // For step 2 and 3: track selected options
  final Set<int> _selectedOptions = {};

  // Controller for step 4 text input
  final TextEditingController _adviceController = TextEditingController();

  @override
  void dispose() {
    _adviceController.dispose();
    super.dispose();
  }

  String get title {
    switch (widget.step) {
      case 1:
        return 'Ứng dụng giám sát, xây dựng lộ trình phục hồi chức năng toàn diện';
      case 2:
        return 'Bác muốn phục hồi chức năng về?';
      case 3:
        return 'Hiện tại, cơ thể bác đang cảm thấy đau hay khó chịu ở đâu nhất?';
      case 4:
        return 'Lời khuyên từ bác sĩ?';
      default:
        return 'Onboarding';
    }
  }

  List<String> get options {
    switch (widget.step) {
      case 2:
        return ['Vật lý trị liệu', 'Thần kinh'];
      case 3:
        return ['Khớp gối', 'Khớp vai'];
      default:
        return [];
    }
  }

  String get nextRoute {
    switch (widget.step) {
      case 1:
        return AppRoutes.onboardingStep2;
      case 2:
        return AppRoutes.onboardingStep3;
      case 3:
        return AppRoutes.onboardingStep4;
      default:
        return AppRoutes.profile;
    }
  }

  void _onNext() {
    if (widget.step == 4) {
      context.go(AppRoutes.profile);
    } else {
      context.go(nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: _buildProgressIndicator(),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildStepContent(),
                ),
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildNextButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index < widget.step;
        final isCurrent = index == widget.step - 1;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: isCurrent ? 20 : 12,
          height: 5,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF00695C) // Primary Color from Figma
                : const Color(0xFFBEBAB3), // Ink/Gray
            borderRadius: BorderRadius.circular(2.5),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (widget.step) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Introduction with image
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        // Elderly2 image from Figma
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/onboarding/elderly2.png',
              width: 280,
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.elderly,
                  size: 100,
                  color: Color(0xFF00695C),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 60),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            height: 1.35,
            color: Color(0xFF221F1F),
          ),
        ),
      ],
    );
  }

  // Step 2: Choose rehabilitation function
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            height: 1.35,
            color: Color(0xFF221F1F),
          ),
        ),
        const SizedBox(height: 40),
        // Option cells
        ...List.generate(options.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildOptionCell(options[index], index),
          );
        }),
        const SizedBox(height: 40),
        // Confused person image from Figma
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/onboarding/confused_person.png',
              width: 280,
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_search,
                  size: 100,
                  color: Color(0xFF00695C),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Step 3: Body pain location
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        // Body image from Figma
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/onboarding/body_image.png',
              width: 280,
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.accessibility_new,
                  size: 100,
                  color: Color(0xFF00695C),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            height: 1.35,
            color: Color(0xFF221F1F),
          ),
        ),
        const SizedBox(height: 24),
        // Option cells
        ...List.generate(options.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildOptionCell(options[index], index),
          );
        }),
      ],
    );
  }

  // Step 4: Doctor's advice
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        // Elderly1 image from Figma
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/onboarding/elderly1.png',
              width: 340,
              height: 340,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.medical_services,
                  size: 100,
                  color: Color(0xFF00695C),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            height: 1.35,
            color: Color(0xFF221F1F),
          ),
        ),
        const SizedBox(height: 16),
        // Answer box
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            border: Border.all(color: const Color(0xFFC5BFBF)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextField(
            controller: _adviceController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Nhập lời khuyên...',
              hintStyle: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 16,
                color: Color(0xFF9E9E9E),
              ),
              contentPadding: EdgeInsets.all(16),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 16,
              color: Color(0xFF221F1F),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCell(String text, int index) {
    final isSelected = _selectedOptions.contains(index);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedOptions.remove(index);
          } else {
            _selectedOptions.add(index);
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00695C)
                : const Color(0xFFBEBAB3),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE7EFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForOption(text),
                color: const Color(0xFF4E6AFF),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  letterSpacing: -0.5,
                  color: Color(0xFF3C3A36),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00695C),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForOption(String option) {
    switch (option) {
      case 'Vật lý trị liệu':
        return Icons.accessibility;
      case 'Thần kinh':
        return Icons.psychology;
      case 'Khớp gối':
        return Icons.directions_walk;
      case 'Khớp vai':
        return Icons.sports_martial_arts;
      default:
        return Icons.medical_services;
    }
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: _onNext,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF00695C),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 70,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 24),
      ),
    );
  }
}
