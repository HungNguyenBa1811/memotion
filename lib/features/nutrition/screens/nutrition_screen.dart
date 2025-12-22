import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/bottom_pill_nav.dart';
import '../../../core/router/app_router.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
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
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                        ),
                        Icon(
                          Icons.notifications_outlined,
                          color: AppColors.textPrimary,
                          size: 24,
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
                          _buildCategoryPill('Lunch', isActive: true),
                          const SizedBox(width: 20),
                          _buildCategoryPill('Fruit'),
                          const SizedBox(width: 20),
                          _buildCategoryPill('Meat'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Featured salads horizontal scroll
                  SizedBox(
                    height: 320,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildFeaturedSaladCard(
                          context,
                          title: 'Keto Salad',
                          subtitle: 'Beans & fruits',
                          kcal: '370 Kcal',
                          imagePath: 'assets/images/KetoSalad.png',
                        ),
                        const SizedBox(width: 20),
                        _buildFeaturedSaladCard(
                          context,
                          title: 'Skewers Salad',
                          subtitle: 'Chicken & quinoa',
                          kcal: '580 Kcal',
                          imagePath: 'assets/images/Salad3.png',
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
                            style: GoogleFonts.glory(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: 'recipes',
                            style: GoogleFonts.glory(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
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

          // Bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomPillNav(
              currentIndex: 2,
              onTap: (index) => _handleNavTap(context, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondary : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.restaurant_menu, color: Colors.white, size: 20),
            ),
          Text(
            label,
            style: GoogleFonts.lexend(
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
  }) {
    return GestureDetector(
      onTap: () {
        context.push(
          AppRoutes.nutritionDetail,
          extra: {'title': title, 'subtitle': subtitle, 'kcal': kcal},
        );
      },
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(70),
            topRight: Radius.circular(70),
            bottomLeft: Radius.circular(27),
            bottomRight: Radius.circular(27),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Salad image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(70),
                topRight: Radius.circular(70),
              ),
              child: Image.asset(
                imagePath,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  height: 160,
                  color: AppColors.background,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        size: 24,
                      ),
                    ],
                  ),
                ],
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(70),
          topRight: Radius.circular(70),
          bottomLeft: Radius.circular(27),
          bottomRight: Radius.circular(27),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(70),
              bottomLeft: Radius.circular(27),
            ),
            child: Image.asset(
              imagePath,
              width: 140,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 140,
                height: 140,
                color: AppColors.background,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: GoogleFonts.lexend(
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
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.favorite_border,
                        color: Colors.black,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        // Calendar - not implemented yet
        break;
      case 2:
        // Already on Nutrition
        break;
      case 3:
        context.go(AppRoutes.profile);
        break;
      case 4:
        // Settings - not implemented yet
        break;
    }
  }
}
