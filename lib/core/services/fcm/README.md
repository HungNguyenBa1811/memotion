# FCM Service

## Cấu trúc

```
fcm/
├── data/                           # Data Layer
│   ├── datasources/               
│   │   ├── fcm_api_service.dart   # API calls
│   │   └── fcm_local_datasource.dart  # Local storage
│   ├── dto/
│   │   └── fcm_token_dto.dart     # Data transfer objects
│   ├── models/
│   │   └── fcm_token_local_model.dart  # Local storage model
│   ├── repositories/
│   │   └── fcm_repository.dart    # Repository implementation
│   └── providers/
│       └── fcm_providers.dart     # Data layer providers
│
├── models/                        # State Models
│   └── fcm_state.dart            # FCM state with freezed
│
├── providers/                     # State Management
│   └── fcm_notifier.dart         # StateNotifier for FCM
│
└── fcm.dart                      # Public exports
```

## Kiến trúc MVVM

### Model
- `FcmState`: Immutable state (freezed)
- `FcmTokenLocalModel`: Local storage model
- `SaveFcmTokenRequest/Response`: API DTOs (freezed)

### ViewModel
- `FcmNotifier`: StateNotifier quản lý logic
  - Initialize FCM
  - Handle token lifecycle
  - Sync to backend
  - Retry mechanism

### View
- Consume `fcmServiceProvider`
- React to state changes
- Không chứa business logic

## Setup

### 1. Initialize in main.dart

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/fcm/fcm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Init SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  final container = ProviderContainer(
    overrides: [
      // Override SharedPreferences provider
      fcmLocalDataSourceProvider.overrideWithValue(
        FcmLocalDataSource(prefs: prefs),
      ),
    ],
  );
  
  // Initialize FCM
  await container.read(fcmServiceProvider.notifier).initialize();
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(),
    ),
  );
}
```

### 2. Update backend URL

In `fcm_providers.dart`, update:
```dart
baseUrl: 'http://YOUR_BACKEND_URL',
```

### 3. After login

```dart
await ref.read(fcmServiceProvider.notifier).syncAfterLogin();
```

### 4. On logout

```dart
await ref.read(fcmServiceProvider.notifier).onLogout();
```

## Features

### Token Lifecycle
- ✅ Auto-generate on first launch
- ✅ Listen for token refresh
- ✅ Save locally (SharedPreferences)
- ✅ Sync to backend with retry (3 attempts)
- ✅ Check freshness (>200 days = refresh)

### State Management
- ✅ Riverpod StateNotifier
- ✅ Immutable state with freezed
- ✅ Clean separation of concerns

### Error Handling
- ✅ Retry with exponential backoff (30s, 60s, 90s)
- ✅ Graceful degradation (save local even if sync fails)
- ✅ Error state in FcmState

## Testing

```dart
// Mock repository
final mockRepo = MockFcmRepository();

// Create notifier with mock
final notifier = FcmNotifier(mockRepo);

// Test
await notifier.initialize();
verify(mockRepo.saveTokenLocally(any)).called(1);
```

## Architecture Benefits

✅ **MVVM**: Clear separation View/ViewModel/Model
✅ **Riverpod**: Declarative state management
✅ **Testable**: Easy to mock dependencies
✅ **Maintainable**: Single responsibility per class
✅ **Scalable**: Easy to extend

## Next Steps

1. Generate freezed code:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. Configure Firebase (google-services.json)

3. Test flow:
   - App launch → token generate
   - Login → token sync
   - Token refresh → auto-sync
   - Logout → token clear
