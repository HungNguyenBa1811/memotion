import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_data.dart';

/// State for home screen
class HomeState {
  final HomeDashboardData? data;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    HomeDashboardData? data,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Provider for home dashboard data
class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState()) {
    _loadHomeData();
  }

  /// Load home dashboard data
  /// In production, this would call an API endpoint
  Future<void> _loadHomeData() async {
    state = state.copyWith(isLoading: true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data - in production this would come from API
      final dashboardData = HomeDashboardData(
        userName: 'John Doe',
        greeting: _getGreeting(),
        upcomingMedication: const UpcomingMedication(
          id: '1',
          name: 'Aspirin 100mg',
          dosage: '1 tablet after breakfast',
          time: '10:00 AM',
        ),
        healthVitals: const HealthVitals(
          heartRate: '72',
          bloodPressure: '120/80',
          steps: '5,420',
        ),
      );

      state = state.copyWith(
        data: dashboardData,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Get greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Trigger SOS emergency alert
  Future<void> triggerSOS() async {
    // In production, this would call an emergency API endpoint
    // and notify caregivers
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Refresh home data
  Future<void> refresh() async {
    await _loadHomeData();
  }
}

/// Provider instance
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});