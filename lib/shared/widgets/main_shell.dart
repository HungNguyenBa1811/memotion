import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import 'bottom_pill_nav.dart';

/// MainShell widget wraps the main screens with a persistent BottomPillNav.
/// This prevents the bottom navigation from being rebuilt when switching tabs.
///
/// Uses a custom fade-through transition animation when switching between tabs
/// while preserving the state of each branch via AutomaticKeepAlive.
class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _previousIndex = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.navigationShell.currentIndex;
    _initAnimationController();
  }

  void _initAnimationController() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.03, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.value = 1.0;
  }

  @override
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentIndex = widget.navigationShell.currentIndex;
    if (currentIndex != _previousIndex && !_isAnimating) {
      _playTransitionAnimation(currentIndex);
    }
  }

  void _playTransitionAnimation(int newIndex) {
    _isAnimating = true;

    // Determine slide direction based on tab position
    final slideDirection = newIndex > _previousIndex ? 1.0 : -1.0;
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.03 * slideDirection, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _previousIndex = newIndex;

    // Reset and play the animation
    _animationController.reset();
    _animationController.forward().then((_) {
      _isAnimating = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // The current screen content with fade-through animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: widget.navigationShell,
            ),
          ),

          // Persistent bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomPillNav(
              currentIndex: widget.navigationShell.currentIndex,
              onTap: (index) => _onTap(index),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(int index) {
    // Use goBranch to switch between tabs while preserving state
    widget.navigationShell.goBranch(
      index,
      // Navigate to the initial location of the branch if already on it
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}
