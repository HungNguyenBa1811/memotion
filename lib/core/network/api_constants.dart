/// API Constants and Endpoints
class ApiConstants {
  ApiConstants._();

  // Base URL - Change this according to your environment
  static const String baseUrl = 'http://ssh.nooblearn2code.com:8005';

  // Auth Endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register/v2';
  static const String userMe = '/api/users/me';

  // Task Endpoints
  static const String medicationTasks = '/api/tasks/patient/medication-tasks';
  static const String nutritionTasks = '/api/tasks/patient/nutrition-tasks';
  static const String exerciseTasks = '/api/tasks/patient/exercise-tasks';
  static const String taskDetail = '/api/tasks';
  static const String completeTask = '/api/tasks/patient';

  // Care Plan Endpoints
  static const String generateCarePlan = '/api/care-plans/generate';

  // Patient Profile Endpoints
  static const String patientProfileGeneral = '/api/patient-profiles/general';
  static const String patientProfilePhysicalTherapy =
      '/api/patient-profiles/physical-therapy';

  // Medication Library Endpoints
  static const String scanMedicationImage = '/api/medication-library/scan-image';

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
