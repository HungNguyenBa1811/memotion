import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/registration_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/onboarding/screens/onboarding_wizard_screen.dart';
import '../../features/onboarding/screens/onboarding_loading_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/nutrition/screens/nutrition_screen.dart';
import '../../features/nutrition/screens/nutrition_detail_screen.dart';
import '../../features/workout/screens/workout_screen.dart';
import '../../features/workout/screens/workout_detail_screen.dart';
import '../../features/workout/screens/workout_exercise_screen.dart';
import '../../features/workout/screens/workout_calibration_complete_screen.dart';
import '../../features/workout/screens/workout_training_screen.dart';
import '../../features/workout/screens/workout_training_complete_screen.dart';
import '../../features/workout/screens/pose_detection_screen.dart';
import '../../features/workout/screens/pose_training_screen.dart';
import '../../features/workout/screens/qr_scan_screen.dart';
import '../../features/workout/screens/pc_standby_screen.dart';
import '../network/api_constants.dart';
import '../../features/medication/screens/medication_screen.dart';
import '../../features/medication/screens/medication_reminder_screen.dart';
import '../../features/medication/screens/medication_scan_screen.dart';
import '../../features/profile/screens/caretaker_health_report_screen.dart';
import '../../shared/widgets/main_shell.dart';
import 'route_config.dart';

/// Shared root navigator key — dùng cho GoRouter và app-level alarm navigation.
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

// Route names
class AppRoutes {
  static const String onboarding = '/';
  static const String onboardingStep1 = '/onboarding/1';
  static const String onboardingLoading = '/onboarding/loading';
  static const String signIn = '/sign-in';
  static const String registration = '/registration';
  static const String profile = '/profile';
  static const String home = '/home';
  static const String nutrition = '/nutrition';
  static const String nutritionDetail = '/nutrition-detail';
  static const String workout = '/workout';
  static const String workoutDetail = '/workout-detail';
  static const String workoutExercise = '/workout-exercise';
  static const String workoutCalibrationComplete =
      '/workout-calibration-complete';
  static const String workoutTraining = '/workout-training';
  static const String workoutTrainingComplete = '/workout-training-complete';
  static const String poseDetection = '/pose-detection';
  static const String poseTraining = '/pose-training';
  static const String pcQrScan = '/pc-qr-scan';
  static const String pcStandby = '/pc-standby';
  static const String medication = '/medication';
  static const String medicationScan = '/medication-scan';
  static const String medicationReminder = '/medication-reminder';
  static const String caretakerHealthReport = '/caretaker-health-report';
}

