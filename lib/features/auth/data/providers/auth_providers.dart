import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data.dart';
import '../datasources/auth_api_service.dart';

/// Provider for AuthApiService
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

/// Provider for AuthDataSource
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  final apiService = ref.watch(authApiServiceProvider);
  return AuthDataSourceImpl(apiService: apiService);
});

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(dataSource: dataSource);
});
