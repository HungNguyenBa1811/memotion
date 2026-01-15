import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/registration_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/onboarding_screen_new.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/nutrition/screens/nutrition_screen.dart';
import '../../features/nutrition/screens/nutrition_detail_screen.dart';
import '../../features/workout/screens/workout_screen.dart';
import '../../features/workout/screens/workout_detail_screen.dart';
import '../../features/medication/screens/medication_main_screen.dart';
import '../../features/medication/screens/medication_scan_screen.dart';
import '../../shared/widgets/main_shell.dart';
import 'route_config.dart';

// Route names
class AppRoutes {
  static const String onboarding = '/';
  static const String onboardingStep1 = '/onboarding/1';
  static const String onboardingStep2 = '/onboarding/2';
  static const String onboardingStep3 = '/onboarding/3';
  static const String onboardingStep4 = '/onboarding/4';
  static const String onboardingStep5 = '/onboarding/5';
  static const String onboardingStep6 = '/onboarding/6';
  static const String onboardingStep7 = '/onboarding/7';
  static const String onboardingStep8 = '/onboarding/8';
  static const String onboardingStep9 = '/onboarding/9';
  static const String onboardingStep10 = '/onboarding/10';
  static const String onboardingStep11 = '/onboarding/11';
  static const String onboardingStep12 = '/onboarding/12';
  static const String onboardingStep13 = '/onboarding/13';
  static const String onboardingStep14 = '/onboarding/14';
  static const String onboardingStep15 = '/onboarding/15';
  static const String onboardingStep16 = '/onboarding/16';
  static const String onboardingStep17 = '/onboarding/17';
  static const String onboardingStep18 = '/onboarding/18';
  static const String signIn = '/sign-in';
  static const String registration = '/registration';
  static const String profile = '/profile';
  static const String home = '/home';
  static const String nutrition = '/nutrition';
  static const String nutritionDetail = '/nutrition-detail';
  static const String workout = '/workout';
  static const String workoutDetail = '/workout-detail';
  static const String medication = '/medication';
  static const String medicationScan = '/medication-scan';
}

/// Listenable để notify router khi auth state thay đổi
class AuthNotifierListenable extends ChangeNotifier {
  AuthNotifierListenable(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;

  AuthStatus get status => _ref.read(authProvider).status;
}

/// Provider cho auth listenable
final authListenableProvider = Provider<AuthNotifierListenable>((ref) {
  return AuthNotifierListenable(ref);
});

// Router provider - SỬ DỤNG refreshListenable thay vì watch
final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ref.watch(authListenableProvider);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: true,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final status = authListenable.status;
      final currentPath = state.matchedLocation;
      final isPublicRoute = RouteConfig.isPublicRoute(currentPath);

      // Không redirect khi đang loading hoặc initial state
      if (status == AuthStatus.loading || status == AuthStatus.initial) {
        return null;
      }

      final isAuthenticated = status == AuthStatus.authenticated;

      // Case 1: Đã authenticated nhưng đang ở public route (sign-in, registration, landing)
      // -> Redirect đến authenticated area
      if (isAuthenticated && isPublicRoute) {
        return RouteConfig.authenticatedRedirect;
      }

      // Case 2: Chưa authenticated nhưng đang ở protected route
      // -> Redirect về public landing page
      // CHÚ Ý: Chỉ redirect khi KHÔNG ở public route
      if (!isAuthenticated && !isPublicRoute) {
        return RouteConfig.unauthenticatedRedirect;
      }

      // Không cần redirect
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => OnboardingScreen(
          onRegisterPressed: () => context.go(AppRoutes.registration),
          onLoginPressed: () => context.go(AppRoutes.signIn),
        ),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => SignInScreen(
          onBackPressed: () => context.go(AppRoutes.onboarding),
          onRegisterPressed: () => context.go(AppRoutes.registration),
          onLoginSuccess: () => context.go(AppRoutes.onboardingStep1),
        ),
      ),
      GoRoute(
        path: AppRoutes.registration,
        builder: (context, state) => RegistrationScreen(
          onBackPressed: () => context.go(AppRoutes.onboarding),
          onLoginPressed: () => context.go(AppRoutes.signIn),
          onRegisterSuccess: () => context.go(AppRoutes.signIn),
        ),
      ),
      // Onboarding step routes (sequence after auth)
      // Sử dụng OnboardingScreenNew với animation và state management
      GoRoute(
        path: AppRoutes.onboardingStep1,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 1),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep2,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 2),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep3,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 3),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep4,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 4),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep5,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 5),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep6,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 6),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep7,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 7),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep8,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 8),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep9,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 9),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep10,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 10),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep11,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 11),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep12,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 12),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep13,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 13),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep14,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 14),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep15,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 15),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep16,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 16),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep17,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 17),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep18,
        pageBuilder: (context, state) => _buildOnboardingPage(
          state,
          const OnboardingScreenNew(initialStep: 18),
        ),
      ),

      // Main shell with persistent bottom navigation
      // Uses StatefulShellRoute.indexedStack to preserve state of each tab
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home/Nutrition
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const NutritionScreenContent(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return NutritionDetailScreen(
                        title: extra?['title'] ?? 'Keto Salad',
                        subtitle:
                            extra?['subtitle'] ??
                            'Beans, mandarin and avocado salad',
                        kcal: extra?['kcal']?.replaceAll(' Kcal', '') ?? '370',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 1: Medication
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.medication,
                builder: (context, state) =>
                    const MedicationMainScreenContent(),
                routes: [
                  GoRoute(
                    path: 'scan',
                    builder: (context, state) => const MedicationScanScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: Nutrition
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.nutrition,
                builder: (context, state) => const NutritionScreenContent(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return NutritionDetailScreen(
                        title: extra?['title'] ?? 'Keto Salad',
                        subtitle:
                            extra?['subtitle'] ??
                            'Beans, mandarin and avocado salad',
                        kcal: extra?['kcal']?.replaceAll(' Kcal', '') ?? '370',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 3: Workout
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.workout,
                builder: (context, state) => const WorkoutScreenContent(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return WorkoutDetailScreen(
                        workoutId: extra?['workoutId'] ?? '',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreenContent(),
              ),
            ],
          ),
          // Branch 5: Settings (placeholder)
        ],
      ),
    ],
  );
});

/// Custom page transition cho onboarding screens
/// Tạo hiệu ứng slide mượt mà giữa các step
CustomTransitionPage _buildOnboardingPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Fade + Slide transition
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeOut).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.1, 0),
            end: Offset.zero,
          ).animate(CurveTween(curve: Curves.easeOutCubic).animate(animation)),
          child: child,
        ),
      );
    },
  );
}
