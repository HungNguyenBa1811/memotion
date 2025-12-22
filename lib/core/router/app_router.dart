import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/registration_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/onboarding_steps.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/nutrition/screens/nutrition_screen.dart';
import '../../features/nutrition/screens/nutrition_detail_screen.dart';

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
      final isOnOnboarding = state.matchedLocation == AppRoutes.onboarding;

      // If authenticated and on auth pages, redirect to profile
      if (isAuthenticated && (isOnAuthPage || isOnOnboarding)) {
        return AppRoutes.profile;
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
      GoRoute(
        path: AppRoutes.onboardingStep1,
        builder: (context, state) => const OnboardingStepScreen(step: 1),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep2,
        builder: (context, state) => const OnboardingStepScreen(step: 2),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep3,
        builder: (context, state) => const OnboardingStepScreen(step: 3),
      ),
      GoRoute(
        path: AppRoutes.onboardingStep4,
        builder: (context, state) => const OnboardingStepScreen(step: 4),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) =>
            ProfileScreen(onLogout: () => context.go(AppRoutes.onboarding)),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const NutritionScreen(),
      ),
      GoRoute(
        path: AppRoutes.nutrition,
        builder: (context, state) => const NutritionScreen(),
      ),
      GoRoute(
        path: AppRoutes.nutritionDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return NutritionDetailScreen(
            title: extra?['title'] ?? 'Keto Salad',
            subtitle: extra?['subtitle'] ?? 'Beans, mandarin and avocado salad',
            kcal: extra?['kcal']?.replaceAll(' Kcal', '') ?? '370',
          );
        },
      ),
    ],
  );
});
