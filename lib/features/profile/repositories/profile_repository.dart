import 'dart:async';

class ProfileRepository {
  Future<Map<String, String>> fetchStats() async {
    // Simulate network / local DB delay
    await Future.delayed(const Duration(milliseconds: 300));
    return {'heartRate': '72bpm', 'energy': '756cal', 'weight': '103lbs'};
  }
}

// Provider is declared next to where it's used (ViewModel).
