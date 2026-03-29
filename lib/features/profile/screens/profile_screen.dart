import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../health_connect/providers/heart_rate_provider.dart';
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
  @override
  void dispose() {
    super.dispose();
  }

  VoidCallback? get onLogout => widget.onLogout;

  void _showBleScanDialog(BuildContext context) {
    final hrNotifier = ref.read(heartRateProvider.notifier);
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _BleScanSheet(notifier: hrNotifier),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(profileViewModelProvider);
    final user = vm.user;
    final hrState = ref.watch(heartRateProvider);
    final bpmText = hrState.bpm > 0 ? '${hrState.bpm} bpm' : '-- bpm';
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final textScale = ResponsiveUtils.textScaleFactor(context);

    // Left Section
    final userProfileSection = Column(
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
            fontSize: 24 * textScale,
          ),
        ),
        const SizedBox(height: 8),

        // User email
        Text(
          vm.displayEmail,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14 * textScale,
          ),
        ),
        const SizedBox(height: 16),

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
                    value: bpmText,
                    textScale: textScale,
                    iconSize: isTablet ? 40 : 32,
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
                    textScale: textScale,
                    iconSize: isTablet ? 40 : 32,
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
                    textScale: textScale,
                    iconSize: isTablet ? 40 : 32,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    // Right Section
    final menuSection = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.contentMaxWidth(context),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.horizontalPadding(context),
          ),
          child: _buildFigmaMenu(context, ref, isTablet, textScale),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Profile', style: AppTextStyles.headline2.copyWith(fontSize: 20 * textScale)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.bluetooth,
              color: hrState.isLive ? AppColors.primary : Colors.grey,
              size: isTablet ? 36 : 24,
            ),
            onPressed: () => _showBleScanDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              userProfileSection,
              const SizedBox(height: 32),
              menuSection,
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
    required double textScale,
    required double iconSize,
  }) {
    return Expanded(
      child: Column(
        children: [
          // Icon
          Container(
            width: iconSize,
            height: iconSize,
            child: Center(
              child: svgAsset != null
                  ? SvgPicture.asset(svgAsset, width: iconSize, height: iconSize)
                  : Icon(
                      fallbackIcon ?? Icons.help_outline,
                      color: AppColors.primary,
                      size: iconSize,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10 * textScale,
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
              fontSize: 16 * textScale,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaMenu(BuildContext context, WidgetRef ref, bool isTablet, double textScale) {
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

    final iconBoxSize = isTablet ? 60.0 : 43.0;
    final iconImageSize = isTablet ? 32.0 : 20.0;

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
                vertical: 8,
              ),
              leading: Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF4DB6AC),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: it.containsKey('iconAsset')
                      ? Image.asset(
                          it['iconAsset'] as String,
                          width: iconImageSize,
                          height: iconImageSize,
                          color: Colors.white,
                        )
                      : it.containsKey('iconAssetSvgPrimary')
                      ? SvgAssetWithFallback(
                          primary: it['iconAssetSvgPrimary'] as String,
                          fallback: it['iconAssetSvgFallback'] as String?,
                          width: iconImageSize,
                          height: iconImageSize,
                          color: Colors.white,
                        )
                      : it.containsKey('iconAssetSvg')
                      ? SvgPicture.asset(
                          it['iconAssetSvg'] as String,
                          width: iconImageSize,
                          height: iconImageSize,
                          color: Colors.white,
                        )
                      : Icon(it['icon'] as IconData, color: Colors.white, size: iconImageSize),
                ),
              ),
              title: Text(
                it['title'] as String,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16 * textScale,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: isTablet ? 36 : 24,
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

// ── BLE Scan Bottom Sheet ──────────────────────────────────────────────────

class _BleScanSheet extends ConsumerStatefulWidget {
  const _BleScanSheet({required this.notifier});
  final HeartRateNotifier notifier;

  @override
  ConsumerState<_BleScanSheet> createState() => _BleScanSheetState();
}

class _BleScanSheetState extends ConsumerState<_BleScanSheet> {
  final _devices = <BluetoothDevice>[];
  bool _scanning = false;
  StreamSubscription<BluetoothDevice>? _scanSub;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    widget.notifier.stopScan();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _devices.clear();
      _scanning = true;
    });
    _scanSub = widget.notifier.scanForDevices().listen(
      (device) {
        if (!_devices.any((d) => d.remoteId == device.remoteId)) {
          setState(() => _devices.add(device));
        }
      },
      onDone: () => setState(() => _scanning = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        32 + ResponsiveUtils.bottomNavPadding(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Connect Watch',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_scanning)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _startScan,
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_devices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  _scanning
                      ? 'Scanning for HR devices…'
                      : 'No devices found.\nMake sure Memotion HR app is running on your watch.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _devices.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final device = _devices[i];
                final name = device.platformName.isNotEmpty
                    ? device.platformName
                    : device.remoteId.str;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.watch, color: AppColors.primary),
                  title: Text(name, style: GoogleFonts.lexend(fontSize: 14)),
                  subtitle: Text(
                    device.remoteId.str,
                    style: GoogleFonts.lexend(fontSize: 11, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    widget.notifier.connectToDevice(device);
                    Navigator.pop(context);
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}