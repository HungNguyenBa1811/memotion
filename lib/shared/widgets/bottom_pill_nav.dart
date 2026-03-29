import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/responsive_utils.dart';

class BottomPillNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomPillNav({super.key, this.currentIndex = 0, this.onTap});

  static const _items = [
    {'asset': 'assets/images/BottomNavHomeIcon.svg', 'label': 'Home'},
    {'asset': 'assets/images/HeartbeatIcon.svg', 'label': 'Med'},
    {'asset': 'assets/images/BottomNavDocumentIcon.svg', 'label': 'Nutri'},
    {'asset': 'assets/images/FireIcon.svg', 'label': 'Phys'},
    {'asset': 'assets/images/ProfileIcon.svg', 'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    final isLarge = ResponsiveUtils.isLargeTablet(context);
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final navHeight = isLarge ? 200.0 : isTablet ? 172.0 : 86.0;
    final bubbleSize = isLarge ? 88.0 : isTablet ? 80.0 : 40.0;
    final iconSize = isLarge ? 52.0 : isTablet ? 44.0 : 22.0;
    final labelSize = isLarge ? 23.0 : isTablet ? 20.0 : 10.0;
    final vPad = isLarge ? 28.0 : isTablet ? 24.0 : 12.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: vPad),
        child: Container(
          height: navHeight,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              return _NavItem(
                asset: _items[i]['asset']!,
                label: _items[i]['label']!,
                isActive: i == currentIndex,
                iconSize: iconSize,
                bubbleSize: bubbleSize,
                labelFontSize: labelSize,
                onTap: () => onTap?.call(i),
              );
            }),
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
  final double iconSize;
  final double bubbleSize;
  final double labelFontSize;
  final VoidCallback onTap;

  const _NavItem({
    required this.asset,
    required this.label,
    required this.isActive,
    required this.iconSize,
    required this.bubbleSize,
    required this.labelFontSize,
    required this.onTap,
  });

  static const _duration = Duration(milliseconds: 250);
  static const _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bubble + icon in the same Stack → Flutter aligns them perfectly,
          // no manual math needed regardless of size.
          SizedBox(
            width: bubbleSize,
            height: bubbleSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Bubble layer
                AnimatedContainer(
                  duration: _duration,
                  curve: _curve,
                  width: isActive ? bubbleSize : 0,
                  height: isActive ? bubbleSize : 0,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                // Icon layer — always centered inside the same SizedBox
                AnimatedSwitcher(
                  duration: _duration,
                  switchInCurve: _curve,
                  switchOutCurve: _curve,
                  child: SvgPicture.asset(
                    asset,
                    key: ValueKey('${asset}_$isActive'),
                    width: iconSize,
                    height: iconSize,
                    // ignore: deprecated_member_use
                    color: isActive ? Colors.white : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          // Label
          AnimatedDefaultTextStyle(
            duration: _duration,
            curve: _curve,
            style: AppTextStyles.caption.copyWith(
              fontSize: labelFontSize,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
