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
    '/onboarding/2',
    '/onboarding/3',
    '/onboarding/4',
    '/home',
    '/medication',
    '/nutrition',
    '/workout',
    '/profile',
    '/caretaker-health-report',
  };

  /// Check if route is public
  static bool isPublicRoute(String path) {
    return publicRoutes.contains(path);
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

  /// Route home chính
  static const String homeRoute = '/home';
}
