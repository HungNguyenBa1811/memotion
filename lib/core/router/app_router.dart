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

// Route names
class AppRoutes {
  static const String onboarding = '/';
  static const String onboardingStep1 = '/onboarding/1';
  static const String onboardingStep2 = '/onboarding/2';
  static const String onboardingStep3 = '/onboarding/3';
  static const String onboardingStep4 = '/onboarding/4';
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

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isOnAuthPage =
          state.matchedLocation == AppRoutes.signIn ||
          state.matchedLocation == AppRoutes.registration;

      // If authenticated and on auth pages, redirect to onboarding step 1
      // to allow users to complete the onboarding flow after login/registration.
      if (isAuthenticated && isOnAuthPage) {
        return AppRoutes.onboardingStep1;
      }

      // If not authenticated and trying to access profile, redirect to onboarding
      if (!isAuthenticated && state.matchedLocation == AppRoutes.profile) {
        return AppRoutes.onboarding;
      }

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
          onRegisterSuccess: () => context.go(AppRoutes.onboardingStep1),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Settings - Coming Soon')),
                ),
              ),
            ],
          ),
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
