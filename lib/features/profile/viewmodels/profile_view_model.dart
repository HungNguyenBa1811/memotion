import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../repositories/profile_repository.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

final profileViewModelProvider = ChangeNotifierProvider<ProfileViewModel>((
  ref,
) {
  return ProfileViewModel(ref);
});

class ProfileViewModel extends ChangeNotifier {
  final Ref ref;

  String heartRate = '';
  String energy = '';
  String weight = '';

  ProfileViewModel(this.ref) {
    _init();
  }

  void _init() async {
    await loadStats();
    notifyListeners();
  }

  Future<void> loadStats() async {
    final repo = ref.read(profileRepositoryProvider);
    final stats = await repo.fetchStats();
    heartRate = stats['heartRate'] ?? '';
    energy = stats['energy'] ?? '';
    weight = stats['weight'] ?? '';
    notifyListeners();
  }

  // Expose current user via auth provider
  get user => ref.read(authProvider).user;

  Future<void> logout() async {
    await ref.read(authProvider.notifier).logout();
    notifyListeners();
  }
}
