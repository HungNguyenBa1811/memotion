import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Horizontal card widget for popular recipes section
/// Layout: Image left, text content right
/// This is a hardcoded demo card based on the Figma design
class NutritionHorizontalCard extends StatelessWidget {
  const NutritionHorizontalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 147,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(70),
          topRight: Radius.circular(70),
          bottomLeft: Radius.circular(27),
          bottomRight: Radius.circular(27),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side - Image (overlapping the card)
          SizedBox(
            width: 160,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: -20,
                  top: -20,
                  child: Image.asset(
                    'assets/images/salad_placeholder.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 140,
                        height: 140,
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4DB6AC).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(70),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          size: 60,
                          color: Color(0xFF4DB6AC),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Right side - Text content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'Cavolo Nero Salad',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    'Cavolo nero & tomato',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Calories
                  Text(
                    '230 Kcal',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Arrow icon
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF4DB6AC).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline,
                size: 18,
                color: Color(0xFF4DB6AC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}