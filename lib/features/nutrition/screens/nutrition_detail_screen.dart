import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';

const Color _textDarkGreen = Color(0xFF1B4332);
const Color _subtitleOrange = Color(0xFFD87659);

class NutritionDetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String kcal;

  const NutritionDetailScreen({
    super.key,
    this.title = 'Thịt bò Wagyu A5',
    this.subtitle = 'Beans , mandarin and\navocado salad',
    this.kcal = '370',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back and notification
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 70,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.notifications,
                            color: _textDarkGreen,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      title,
                      style: GoogleFonts.lexend(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: _textDarkGreen,
                        height: 1.12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      subtitle,
                      style: GoogleFonts.lexend(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _subtitleOrange,
                        height: 1.12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Hero image area with nutrition badges
                  SizedBox(
                    height: 350,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Main salad bowl image (top right)
                        Positioned(
                          right: -140,
                          top: -10,
                          child: SizedBox(
                            width: 340,
                            height: 344,
                            child: Image.asset(
                              'assets/images/nutrition/salad2.png',
                              width: 340,
                              height: 344,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  Container(
                                    width: 340,
                                    height: 344,
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Icon(
                                        Icons.restaurant,
                                        size: 80,
                                        color: AppColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),

                        // Avocado image (middle right)
                        Positioned(
                          right: -60,
                          top: 160,
                          child: Image.asset(
                            'assets/images/nutrition/avocado.png',
                            width: 230,
                            height: 244,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                const SizedBox.shrink(),
                          ),
                        ),

                        // Mandarin image
                        Positioned(
                          right: -60,
                          top: 150,
                          child: Image.asset(
                            'assets/images/nutrition/mandalin.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                const SizedBox.shrink(),
                          ),
                        ),

                        // Beans image
                        Positioned(
                          right: -60,
                          top: 220,
                          child: Image.asset(
                            'assets/images/nutrition/beans.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                const SizedBox.shrink(),
                          ),
                        ),

                        // Nutrition section title and badges (left side)
                        Positioned(
                          left: 25,
                          top: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dinh dưỡng',
                                style: GoogleFonts.lexend(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: _textDarkGreen,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildNutritionBadge(kcal, 'Calories'),
                              const SizedBox(height: 12),
                              _buildNutritionBadge('35', 'Carbo'),
                              const SizedBox(height: 12),
                              _buildNutritionBadge('6.8', 'Protein'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Ingredients section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Text(
                      'Nguyên liệu',
                      style: GoogleFonts.lexend(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: _textDarkGreen,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      '½ cup extra-virgin olive oil\n'
                      '¼ cup lime juice\n'
                      '¼ avocado\n'
                      '½ teaspoon salt\n'
                      '½ teaspoon freshly ground pepper\n'
                      'Pinch of minced garlic',
                      style: GoogleFonts.lexend(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: _textDarkGreen,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Recipe Preparation section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      'Receipe Preparation',
                      style: GoogleFonts.lexend(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: _textDarkGreen,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      'Chop all the ingredients to the size you want. '
                      'Add olive oil, garlic and lemon. '
                      'Mix them all in a large bowl slowly.',
                      style: GoogleFonts.lexend(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: _textDarkGreen,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            // Watch Video button - fixed at bottom
            Positioned(
              left: 37,
              bottom: 120,
              child: SizedBox(
                height: 48,
                width: 180,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Label container (behind)
                    Positioned(
                      left: 17,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 48,
                          right: 20,
                          top: 14,
                          bottom: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(70),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Watch Video',
                          style: GoogleFonts.lexend(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            height: 1.12,
                          ),
                        ),
                      ),
                    ),
                    // Play button (in front, overlapping)
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 50,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionBadge(String value, String label) {
    return SizedBox(
      height: 62,
      width: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Label container (behind)
          Positioned(
            left: 22,
            top: 8,
            child: Container(
              padding: const EdgeInsets.only(
                left: 50,
                right: 18,
                top: 10,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(27),
                  topRight: Radius.circular(27),
                  bottomLeft: Radius.circular(27),
                  bottomRight: Radius.circular(27),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.12,
                ),
              ),
            ),
          ),
          // Circle badge (in front, overlapping)
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  value,
                  style: GoogleFonts.lexend(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
