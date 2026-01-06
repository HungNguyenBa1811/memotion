import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import 'bottom_pill_nav.dart';

/// MainShell widget wraps the main screens with a persistent BottomPillNav.
/// This prevents the bottom navigation from being rebuilt when switching tabs.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // The current screen content
          navigationShell,

          // Persistent bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomPillNav(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => _onTap(index),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(int index) {
    // Use goBranch to switch between tabs while preserving state
    navigationShell.goBranch(
      index,
      // Navigate to the initial location of the branch if already on it
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
