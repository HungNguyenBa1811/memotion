import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/theme.dart';

class BottomPillNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomPillNav({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'asset': 'assets/images/BottomNavHomeIcon.svg', 'label': 'Home'},
      {'asset': 'assets/images/BottomNavCalendarIcon.svg', 'label': 'Calendar'},
      {'asset': 'assets/images/BottomNavDocumentIcon.svg', 'label': 'Docs'},
      {'asset': 'assets/images/ProfileIcon.svg', 'label': 'Profile'},
      {'asset': 'assets/images/NavSettingsIcon.svg', 'label': 'Settings'},
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
        child: Container(
          height: 86,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final it = items[i];
              final active = i == currentIndex;
              return GestureDetector(
                onTap: () {
                  if (onTap != null) onTap!(i);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.secondary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          it['asset'] as String,
                          width: 22,
                          height: 22,
                          color: active ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      it['label'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: active
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
