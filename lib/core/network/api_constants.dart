/// API Constants and Endpoints
class ApiConstants {
  ApiConstants._();

  // Base URL - Change this according to your environment
  static const String baseUrl = 'http://14.225.218.83:8005';

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
  static const String updateCarePlan = '/api/care-plans/update';

  // Patient Profile Endpoints
  static const String patientProfileGeneral = '/api/patient-profiles/general';
  static const String patientProfilePhysicalTherapy =
      '/api/patient-profiles/physical-therapy';

  // Medication Library Endpoints
  static const String scanMedicationImage = '/api/medication-library/scan-image';

  // Medical Record Scan Endpoints
  static const String scanMedicalRecord =
      '/api/patient-profiles/physical-therapy/scan-medical-record';

  // Pose Detection Endpoints (Real-time WebSocket)
  static const String poseHealth = '/api/pose/health';
  static const String poseSessions = '/api/pose/sessions';
  // WebSocket: ws://{baseUrl}/api/pose/sessions/{session_id}/ws

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 120);
  static const Duration receiveTimeout = Duration(seconds: 120);
}
