import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/theme.dart';

class BottomPillNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomPillNav({super.key, this.currentIndex = 0, this.onTap});

  @override
  State<BottomPillNav> createState() => _BottomPillNavState();
}

class _BottomPillNavState extends State<BottomPillNav>
    with SingleTickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 250);
  static const _animationCurve = Curves.easeOutCubic;

  final List<Map<String, String>> _items = const [
    {'asset': 'assets/images/BottomNavHomeIcon.svg', 'label': 'Home'},
    {'asset': 'assets/images/HeartbeatIcon.svg', 'label': 'Med'},
    {'asset': 'assets/images/BottomNavDocumentIcon.svg', 'label': 'Nutri'},
    {'asset': 'assets/images/FireIcon.svg', 'label': 'Phys'},
    {'asset': 'assets/images/ProfileIcon.svg', 'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
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
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / _items.length;
              return Stack(
                children: [
                  // Animated focus indicator
                  AnimatedPositioned(
                    duration: _animationDuration,
                    curve: _animationCurve,
                    left: (itemWidth * widget.currentIndex) +
                        (itemWidth - 40) / 2,
                    top: (86 - 40 - 6 - 14) / 2, // Centered vertically
                    child: AnimatedContainer(
                      duration: _animationDuration,
                      curve: _animationCurve,
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Nav items
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_items.length, (i) {
                      final item = _items[i];
                      final isActive = i == widget.currentIndex;
                      return _NavItem(
                        asset: item['asset']!,
                        label: item['label']!,
                        isActive: isActive,
                        onTap: () => widget.onTap?.call(i),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String asset;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.asset,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  static const _animationDuration = Duration(milliseconds: 250);
  static const _animationCurve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Center(
                child: AnimatedSwitcher(
                  duration: _animationDuration,
                  switchInCurve: _animationCurve,
                  switchOutCurve: _animationCurve,
                  child: SvgPicture.asset(
                    asset,
                    key: ValueKey('${asset}_$isActive'),
                    width: 22,
                    height: 22,
                    // ignore: deprecated_member_use
                    color: isActive ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: _animationDuration,
              curve: _animationCurve,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
