/// FCM Service exports
/// 
/// Provides Firebase Cloud Messaging token management
/// following MVVM pattern with Riverpod.
/// 
/// Usage:
/// ```dart
/// // In main.dart - Initialize FCM
/// final container = ProviderContainer();
/// await container.read(fcmServiceProvider.notifier).initialize();
/// 
/// // After login - Sync token
/// await ref.read(fcmServiceProvider.notifier).syncAfterLogin();
/// 
/// // On logout - Clear token
/// await ref.read(fcmServiceProvider.notifier).onLogout();
/// ```
library;

export 'data/data.dart';
export 'models/fcm_state.dart';
export 'providers/providers.dart';
