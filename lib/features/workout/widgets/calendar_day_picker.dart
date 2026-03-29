import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme.dart';
import '../models/workout_model.dart';

class CalendarDayPicker extends StatelessWidget {
  final List<CalendarDay> days;
  final int selectedIndex;
  final Function(int) onDaySelected;
  final double scale;

  const CalendarDayPicker({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onDaySelected,
    this.scale = 1.0,
  });

  String _getMonthName(DateTime date) {
    return DateFormat('MMM').format(date);
  }

  String _getDayOfWeekShort(DateTime date) {
    return DateFormat('E').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90 * scale,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(days.length, (index) {
          final day = days[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onDaySelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 64 * scale,
              height: 84 * scale,
              margin: EdgeInsets.symmetric(horizontal: 4 * scale),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(15 * scale),
                boxShadow: isSelected
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 32,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Month name (e.g., "May")
                  Text(
                    _getMonthName(day.date),
                    style: GoogleFonts.lexend(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF24252C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Day number
                  Text(
                    day.date.day.toString(),
                    style: GoogleFonts.lexend(
                      fontSize: 19 * scale,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF24252C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Day of week (e.g., "Sun", "Mon")
                  Text(
                    _getDayOfWeekShort(day.date),
                    style: GoogleFonts.lexend(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF24252C),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        ),
      ),
    );
  }
}
