# FCM Service Implementation Guide

## 📚 Mục lục
- [Tổng quan kiến trúc](#tổng-quan-kiến-trúc)
- [Giải thích chi tiết từng file](#giải-thích-chi-tiết-từng-file)
- [Data Flow](#data-flow)
- [Cách sử dụng](#cách-sử-dụng)
- [Testing](#testing)

---

## Tổng quan kiến trúc

FCM Service được xây dựng theo **MVVM pattern** với **Riverpod** state management, tuân thủ cấu trúc của project hiện tại.

### Cấu trúc thư mục

```
lib/core/services/fcm/
├── data/                          # 📦 Data Layer
│   ├── datasources/
│   │   ├── fcm_api_service.dart          # HTTP API calls
│   │   └── fcm_local_datasource.dart     # Local storage
│   ├── dto/
│   │   ├── fcm_token_dto.dart            # API DTOs
│   │   └── dto.dart                      # Exports
│   ├── models/
│   │   └── fcm_token_local_model.dart    # Local model
│   ├── repositories/
│   │   └── fcm_repository.dart           # Repository
│   ├── providers/
│   │   └── fcm_providers.dart            # Data providers
│   └── data.dart                         # Data layer exports
│
├── models/                        # 🎯 State Models
│   └── fcm_state.dart                    # FCM state
│
├── providers/                     # 🔄 State Management
│   ├── fcm_notifier.dart                 # ViewModel
│   └── providers.dart                    # Exports
│
├── fcm.dart                      # 📤 Public API
└── README.md                     # 📖 Documentation
```

### Vai trò các layer

| Layer | Mô tả | File |
|-------|-------|------|
| **Model** | Immutable state & data models | `fcm_state.dart`, `fcm_token_local_model.dart`, `fcm_token_dto.dart` |
| **ViewModel** | Business logic & state management | `fcm_notifier.dart` |
| **Repository** | Coordinate data sources | `fcm_repository.dart` |
| **Data Source** | Raw data operations | `fcm_api_service.dart`, `fcm_local_datasource.dart` |
| **Providers** | Dependency injection | `fcm_providers.dart` |

---

## Giải thích chi tiết từng file

### 1. Data Layer (`data/`)

#### 1.1 `datasources/fcm_api_service.dart`

**Vai trò:** Xử lý HTTP requests đến backend API.

**Class:** `FcmApiService`

**Dependencies:**
- `Dio` - HTTP client
- `SaveFcmTokenRequest/Response` - API DTOs

**Methods:**

```dart
Future<SaveFcmTokenResponse> syncToken({
  required String fcmToken,
  required String accessToken,
})
```

**Nhiệm vụ:**
- Gọi API `POST /api/v1/users/fcm-token`
- Gửi kèm Bearer token trong header
- Parse response thành DTO
- Handle errors (timeout, network, API errors)

**Ví dụ sử dụng:**
```dart
final apiService = FcmApiService(dio: Dio(), baseUrl: 'http://...');
final response = await apiService.syncToken(
  fcmToken: 'eyJhbGc...',
  accessToken: 'Bearer xxx',
);
```

**Lý do tách riêng:**
- **Single Responsibility**: Chỉ lo HTTP communication
- **Testable**: Dễ mock Dio để test
- **Reusable**: Có thể dùng cho nhiều repository

---

#### 1.2 `datasources/fcm_local_datasource.dart`

**Vai trò:** Quản lý lưu trữ local (SharedPreferences).

**Class:** `FcmLocalDataSource`

**Dependencies:**
- `SharedPreferences` - Local storage
- `FcmTokenLocalModel` - Local model

**Methods:**

```dart
// Get stored token
Future<FcmTokenLocalModel?> getToken()

// Save token locally
Future<void> saveToken(FcmTokenLocalModel token)

// Clear token
Future<void> clearToken()

// Check if needs sync
Future<bool> needsSync()
```

**Storage key:** `fcm_token_v1`

**Data format:**
```json
{
  "token": "eyJhbGc...",
  "last_updated": "2026-02-08T10:30:00.000Z",
  "is_synced": false
}
```

**Lý do tách riêng:**
- **Abstraction**: Repository không cần biết SharedPreferences
- **Swappable**: Có thể thay bằng Hive, SQLite mà không ảnh hưởng repository
- **Testable**: Mock SharedPreferences dễ dàng

---

#### 1.3 `dto/fcm_token_dto.dart`

**Vai trò:** Define API request/response structures.

**Classes:**

##### `SaveFcmTokenRequest`
```dart
@freezed
class SaveFcmTokenRequest with _$SaveFcmTokenRequest {
  const factory SaveFcmTokenRequest({
    @JsonKey(name: 'fcm_token') required String fcmToken,
  }) = _SaveFcmTokenRequest;
}
```

**Mapping backend:**
```json
{
  "fcm_token": "eyJhbGc..."
}
```

##### `SaveFcmTokenResponse`
```dart
@freezed
class SaveFcmTokenResponse with _$SaveFcmTokenResponse {
  const factory SaveFcmTokenResponse({
    required int code,
    required String message,
    UserDataDto? data,
  }) = _SaveFcmTokenResponse;
}
```

**Response example:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "user_id": "uuid",
    "register_fcm_token": "eyJhbGc...",
    "update_fcm_time": "2026-02-08T10:30:00"
  }
}
```

**Tại sao dùng freezed:**
- ✅ Immutable
- ✅ Auto-generate `copyWith`, `==`, `hashCode`
- ✅ JSON serialization
- ✅ Union types (Success/Error)

**Generate code:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

#### 1.4 `models/fcm_token_local_model.dart`

**Vai trò:** Model cho local storage (không dùng freezed vì đơn giản).

**Class:** `FcmTokenLocalModel`

**Properties:**
```dart
final String token;         // FCM token
final DateTime lastUpdated; // Last update time
final bool isSynced;        // Sync status
```

**Methods:**

```dart
// JSON serialization
factory FcmTokenLocalModel.fromJson(Map<String, dynamic> json)
Map<String, dynamic> toJson()

// Copy with changes
FcmTokenLocalModel copyWith({...})

// Business logic
bool isExpiringSoon()  // >200 days = need refresh
```

**Lý do không dùng freezed:**
- Đơn giản, không cần union types
- Không cần equality comparison phức tạp
- Performance (ít overhead hơn)

---

#### 1.5 `repositories/fcm_repository.dart`

**Vai trò:** Coordinate giữa local và remote data sources.

**Class:** `FcmRepository`

**Dependencies:**
```dart
final FcmLocalDataSource _localDataSource;
final FcmApiService _apiService;
final TokenStorage _tokenStorage;  // From core/storage
```

**Methods:**

##### `getStoredToken()`
```dart
Future<FcmTokenLocalModel?> getStoredToken()
```
- Lấy token từ local storage
- Return null nếu chưa có

##### `saveTokenLocally(String token)`
```dart
Future<void> saveTokenLocally(String token)
```
- Tạo `FcmTokenLocalModel` mới
- Set `isSynced = false`
- Lưu vào SharedPreferences

##### `syncTokenToServer(String token)`
```dart
Future<bool> syncTokenToServer(String token)
```
**Flow:**
1. Get access token từ `TokenStorage`
2. Nếu null → return false (chưa login)
3. Call API `_apiService.syncToken()`
4. Nếu success → update local `isSynced = true`
5. Return true/false

##### `needsSync()`
```dart
Future<bool> needsSync()
```
- Check token có cần sync không
- Return `!token.isSynced`

##### `clearToken()`
```dart
Future<void> clearToken()
```
- Xóa token khỏi local storage
- Gọi khi logout

##### `requestNewToken()`
```dart
Future<String?> requestNewToken()
```
- Request token mới từ Firebase
- Lưu local
- Return token

##### `refreshToken()`
```dart
Future<String?> refreshToken()
```
- Delete token cũ
- Request token mới
- Dùng khi token >200 ngày

**Lý do tách repository:**
- **Coordination**: Orchestrate multiple data sources
- **Caching**: Local cache trước khi call API
- **Offline support**: Lưu local ngay cả khi sync fail
- **Testability**: Mock data sources dễ dàng

---

#### 1.6 `providers/fcm_providers.dart`

**Vai trò:** Riverpod providers cho data layer.

**Providers:**

##### `fcmApiServiceProvider`
```dart
final fcmApiServiceProvider = Provider<FcmApiService>((ref) {
  return FcmApiService(
    dio: Dio(),
    baseUrl: 'http://your-backend.com',
  );
});
```

##### `fcmLocalDataSourceProvider`
```dart
final fcmLocalDataSourceProvider = Provider<FcmLocalDataSource>((ref) {
  throw UnimplementedError('Override in main.dart');
});
```
**⚠️ Phải override trong `main.dart`:**
```dart
fcmLocalDataSourceProvider.overrideWithValue(
  FcmLocalDataSource(prefs: await SharedPreferences.getInstance()),
)
```

##### `fcmRepositoryProvider`
```dart
final fcmRepositoryProvider = Provider<FcmRepository>((ref) {
  return FcmRepository(
    localDataSource: ref.watch(fcmLocalDataSourceProvider),
    apiService: ref.watch(fcmApiServiceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});
```

**Dependency graph:**
```
fcmRepositoryProvider
├── fcmLocalDataSourceProvider (override needed)
├── fcmApiServiceProvider
└── tokenStorageProvider (from core/storage)
```

---

### 2. Models Layer (`models/`)

#### 2.1 `models/fcm_state.dart`

**Vai trò:** Immutable state cho FCM service.

**Class:** `FcmState` (freezed)

**Properties:**

```dart
@freezed
class FcmState with _$FcmState {
  const factory FcmState({
    @Default(false) bool isInitialized,      // FCM initialized?
    @Default(false) bool permissionGranted,  // Permission granted?
    String? currentToken,                    // Current token
    @Default(false) bool isSyncing,          // Syncing in progress?
    @Default(0) int syncRetryCount,          // Retry attempts
    String? error,                           // Last error
  }) = _FcmState;
}
```

**State transitions:**

```
Initial State:
FcmState(isInitialized: false, permissionGranted: false)

After Initialize:
FcmState(isInitialized: true, permissionGranted: true, currentToken: "xxx")

During Sync:
FcmState(..., isSyncing: true)

After Sync Success:
FcmState(..., isSyncing: false, syncRetryCount: 0)

After Sync Failed:
FcmState(..., isSyncing: false, syncRetryCount: 1)
```

**Lý do dùng freezed:**
- ✅ Immutable (không thay đổi state trực tiếp)
- ✅ Auto `copyWith` cho state updates
- ✅ Pattern matching (nếu cần union types sau này)
- ✅ `==` comparison tự động

---

### 3. Providers Layer (`providers/`)

#### 3.1 `providers/fcm_notifier.dart`

**Vai trò:** ViewModel - Quản lý business logic và state.

**Class:** `FcmNotifier extends StateNotifier<FcmState>`

**Methods:**

##### `initialize()`
```dart
Future<void> initialize()
```

**Flow:**
1. Check if already initialized → return
2. Request FCM permission
3. Update state with permission status
4. If denied → return
5. Get initial token from Firebase
6. Handle token với `_handleNewToken()`
7. Listen `onTokenRefresh` stream
8. Set `isInitialized = true`

**State changes:**
```
FcmState(isInitialized: false)
  ↓ request permission
FcmState(permissionGranted: true)
  ↓ get token
FcmState(currentToken: "xxx")
  ↓
FcmState(isInitialized: true)
```

##### `_handleNewToken(String token)`
```dart
Future<void> _handleNewToken(String token)
```

**Flow:**
1. Update state với token mới
2. Save token locally
3. Try sync to server
4. Nếu fail → schedule retry

**Internal method** (không expose ra ngoài)

##### `_syncToken(String token)`
```dart
Future<void> _syncToken(String token)
```

**Flow:**
1. Check if already syncing → return
2. Set `isSyncing = true`
3. Call `repository.syncTokenToServer()`
4. If success:
   - Set `isSyncing = false`
   - Reset `syncRetryCount = 0`
5. If failed:
   - Set `isSyncing = false`
   - Schedule retry

##### `_scheduleRetry(String token)`
```dart
void _scheduleRetry(String token)
```

**Retry mechanism:**
- Max 3 attempts
- Exponential backoff: 30s → 60s → 90s
- Update `syncRetryCount` in state
- Schedule `Future.delayed()` để retry

**Example:**
```
Attempt 1: 30s delay
Attempt 2: 60s delay
Attempt 3: 90s delay
Max reached: Stop retrying
```

##### `syncAfterLogin()`
```dart
Future<void> syncAfterLogin()
```

**Public method** - Gọi sau khi login thành công.

**Flow:**
1. Check `repository.needsSync()`
2. Nếu false → return (already synced)
3. Get stored token
4. Sync to server

**Use case:**
```dart
// After login success
await ref.read(fcmServiceProvider.notifier).syncAfterLogin();
```

##### `checkTokenFreshness()`
```dart
Future<void> checkTokenFreshness()
```

**Public method** - Check và refresh token nếu cần.

**Flow:**
1. Get stored token
2. Check `token.isExpiringSoon()` (>200 days)
3. Nếu true:
   - Delete token cũ
   - Request token mới
   - Handle token mới

**Use case:**
```dart
// Periodic check (e.g., on app resume)
await ref.read(fcmServiceProvider.notifier).checkTokenFreshness();
```

##### `onLogout()`
```dart
Future<void> onLogout()
```

**Public method** - Clear token khi logout.

**Flow:**
1. Call `repository.clearToken()`
2. Update state: `currentToken = null`, `syncRetryCount = 0`

**Use case:**
```dart
// Before logout
await ref.read(fcmServiceProvider.notifier).onLogout();
```

---

#### 3.2 Provider definition

```dart
final fcmServiceProvider =
    StateNotifierProvider<FcmNotifier, FcmState>((ref) {
  final repository = ref.watch(fcmRepositoryProvider);
  return FcmNotifier(repository);
});
```

**Type:**
- `StateNotifierProvider` - Cho stateful logic
- `<FcmNotifier, FcmState>` - Notifier type và State type
- Auto rebuild UI khi state changes

---

## Data Flow

### 1. Token Generation Flow

```
Firebase FCM
    │
    │ onTokenRefresh
    ▼
FcmNotifier._handleNewToken()
    │
    ├─► repository.saveTokenLocally()
    │       │
    │       └─► localDataSource.saveToken()
    │               │
    │               └─► SharedPreferences
    │
    └─► FcmNotifier._syncToken()
            │
            └─► repository.syncTokenToServer()
                    │
                    ├─► tokenStorage.getAccessToken()
                    │
                    └─► apiService.syncToken()
                            │
                            └─► Backend API
                                    │
                                    ├─► Success ✅
                                    │       │
                                    │       └─► Update local isSynced=true
                                    │
                                    └─► Failed ❌
                                            │
                                            └─► Schedule retry
```

### 2. Login Flow

```
User Login Success
    │
    └─► fcmNotifier.syncAfterLogin()
            │
            └─► repository.needsSync()
                    │
                    ├─► Yes → Sync token
                    │       │
                    │       └─► _syncToken()
                    │
                    └─► No → Skip
```

### 3. Logout Flow

```
User Logout
    │
    └─► fcmNotifier.onLogout()
            │
            └─► repository.clearToken()
                    │
                    └─► localDataSource.clearToken()
                            │
                            └─► Remove from SharedPreferences
```

### 4. Token Refresh Flow (Expiring)

```
App Resume / Periodic Check
    │
    └─► fcmNotifier.checkTokenFreshness()
            │
            └─► repository.getStoredToken()
                    │
                    └─► token.isExpiringSoon()? (>200 days)
                            │
                            └─► Yes → repository.refreshToken()
                                    │
                                    ├─► Firebase.deleteToken()
                                    │
                                    └─► Firebase.getToken()
                                            │
                                            └─► _handleNewToken()
```

---

## Cách sử dụng

### Setup trong `main.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/fcm/fcm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase
  await Firebase.initializeApp();
  
  // 2. Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // 3. Create ProviderContainer with overrides
  final container = ProviderContainer(
    overrides: [
      // Override local data source with initialized SharedPreferences
      fcmLocalDataSourceProvider.overrideWithValue(
        FcmLocalDataSource(prefs: prefs),
      ),
    ],
  );
  
  // 4. Initialize FCM service
  await container.read(fcmServiceProvider.notifier).initialize();
  
  // 5. Run app with UncontrolledProviderScope
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(),
    ),
  );
}
```

### Trong Auth Flow

#### After Login
```dart
// In LoginScreen or AuthNotifier
Future<void> handleLogin() async {
  // ... existing login logic
  
  // After successful login
  if (loginSuccess) {
    // Sync FCM token
    await ref.read(fcmServiceProvider.notifier).syncAfterLogin();
  }
}
```

#### Before Logout
```dart
// In ProfileScreen or AuthNotifier
Future<void> handleLogout() async {
  // Clear FCM token first
  await ref.read(fcmServiceProvider.notifier).onLogout();
  
  // ... existing logout logic
}
```

### Hiển thị Token Status (Debug)

```dart
class DebugFcmScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fcmState = ref.watch(fcmServiceProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('FCM Status')),
      body: Column(
        children: [
          Text('Initialized: ${fcmState.isInitialized}'),
          Text('Permission: ${fcmState.permissionGranted}'),
          Text('Token: ${fcmState.currentToken?.substring(0, 20)}...'),
          Text('Syncing: ${fcmState.isSyncing}'),
          Text('Retry: ${fcmState.syncRetryCount}/3'),
          if (fcmState.error != null)
            Text('Error: ${fcmState.error}', 
                style: TextStyle(color: Colors.red)),
          
          ElevatedButton(
            onPressed: () {
              ref.read(fcmServiceProvider.notifier).syncAfterLogin();
            },
            child: Text('Force Sync'),
          ),
        ],
      ),
    );
  }
}
```

### Periodic Token Check (Optional)

```dart
class MyApp extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check token freshness when app resumes
      ref.read(fcmServiceProvider.notifier).checkTokenFreshness();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(...);
  }
}
```

---

## Testing

### Unit Test: FcmRepository

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFcmLocalDataSource extends Mock implements FcmLocalDataSource {}
class MockFcmApiService extends Mock implements FcmApiService {}
class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late FcmRepository repository;
  late MockFcmLocalDataSource mockLocal;
  late MockFcmApiService mockApi;
  late MockTokenStorage mockTokenStorage;
  
  setUp(() {
    mockLocal = MockFcmLocalDataSource();
    mockApi = MockFcmApiService();
    mockTokenStorage = MockTokenStorage();
    
    repository = FcmRepository(
      localDataSource: mockLocal,
      apiService: mockApi,
      tokenStorage: mockTokenStorage,
    );
  });
  
  group('saveTokenLocally', () {
    test('should save token to local storage', () async {
      // Arrange
      const token = 'test-token';
      
      // Act
      await repository.saveTokenLocally(token);
      
      // Assert
      verify(mockLocal.saveToken(any)).called(1);
    });
  });
  
  group('syncTokenToServer', () {
    test('should return false if user not logged in', () async {
      // Arrange
      when(mockTokenStorage.getAccessToken()).thenAnswer((_) async => null);
      
      // Act
      final result = await repository.syncTokenToServer('test-token');
      
      // Assert
      expect(result, false);
      verifyNever(mockApi.syncToken(fcmToken: any, accessToken: any));
    });
    
    test('should sync token and update local when success', () async {
      // Arrange
      when(mockTokenStorage.getAccessToken()).thenAnswer((_) async => 'access-token');
      when(mockApi.syncToken(
        fcmToken: any,
        accessToken: any,
      )).thenAnswer((_) async => SaveFcmTokenResponse(
        code: 200,
        message: 'success',
      ));
      
      // Act
      final result = await repository.syncTokenToServer('test-token');
      
      // Assert
      expect(result, true);
      verify(mockApi.syncToken(
        fcmToken: 'test-token',
        accessToken: 'access-token',
      )).called(1);
      verify(mockLocal.saveToken(any)).called(1);
    });
  });
}
```

