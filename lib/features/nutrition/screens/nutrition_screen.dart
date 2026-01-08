import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';

/// Original screen - kept for backwards compatibility
class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NutritionScreenContent();
  }
}

/// Content version without bottom nav - used inside MainShell
class NutritionScreenContent extends StatelessWidget {
  const NutritionScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 160),
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
                          color: const Color(0xFF00695C),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      child: Stack(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Healthy Salads',
                  style: GoogleFonts.lexend(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Healthy and nutritious food recipes',
                  style: GoogleFonts.lexend(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD87659),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category pills (horizontally scrollable to avoid overflow)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryPill(
                        'Lunch',
                        isActive: true,
                        icon: Icons.restaurant_menu,
                      ),
                      const SizedBox(width: 20),
                      _buildCategoryPill('Fruit', icon: Icons.eco_outlined),
                      const SizedBox(width: 20),
                      _buildCategoryPill(
                        'Meat',
                        icon: Icons.kebab_dining_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Featured salads horizontal scroll
              SizedBox(
                height: 340,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  children: [
                    _buildFeaturedSaladCard(
                      context,
                      title: 'Keto Salad',
                      subtitle: 'Beans & fruits',
                      kcal: '370 Kcal',
                      imagePath: 'assets/images/KetoSalad.png',
                      imageRotation: -11,
                    ),
                    const SizedBox(width: 20),
                    _buildFeaturedSaladCard(
                      context,
                      title: 'Skewers Salad',
                      subtitle: 'Chicken & quinoa',
                      kcal: '580 Kcal',
                      imagePath: 'assets/images/Salad3.png',
                      imageRotation: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Popular recipes title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Popular ',
                        style: GoogleFonts.lexend(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: 'recipes',
                        style: GoogleFonts.lexend(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFACACAC),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Popular recipe card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildPopularRecipeCard(
                  title: 'Cavolo Nero Salad',
                  subtitle: 'Cavolo nero & tomato',
                  kcal: '230 Kcal',
                  imagePath: 'assets/images/CavoloSalad.png',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPill(
    String label, {
    bool isActive = false,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondary : Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                icon,
                size: 24,
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
          Text(
            label,
            style: GoogleFonts.glory(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSaladCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String kcal,
    required String imagePath,
    double imageRotation = 0,
  }) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/nutrition/detail',
          extra: {'title': title, 'subtitle': subtitle, 'kcal': kcal},
        );
      },
      child: SizedBox(
        width: 227,
        height: 340,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // White card positioned below image
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 272,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                    bottomLeft: Radius.circular(27),
                    bottomRight: Radius.circular(27),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 12,
                    top: 150,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            kcal,
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Icon(
                            Icons.favorite_border,
                            color: const Color(0xFFD6E68A),
                            size: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -20,
              left: -30,
              right: -30,
              child: Transform.rotate(
                angle: imageRotation * 3.14159 / 180,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(150),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      imagePath,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.restaurant,
                            size: 60,
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularRecipeCard({
    required String title,
    required String subtitle,
    required String kcal,
    required String imagePath,
  }) {
    return SizedBox(
      height: 147,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // White card
          Positioned(
            left: 55,
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(70),
                  topRight: Radius.circular(27),
                  bottomLeft: Radius.circular(70),
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
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 100,
                  right: 16,
                  top: 20,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.glory(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: GoogleFonts.glory(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          kcal,
                          style: GoogleFonts.glory(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Icon(
                          Icons.favorite_border,
                          color: Colors.black,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Image floating on left side, overlapping the card
          Positioned(
            left: -20,
            top: -20,
            bottom: -20,
            child: Image.asset(
              imagePath,
              width: 190,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => Container(
                width: 190,
                height: 184,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.eco,
                    size: 50,
                    color: AppColors.primary.withValues(alpha: 0.3),
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
