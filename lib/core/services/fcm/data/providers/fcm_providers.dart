import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../data/data.dart';
import '../../storage/token_storage.dart';

/// Provider for FcmApiService
final fcmApiServiceProvider = Provider<FcmApiService>((ref) {
  return FcmApiService(
    dio: Dio(),
    baseUrl: 'http://your-backend.com', // TODO: Move to config
  );
});

/// Provider for FcmLocalDataSource
final fcmLocalDataSourceProvider = Provider<FcmLocalDataSource>((ref) {
  // Note: SharedPreferences should be initialized in main.dart
  throw UnimplementedError(
    'SharedPreferences must be overridden in main.dart',
  );
});

/// Provider for FcmRepository
final fcmRepositoryProvider = Provider<FcmRepository>((ref) {
  return FcmRepository(
    localDataSource: ref.watch(fcmLocalDataSourceProvider),
    apiService: ref.watch(fcmApiServiceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});