### Widget Test: FCM Status Display

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('should display FCM status', (tester) async {
    // Arrange
    final container = ProviderContainer(
      overrides: [
        fcmServiceProvider.overrideWith((ref) {
          return FcmNotifier(mockRepository)
            ..state = FcmState(
              isInitialized: true,
              permissionGranted: true,
              currentToken: 'test-token-abc123',
            );
        }),
      ],
    );
    
    // Act
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: DebugFcmScreen()),
      ),
    );
    
    // Assert
    expect(find.text('Initialized: true'), findsOneWidget);
    expect(find.text('Permission: true'), findsOneWidget);
    expect(find.textContaining('test-token'), findsOneWidget);
  });
}
```

---

## Tổng kết

### ✅ Ưu điểm của kiến trúc này

1. **Separation of Concerns**
   - Data sources riêng: API, Local
   - Repository coordinate data
   - ViewModel chỉ lo business logic
   - View chỉ lo UI

2. **Testability**
   - Mỗi layer mock dễ dàng
   - Unit test không cần Firebase
   - Widget test với mock state

3. **Maintainability**
   - Code clean, dễ đọc
   - Single Responsibility mỗi class
   - Easy to extend (add SMS channel, Voice)

4. **Scalability**
   - Thêm data source mới không ảnh hưởng repository
   - Thêm business logic mới trong notifier
   - Swap storage (SharedPreferences → Hive) dễ dàng

5. **Follow Project Convention**
   - Giống auth feature structure
   - Dùng Riverpod như toàn project
   - Freezed cho immutable state

### 📋 Checklist trước khi sử dụng

- [ ] Generate freezed code: `flutter pub run build_runner build`
- [ ] Configure Firebase (`google-services.json`)
- [ ] Update backend URL trong `fcm_providers.dart`
- [ ] Override `fcmLocalDataSourceProvider` trong `main.dart`
- [ ] Initialize FCM trong `main.dart`
- [ ] Call `syncAfterLogin()` sau khi login
- [ ] Call `onLogout()` trước khi logout
- [ ] Test với device thật (FCM không chạy trên emulator tốt)

### 🔗 Dependencies cần thiết

```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_messaging: ^15.1.5
  flutter_riverpod: ^2.6.1
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  dio: ^5.4.0
  shared_preferences: ^2.3.3

dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.4.6
  json_serializable: ^6.7.0
  mockito: ^5.4.0
```

---

**Tài liệu này cung cấp đầy đủ thông tin để hiểu và sử dụng FCM service trong project.** 🚀