/// Listenable để notify router khi auth state thay đổi
class AuthNotifierListenable extends ChangeNotifier {
  AuthNotifierListenable(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, _) {
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
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: true,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final status = authState.status;
      final currentPath = state.matchedLocation;
      final isPublicRoute = RouteConfig.isPublicRoute(currentPath);

      // Không redirect khi đang loading hoặc initial state
      if (status == AuthStatus.loading || status == AuthStatus.initial) {
        return null;
      }

      final isAuthenticated = status == AuthStatus.authenticated;

      // Case 1: Đã authenticated nhưng đang ở public route -> về home
      if (isAuthenticated && isPublicRoute) {
        return RouteConfig.homeRoute;
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
        builder: (context, state) => WelcomeScreen(
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
      // Onboarding wizard — single route, PageView handles step navigation internally
      GoRoute(
        path: AppRoutes.onboardingStep1,
        builder: (context, state) => const OnboardingWizardScreen(initialStep: 1),
      ),

      // Onboarding Loading screen - shown while submitting data
      GoRoute(
        path: AppRoutes.onboardingLoading,
        builder: (context, state) => const OnboardingLoadingScreen(),
      ),

      // Workout Detail and Exercise routes - OUTSIDE shell (no bottom nav)
      GoRoute(
        path: '/workout-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return WorkoutDetailScreen(workoutId: extra?['workoutId'] ?? '');
        },
      ),
      GoRoute(
        path: '/workout-exercise',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return WorkoutExerciseScreen(workoutId: extra?['workoutId'] ?? '');
        },
      ),
      GoRoute(
        path: '/workout-calibration-complete',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return WorkoutCalibrationCompleteScreen(
            workoutId: extra?['workoutId'] ?? '',
            minAngle: extra?['currentAngle'] ?? 20,
            maxAngle: extra?['safeLimit'] ?? 140,
            videoPath: extra?['videoPath'],
          );
        },
      ),
      GoRoute(
        path: '/workout-training',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return WorkoutTrainingScreen(
            workoutId: extra?['workoutId'] ?? '',
            videoPath: extra?['videoPath'],
          );
        },
      ),
      GoRoute(
        path: '/workout-training-complete',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return WorkoutTrainingCompleteScreen(
            workoutId: extra?['workoutId'] ?? '',
            duration: extra?['duration'] ?? '12:30',
            durationSeconds: extra?['durationSeconds'] ?? 750,
          );
        },
      ),
      
      // Pose Detection routes - Real-time AI pose analysis
      GoRoute(
        path: '/pose-detection',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PoseDetectionScreen(
            workoutId: extra?['workoutId'] ?? '',
            exerciseType: extra?['exerciseType'],
            videoPath: extra?['videoPath'],
          );
        },
      ),
      GoRoute(
        path: '/pose-training',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PoseTrainingScreen(
            workoutId: extra?['workoutId'] ?? '',
            exerciseType: extra?['exerciseType'],
            videoPath: extra?['videoPath'],
          );
        },
      ),

      // PC QR Scan - Android scans PC QR to initiate pairing
      GoRoute(
        path: AppRoutes.pcQrScan,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final videoPath = extra?['videoPath'] as String?;
          final videoUrl = (videoPath != null && videoPath.isNotEmpty)
              ? '${ApiConstants.baseUrl}$videoPath'
              : null;
          return QrScanScreen(
            workoutId: extra?['workoutId'] ?? '',
            exerciseType: extra?['exerciseType'] ?? 'arm_raise',
            videoUrl: videoUrl,
          );
        },
      ),

      // PC Standby - Android waits while PC runs the session
      GoRoute(
        path: AppRoutes.pcStandby,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PcStandbyScreen(
            workoutId: extra?['workoutId'] ?? '',
            exerciseType: extra?['exerciseType'] ?? 'arm_raise',
          );
        },
      ),

      // Medication Scan - outside shell (no bottom nav)
      GoRoute(
        path: AppRoutes.medicationScan,
        builder: (context, state) => const MedicationScanScreen(),
      ),

      // Medication Reminder - alarm scheduler demo
      GoRoute(
        path: AppRoutes.medicationReminder,
        builder: (context, state) => const MedicationReminderScreen(),
      ),

      // Caretaker Health Report - outside shell (no bottom nav)
      GoRoute(
        path: AppRoutes.caretakerHealthReport,
        builder: (context, state) => const CaretakerHealthReportScreen(),
      ),

      // Nutrition Detail - outside shell (no bottom nav)
      GoRoute(
        path: AppRoutes.nutritionDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final taskId = extra?['taskId'] as String? ?? '';
          return NutritionDetailScreen(taskId: taskId);
        },
      ),

      // Main shell with persistent bottom navigation
      // Uses StatefulShellRoute.indexedStack to preserve state of each tab
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 1: Medication
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.medication,
                builder: (context, state) => const MedicationScreen(),
              ),
            ],
          ),
          // Branch 2: Nutrition
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.nutrition,
                builder: (context, state) => const NutritionScreen(),
              ),
            ],
          ),
          // Branch 3: Workout (only list screen has bottom nav)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.workout,
                builder: (context, state) => const WorkoutScreen(),
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

