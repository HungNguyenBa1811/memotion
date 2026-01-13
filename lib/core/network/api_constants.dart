/// API Constants and Endpoints
class ApiConstants {
  ApiConstants._();

  // Base URL - Change this according to your environment
  static const String baseUrl = 'http://14.225.218.83:8005';

  // Auth Endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register/v2';

  // Task Endpoints
  static const String medicationTasks = '/api/tasks/patient/medication-tasks';
  static const String nutritionTasks = '/api/tasks/patient/nutrition-tasks';
  static const String exerciseTasks = '/api/tasks/patient/exercise-tasks';
  static const String taskDetail = '/api/tasks';
  static const String completeTask = '/api/tasks/patient';

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
