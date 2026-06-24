import '../models/onboarding_data.dart';

/// Service để lưu trữ và lấy dữ liệu onboarding
/// Có thể mở rộng để lưu vào SharedPreferences, Hive, hoặc API
abstract class OnboardingRepository {
  /// Lưu dữ liệu onboarding
  Future<void> saveOnboardingData(OnboardingData data);

  /// Lấy dữ liệu onboarding đã lưu
  Future<OnboardingData?> getOnboardingData();

  /// Kiểm tra người dùng đã hoàn thành onboarding chưa
  Future<bool> hasCompletedOnboarding();

  /// Đánh dấu onboarding đã hoàn thành
  Future<void> markOnboardingComplete();

  /// Xóa dữ liệu onboarding (khi logout)
  Future<void> clearOnboardingData();
}

/// Implementation mặc định - lưu trong memory
/// Có thể thay bằng SharedPreferencesOnboardingRepository cho production
class InMemoryOnboardingRepository implements OnboardingRepository {
  OnboardingData? _cachedData;
  bool _isCompleted = false;

  @override
  Future<void> saveOnboardingData(OnboardingData data) async {
    _cachedData = data;
  }

  @override
  Future<OnboardingData?> getOnboardingData() async {
    return _cachedData;
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    return _isCompleted;
  }

  @override
  Future<void> markOnboardingComplete() async {
    _isCompleted = true;
    if (_cachedData != null) {
      _cachedData = _cachedData!.copyWith(isCompleted: true);
    }
  }

  @override
  Future<void> clearOnboardingData() async {
    _cachedData = null;
    _isCompleted = false;
  }
}

/* 
/// Implementation với SharedPreferences cho production
/// Import: import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesOnboardingRepository implements OnboardingRepository {
  static const String _keyOnboardingData = 'onboarding_data';
  static const String _keyOnboardingComplete = 'onboarding_complete';

  final SharedPreferences _prefs;

  SharedPreferencesOnboardingRepository(this._prefs);

  @override
  Future<void> saveOnboardingData(OnboardingData data) async {
    final json = jsonEncode(data.toJson());
    await _prefs.setString(_keyOnboardingData, json);
  }

  @override
  Future<OnboardingData?> getOnboardingData() async {
    final json = _prefs.getString(_keyOnboardingData);
    if (json == null) return null;
    // TODO: Implement fromJson in OnboardingData
    return null;
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  @override
  Future<void> markOnboardingComplete() async {
    await _prefs.setBool(_keyOnboardingComplete, true);
  }

  @override
  Future<void> clearOnboardingData() async {
    await _prefs.remove(_keyOnboardingData);
    await _prefs.remove(_keyOnboardingComplete);
  }
}
*/
