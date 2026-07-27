/// Route configuration
///
/// Định nghĩa public và private routes
class RouteConfig {
  RouteConfig._();

  /// Public routes - không cần authentication
  static const Set<String> publicRoutes = {'/', '/sign-in', '/registration'};

  /// Routes được phép khi đã authenticated (sau onboarding)
  static const Set<String> authenticatedRoutes = {
    '/onboarding/1',
    '/onboarding/loading',
    '/home',
    '/medication',
    '/nutrition',
    '/workout',
    '/profile',
    '/caretaker-health-report',
  };

  /// Onboarding wizard flow — được phép ở lại khi is_first_login = true
  static const Set<String> onboardingRoutes = {
    '/onboarding/1',
    '/onboarding/loading',
  };

  /// Check if route is public
  static bool isPublicRoute(String path) {
    return publicRoutes.contains(path);
  }

  /// Check if route thuộc onboarding wizard
  static bool isOnboardingRoute(String path) {
    return onboardingRoutes.contains(path);
  }

  /// Check if route is protected (requires authentication)
  static bool isProtectedRoute(String path) {
    // Nếu không phải public route thì là protected
    return !isPublicRoute(path);
  }

  /// Route mặc định khi chưa authenticated
  static const String unauthenticatedRedirect = '/';

  /// Route mặc định khi đã authenticated
  static const String authenticatedRedirect = '/onboarding/1';

  /// Route bắt đầu onboarding wizard (dùng khi is_first_login = true)
  static const String onboardingRedirect = '/onboarding/1';

  /// Route home chính
  static const String homeRoute = '/home';
}
