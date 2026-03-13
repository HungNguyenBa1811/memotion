import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../providers/profile_provider.dart';

/// Original screen - kept for backwards compatibility
class ProfileScreen extends ConsumerWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileScreenContent(onLogout: onLogout);
  }
}

/// Content version without bottom nav - used inside MainShell
class ProfileScreenContent extends ConsumerStatefulWidget {
  final VoidCallback? onLogout;

  const ProfileScreenContent({super.key, this.onLogout});

  @override
  ConsumerState<ProfileScreenContent> createState() =>
      _ProfileScreenContentState();
}

class _ProfileScreenContentState extends ConsumerState<ProfileScreenContent> {
  // TODO(mock): remove when real health API is connected
  int _bpm = 73;
  Timer? _bpmTimer;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _bpmTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _bpm = 70 + _rng.nextInt(8)); // 70–77
    });
  }

  @override
  void dispose() {
    _bpmTimer?.cancel();
    super.dispose();
  }

  VoidCallback? get onLogout => widget.onLogout;

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(profileViewModelProvider);
    final user = vm.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Profile', style: AppTextStyles.headline2),
        centerTitle: true,
        actions: [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile avatar
              Container(
                width: ResponsiveUtils.avatarSize(context),
                height: ResponsiveUtils.avatarSize(context),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: user?.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          user!.avatarUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ClipOval(
                        child: Image.asset(
                          'assets/images/Avatar.png',
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(height: 18),

              // User name
              Text(
                vm.displayName,
                style: AppTextStyles.headline2.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // User email
              Text(
                vm.displayEmail,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              // Health stats row (Heart Rate / Energy / Weight)
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveUtils.contentMaxWidth(context),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.horizontalPadding(context),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHealthStat(
                          svgAsset: 'assets/images/heartbeat_icon.svg',
                          fallbackIcon: Icons.favorite,
                          label: 'Heart Rate',
                          value: '$_bpm bpm', // TODO(mock): replace with real API
                          // value: '215bpm',
                        ),
                        Container(
                          width: 1,
                          height: 44,
                          color: AppColors.background,
                        ),
                        _buildHealthStat(
                          svgAsset: 'assets/images/fire_icon.svg',
                          fallbackIcon: Icons.local_fire_department,
                          label: 'Energy',
                          value: '756cal',
                        ),
                        Container(
                          width: 1,
                          height: 44,
                          color: AppColors.background,
                        ),
                        _buildHealthStat(
                          svgAsset: 'assets/images/weight_icon.svg',
                          fallbackIcon: Icons.fitness_center,
                          label: 'Weight',
                          value: '103lbs',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Menu items matching Figma order
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveUtils.contentMaxWidth(context),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.horizontalPadding(context),
                    ),
                    child: _buildFigmaMenu(context, ref),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveUtils.bottomNavPadding(context)),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.headline3.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: AppColors.divider);
  }

  // ignore: unused_element
  Widget _buildMenuSection() {
    final menuItems = [
      _MenuItem(
        iconWidget: Image.asset(
          'assets/images/icon_user.png',
          width: 22,
          height: 22,
          color: AppColors.textPrimary,
        ),
        title: 'Account',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        onTap: () {},
      ),
      _MenuItem(icon: Icons.lock_outline, title: 'Security', onTap: () {}),
      _MenuItem(
        icon: Icons.help_outline,
        title: 'Help & Support',
        onTap: () {},
      ),
      _MenuItem(icon: Icons.info_outline, title: 'About', onTap: () {}),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: menuItems.map((item) {
          final isLast = item == menuItems.last;
          return Column(
            children: [
              ListTile(
                leading:
                    item.iconWidget ??
                    Icon(item.icon, color: AppColors.textPrimary),
                title: Text(item.title, style: AppTextStyles.bodyMedium),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
                onTap: item.onTap,
              ),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.divider),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHealthStat({
    String? svgAsset,
    IconData? fallbackIcon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            child: Center(
              child: svgAsset != null
                  ? SvgPicture.asset(svgAsset, width: 32, height: 32)
                  : Icon(
                      fallbackIcon ?? Icons.help_outline,
                      color: AppColors.primary,
                      size: 32,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          // Value
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaMenu(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(profileViewModelProvider);
    // Items: Edit Profile, Patient Information, Help, Log out
    final items = [
      {
        'title': 'Edit Profile',
        'iconAssetSvg': 'assets/images/heart_icon.svg',
        'action': () {
          final role = vm.userDetails?.role.toUpperCase() ?? '';
          if (role == 'CARETAKER') {
            context.push(AppRoutes.onboardingStep1);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Only caretakers can edit patient profiles'),
              ),
            );
          }
        },
      },
      {
        'title': 'Patient Information',
        'iconAssetSvg': 'assets/images/document_icon.svg',
        'action': () {
          context.push(AppRoutes.caretakerHealthReport);
        },
      },
      {
        'title': 'Help',
        'iconAssetSvg': 'assets/images/chat_icon.svg',
        'action': () {},
      },
      {
        'title': 'Log out',
        'iconAssetSvgPrimary': 'assets/images/logout_icon.svg',
        'iconAssetSvgFallback': 'assets/images/logout_icon.svg',
        'action': () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('Log out'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: const Text('Log out'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await vm.logout();
            if (onLogout != null) {
              onLogout!();
            } else {
              context.go(AppRoutes.onboarding);
            }
          }
        },
      },
    ];

    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final it = entry.value;
        final isLast = index == items.length - 1;

        return Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFF4DB6AC),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: it.containsKey('iconAsset')
                      ? Image.asset(
                          it['iconAsset'] as String,
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        )
                      : it.containsKey('iconAssetSvgPrimary')
                      ? SvgAssetWithFallback(
                          primary: it['iconAssetSvgPrimary'] as String,
                          fallback: it['iconAssetSvgFallback'] as String?,
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        )
                      : it.containsKey('iconAssetSvg')
                      ? SvgPicture.asset(
                          it['iconAssetSvg'] as String,
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        )
                      : Icon(it['icon'] as IconData, color: Colors.white),
                ),
              ),
              title: Text(
                it['title'] as String,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 24,
              ),
              onTap: it['action'] as void Function(),
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 37),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.blue.withValues(alpha: 0.13),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}

/// Widget that tries to load [primary] SVG asset and falls back to [fallback]
class SvgAssetWithFallback extends StatefulWidget {
  final String primary;
  final String? fallback;
  final double? width;
  final double? height;
  final Color? color;

  const SvgAssetWithFallback({
    super.key,
    required this.primary,
    this.fallback,
    this.width,
    this.height,
    this.color,
  });

  @override
  State<SvgAssetWithFallback> createState() => _SvgAssetWithFallbackState();
}

class _SvgAssetWithFallbackState extends State<SvgAssetWithFallback> {
  late Future<String> _which;

  @override
  void initState() {
    super.initState();
    _which = _chooseAsset();
  }

  Future<String> _chooseAsset() async {
    try {
      await rootBundle.load(widget.primary);
      return widget.primary;
    } catch (_) {
      if (widget.fallback != null) return widget.fallback!;
      return widget.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _which,
      builder: (context, snap) {
        final path = snap.data ?? widget.primary;
        return SvgPicture.asset(
          path,
          width: widget.width,
          height: widget.height,
          color: widget.color,
        );
      },
    );
  }
}

class _MenuItem {
  final IconData? icon;
  final Widget? iconWidget;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    this.icon,
    this.iconWidget,
    required this.title,
    required this.onTap,
  });
}