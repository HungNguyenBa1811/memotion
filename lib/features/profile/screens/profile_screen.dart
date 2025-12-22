import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import 'package:memotion/shared/widgets/bottom_pill_nav.dart';
import '../../auth/providers/auth_provider.dart';
import '../viewmodels/profile_view_model.dart';
import '../../../core/router/app_router.dart';

class ProfileScreen extends ConsumerWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(profileViewModelProvider);
    final user = vm.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Profile', style: AppTextStyles.headline2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/images/NavSettingsIcon.svg',
              width: 22,
              height: 22,
              color: AppColors.primary,
            ),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomPillNav(
        currentIndex: 3,
        onTap: (index) => _handleNavTap(context, index),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Profile avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: user?.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          user!.avatarUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
              ),
              const SizedBox(height: 16),

              // User name
              Text(user?.nickname ?? 'User', style: AppTextStyles.headline1),
              const SizedBox(height: 4),

              // User email
              Text(
                user?.email ?? '',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Figma-alike stats row (Nhịp tim / Năng lượng / Cân nặng)
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHealthStat(
                    svgAsset: 'assets/images/HeartbeatIcon.svg',
                    fallbackIcon: Icons.favorite,
                    label: 'Nhịp tim',
                    value: '215bpm',
                  ),
                  _buildHealthStat(
                    svgAsset: 'assets/images/FireIcon.svg',
                    fallbackIcon: Icons.local_fire_department,
                    label: 'Năng lượng',
                    value: '756cal',
                  ),
                  _buildHealthStat(
                    svgAsset: 'assets/images/WeightIcon.svg',
                    fallbackIcon: Icons.fitness_center,
                    label: 'Cân nặng',
                    value: '103lbs',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Menu items matching Figma order
              _buildFigmaMenu(context, ref),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: AppColors.divider);
  }

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
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: svgAsset != null
                ? SvgPicture.asset(
                    svgAsset,
                    width: 22,
                    height: 22,
                    color: AppColors.primary,
                  )
                : Icon(
                    fallbackIcon ?? Icons.help_outline,
                    color: AppColors.primary,
                    size: 22,
                  ),
          ),
        ),
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

  Widget _buildFigmaMenu(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(profileViewModelProvider);
    // Items: Chỉnh sửa hồ sơ, Thông tin về người bệnh, Trợ giúp, Đăng xuất
    final items = [
      {
        'title': 'Chỉnh sửa hồ sơ',
        'iconAsset': 'assets/images/icon_user.png',
        'action': () {},
      },
      {
        'title': 'Thông tin về người bệnh',
        'iconAssetSvg': 'assets/images/DocumentIcon.svg',
        'action': () {},
      },
      {
        'title': 'Trợ giúp',
        'iconAssetSvg': 'assets/images/ChatIcon.svg',
        'action': () {},
      },
      {
        'title': 'Đăng xuất',
        'iconAssetSvgPrimary': 'assets/images/LogoutIcon.svg',
        'iconAssetSvgFallback': 'assets/images/LogoutIcon.svg',
        'action': () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('Đăng xuất'),
              content: const Text('Bạn có chắc muốn đăng xuất?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await vm.logout();
            onLogout();
          }
        },
      },
    ];

    return Column(
      children: items.map((it) {
        final isLogout = it['title'] == 'Đăng xuất';
        return Column(
          children: [
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: it.containsKey('iconAsset')
                      ? Image.asset(
                          it['iconAsset'] as String,
                          width: 20,
                          height: 20,
                          color: AppColors.surface,
                        )
                      : it.containsKey('iconAssetSvgPrimary')
                      ? SvgAssetWithFallback(
                          primary: it['iconAssetSvgPrimary'] as String,
                          fallback: it['iconAssetSvgFallback'] as String?,
                          width: 20,
                          height: 20,
                          color: AppColors.surface,
                        )
                      : it.containsKey('iconAssetSvg')
                      ? SvgPicture.asset(
                          it['iconAssetSvg'] as String,
                          width: 20,
                          height: 20,
                          color: AppColors.surface,
                        )
                      : Icon(it['icon'] as IconData, color: AppColors.surface),
                ),
              ),
              title: Text(
                it['title'] as String,
                style: AppTextStyles.bodyLarge,
              ),
              trailing: SvgPicture.asset(
                'assets/images/ChevronListIcon.svg',
                width: 18,
                height: 18,
                color: AppColors.textSecondary,
              ),
              onTap: it['action'] as void Function(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: AppColors.divider),
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

void _handleNavTap(BuildContext context, int index) {
  switch (index) {
    case 0:
      context.go(AppRoutes.home);
      break;
    case 1:
      // Calendar - not implemented yet
      break;
    case 2:
      context.go(AppRoutes.nutrition);
      break;
    case 3:
      // Already on Profile
      break;
    case 4:
      // Settings - not implemented yet
      break;
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
