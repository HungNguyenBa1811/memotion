# Firebase Cloud Messaging (FCM) Token Management Strategy

## 📋 Table of Contents
- [Kiến trúc tổng quan](#kiến-trúc-tổng-quan)
- [Vai trò các thành phần](#vai-trò-các-thành-phần)
- [Flow hoạt động](#flow-hoạt-động)
- [Xử lý Token Lifecycle](#xử-lý-token-lifecycle)
- [Edge Cases & Solutions](#edge-cases--solutions)
- [Implementation Guide](#implementation-guide)
- [Best Practices](#best-practices)

---

## Kiến trúc tổng quan

```
┌─────────────────────┐
│   Android Device    │
│  (Flutter App)      │
│                     │
│  ┌──────────────┐   │
│  │ FCM SDK      │   │  1. Generate Token
│  │ (Firebase)   │───┼──────────────────┐
│  └──────────────┘   │                  │
│         │           │                  ▼
│         │ 2. onNewToken()      ┌──────────────────┐
│         ▼           │          │  FCM Servers     │
│  ┌──────────────┐   │          │  (Google)        │
│  │SharedPrefs   │   │          └──────────────────┐
│  │(Local)       │   │                             │
│  └──────────────┘   │                             │
│         │           │                             │
│         │ 3. API Call                             │
│         ▼           │                             │
└─────────────────────┘                             │
         │                                          │
         │ POST /api/v1/users/fcm-token            │
         ▼                                          │
┌─────────────────────┐                             │
│   Backend Server    │                             │
│   (FastAPI)         │                             │
│                     │                             │
│  ┌──────────────┐   │                             │
│  │ PostgreSQL   │   │  4. Store Token             │
│  │ users table  │◄──┼─────────────────            │
│  └──────────────┘   │                             │
│         │           │                             │
│         │ 5. Send Push                            │
│         └───────────┼─────────────────────────────┘
│                     │
└─────────────────────┘
```

---

## Vai trò các thành phần

### 1. **Frontend (Flutter/Android)**
**Trách nhiệm:**
- ✅ Generate FCM token (thông qua FCM SDK)
- ✅ Lưu token vào SharedPreferences/LocalStorage
- ✅ Sync token lên backend qua API
- ✅ Handle token refresh events (`onNewToken()`)
- ✅ Retry mechanism khi API call fail

**KHÔNG làm:**
- ❌ Backend không generate token
- ❌ Backend không quyết định khi nào token thay đổi

### 2. **Backend (FastAPI + PostgreSQL)**
**Trách nhiệm:**
- ✅ Nhận token từ frontend qua API `POST /api/v1/users/fcm-token`
- ✅ Lưu token vào database với timestamp
- ✅ Sử dụng token để gửi push notification qua FCM Admin SDK
- ✅ Handle expired/invalid tokens

**KHÔNG làm:**
- ❌ Không tự generate token
- ❌ Không quản lý lifecycle của token (Firebase quản lý)

### 3. **FCM Servers (Google)**
**Trách nhiệm:**
- ✅ Generate token dựa trên: `Firebase Project ID + Device ID + App Signature`
- ✅ Deliver notifications đến device
- ✅ Tự động rotate token khi cần (security, expiry)
- ✅ Handle device connectivity

---

## Flow hoạt động

### Flow 1: Initial Token Generation (App mới cài đặt)
```
1. User cài đặt app
   ↓
2. App khởi động → Firebase SDK initialize
   ↓
3. FCM SDK tự động request token từ FCM Servers
   ↓
4. FCM Servers generate token mới
   ↓
5. onNewToken(token) được gọi trong FirebaseMessagingService
   ↓
6. Frontend lưu token vào SharedPreferences
   ↓
7. Frontend gọi API: POST /api/v1/users/fcm-token
   Body: { "fcm_token": "xxx" }
   ↓
8. Backend lưu vào DB:
   UPDATE users SET 
     register_fcm_token = 'xxx',
     update_fcm_time = NOW()
   WHERE user_id = current_user
```

### Flow 2: Token Refresh (Token thay đổi)
```
Triggers:
- App reinstall
- Clear app data
- Device restore
- Token expired (270 ngày)
- FCM force refresh

1. FCM SDK detect token cần refresh
   ↓
2. FCM Servers generate token mới
   ↓
3. onNewToken(newToken) được gọi
   ↓
4. Frontend:
   - Lưu newToken vào SharedPreferences
   - Replace old token
   ↓
5. Frontend gọi API: POST /api/v1/users/fcm-token
   Body: { "fcm_token": "newToken" }
   ↓
6. Backend update DB với token mới
```

### Flow 3: Gửi Push Notification
```
1. Backend Scheduler detect reminder due
   (status='SCHEDULED' AND remind_time <= NOW())
   ↓
2. Backend lấy user.register_fcm_token từ DB
   ↓
3. Backend gọi FCM Admin SDK:
   firebase_admin.messaging.send(
     message=Message(
       token=user.register_fcm_token,
       notification=Notification(
         title="Task Reminder",
         body="Your task is due in 15 minutes"
       )
     )
   )
   ↓
4. FCM Servers deliver notification đến device
   ↓
5. Device hiển thị notification
```

---

## Xử lý Token Lifecycle

### Các trường hợp Token thay đổi

| Scenario | Tại sao token thay đổi | Trigger Point | Frontend Action | Backend Action |
|----------|----------------------|---------------|----------------|----------------|
| **App mới cài** | Token hoàn toàn mới cho device | App first launch | `onNewToken()` → API call | Lưu token mới |
| **Reinstall** | Token mới sau uninstall | App launch sau install | `onNewToken()` → API call | Lưu token mới |
| **Clear app data** | Token reset về initial | App launch sau clear | `onNewToken()` → API call | Lưu token mới |
| **Device restore** | Token mới cho device mới | App launch sau restore | `onNewToken()` → API call | Lưu token mới |
| **Token expired (270 ngày)** | FCM tự expire inactive token | FCM detect expire | `onNewToken()` → API call | Lưu token mới |
| **FCM force refresh** | Security compromise | FCM security event | `onNewToken()` → API call | Lưu token mới |
| **Hardware failure** | FCM generate mới để bypass | Device recovery | `onNewToken()` → API call | Lưu token mới |

---

## Edge Cases & Solutions

### 🚨 Problem 1: Miss Notification - Token Sync Failed

**Nguyên nhân:**
- `onNewToken()` gọi nhưng network fail
- API timeout/error
- App killed before sync complete

**Giải pháp:**

#### Frontend (Flutter):
```dart
class FCMTokenManager {
  static const String TOKEN_KEY = 'fcm_token';
  static const String SYNCED_KEY = 'fcm_token_synced';
  
  // 1. Lưu token và đánh dấu chưa sync
  Future<void> onNewToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
    await prefs.setBool(SYNCED_KEY, false);  // ← Đánh dấu chưa sync
    
    // Sync ngay lập tức
    await syncTokenToServer(token);
  }
  
  // 2. Retry mechanism với exponential backoff
  Future<void> syncTokenToServer(String token) async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      final response = await dio.post(
        '/api/v1/users/fcm-token',
        data: {'fcm_token': token},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'}
        )
      );
      
      if (response.statusCode == 200) {
        await prefs.setBool(SYNCED_KEY, true);  // ← Đánh dấu đã sync
      }
    } catch (e) {
      // Lỗi → schedule retry sau 30s, 1m, 5m, 15m
      scheduleRetry(token);
    }
  }
  
  // 3. Check và retry khi app launch
  Future<void> checkAndSyncOnAppLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(TOKEN_KEY);
    final synced = prefs.getBool(SYNCED_KEY) ?? false;
    
    if (token != null && !synced) {
      await syncTokenToServer(token);  // ← Retry sync
    }
  }
}
```

#### Backend API Enhancement:
```python
# app/api/api_user.py
@router.post("/fcm-token", dependencies=[Depends(login_required)])
def save_fcm_token(
    token_data: SaveFcmTokenRequest,
    current_user: User = Depends(UserService.get_current_user),
    user_service: UserService = Depends()
) -> Any:
    """
    Idempotent API - có thể gọi nhiều lần với cùng token
    """
    try:
        # Check if token already exists and same
        if (current_user.register_fcm_token == token_data.fcm_token and 
            current_user.update_fcm_time and 
            (datetime.now() - current_user.update_fcm_time).seconds < 60):
            # Token giống và mới update trong 60s → skip
            return DataResponse().success_response(data=current_user)
        
        # Update token
        updated_user = user_service.update_fcm_token(
            user=current_user,
            fcm_token=token_data.fcm_token
        )
        return DataResponse().success_response(data=updated_user)
    except Exception as e:
        logger.error(f"save_fcm_token error: {str(e)}")
        raise CustomException(http_code=500, code='500', message=str(e))
```

---

### 🚨 Problem 2: User chưa login khi onNewToken() gọi

**Nguyên nhân:**
- App mới cài → token generate trước khi user login
- User logout → token vẫn còn nhưng không có auth

**Giải pháp:**

```dart
// Frontend
class FCMTokenManager {
  Future<void> onNewToken(String token) async {
    // 1. Luôn lưu local first
    await saveToSharedPreferences(token);
    
    // 2. Check nếu đã login → sync ngay
    if (await isUserLoggedIn()) {
      await syncTokenToServer(token);
    }
    // 3. Nếu chưa login → sẽ sync sau khi login
  }
  
  Future<void> onUserLogin() async {
    // Sau khi login thành công
    final token = await getLocalToken();
    if (token != null) {
      await syncTokenToServer(token);  // ← Sync token đã có
    }
  }
}
```

---

### 🚨 Problem 3: Token expired nhưng device offline

**Nguyên nhân:**
- Device không connect Internet > 270 ngày
- `onNewToken()` không trigger vì không connect FCM

**Giải pháp:**

```dart
// Frontend: Periodic token refresh
class FCMTokenManager {
  Future<void> checkTokenFreshness() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt('token_last_update') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Nếu token > 200 ngày (trước expiry 270 ngày)
    if (now - lastUpdate > 200 * 24 * 60 * 60 * 1000) {
      // Force refresh token
      await FirebaseMessaging.instance.deleteToken();
      final newToken = await FirebaseMessaging.instance.getToken();
      await onNewToken(newToken!);
    }
  }
}
```

---

## Implementation Guide

### Phase 1: Frontend (Flutter) Implementation

**File: `lib/core/services/fcm_service.dart`**
```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();
  
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final Dio _dio = Dio();
  
  // Initialize FCM
  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get initial token
      String? token = await _fcm.getToken();
      if (token != null) {
        await _handleNewToken(token);
      }
      
      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen(_handleNewToken);
    }
  }
  
  // Handle new/refreshed token
  Future<void> _handleNewToken(String token) async {
    print('[FCM] New token received: ${token.substring(0, 20)}...');
    
    // 1. Save to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
    await prefs.setBool('fcm_token_synced', false);
    await prefs.setInt('token_last_update', DateTime.now().millisecondsSinceEpoch);
    
    // 2. Sync to server with retry
    await _syncTokenToServer(token);
  }
  
  // Sync token to backend
  Future<void> _syncTokenToServer(String token, {int retryCount = 0}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      if (accessToken == null) {
        print('[FCM] User not logged in, will sync after login');
        return;
      }
      
      final response = await _dio.post(
        'http://your-backend.com/api/v1/users/fcm-token',
        data: {'fcm_token': token},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'}
        )
      );
      
      if (response.statusCode == 200) {
        await prefs.setBool('fcm_token_synced', true);
        print('[FCM] Token synced to server successfully');
      }
    } catch (e) {
      print('[FCM] Failed to sync token: $e');
      
      // Retry with exponential backoff (max 3 retries)
      if (retryCount < 3) {
        final delay = Duration(seconds: 30 * (retryCount + 1));
        Future.delayed(delay, () {
          _syncTokenToServer(token, retryCount: retryCount + 1);
        });
      }
    }
  }
  
  // Call after successful login
  Future<void> syncTokenAfterLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('fcm_token');
    final synced = prefs.getBool('fcm_token_synced') ?? false;
    
    if (token != null && !synced) {
      await _syncTokenToServer(token);
    }
  }
  
  // Call on app launch
  Future<void> checkAndSyncOnLaunch() async {
    await syncTokenAfterLogin();
  }
}
```

**File: `lib/main.dart`**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize FCM
  final fcmService = FCMService();
  await fcmService.initialize();
  await fcmService.checkAndSyncOnLaunch();
  
  runApp(MyApp());
}
```

---

### Phase 2: Backend Implementation

**Backend đã có sẵn:**
- ✅ API endpoint: `POST /api/v1/users/fcm-token` (đã implement)
- ✅ Database fields: `register_fcm_token`, `update_fcm_time` (đã có)
- ✅ Notification scheduler service (đã có)

**Cần thêm: FCM Admin SDK để gửi notification**

**File: `app/services/srv_fcm.py`**
```python
import logging
import firebase_admin
from firebase_admin import credentials, messaging
from typing import Optional

logger = logging.getLogger(__name__)


class FCMService:
    """Service to send push notifications via Firebase Cloud Messaging"""
    
    _instance = None
    _initialized = False
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if not FCMService._initialized:
            self._initialize_firebase()
            FCMService._initialized = True
    
    def _initialize_firebase(self):
        """Initialize Firebase Admin SDK"""
        try:
            # TODO: Place your firebase-adminsdk.json in project root
            cred = credentials.Certificate("path/to/firebase-adminsdk.json")
            firebase_admin.initialize_app(cred)
            logger.info("[FCM] Firebase Admin SDK initialized successfully")
        except Exception as e:
            logger.error(f"[FCM] Failed to initialize Firebase Admin SDK: {str(e)}")
    
    def send_notification(
        self,
        fcm_token: str,
        title: str,
        body: str,
        data: Optional[dict] = None
    ) -> bool:
        """
        Send push notification to a specific device.
        
        Args:
            fcm_token: User's FCM registration token
            title: Notification title
            body: Notification body
            data: Optional custom data payload
            
        Returns:
            bool: True if sent successfully, False otherwise
        """
        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data=data or {},
                token=fcm_token,
                android=messaging.AndroidConfig(
                    priority='high',
                    notification=messaging.AndroidNotification(
                        sound='default',
                        click_action='FLUTTER_NOTIFICATION_CLICK'
                    )
                )
            )
            
            response = messaging.send(message)
            logger.info(f"[FCM] Successfully sent message: {response}")
            return True
            
        except messaging.UnregisteredError:
            logger.warning(f"[FCM] Token unregistered/expired: {fcm_token[:20]}...")
            return False
        except messaging.InvalidArgumentError as e:
            logger.error(f"[FCM] Invalid argument: {str(e)}")
            return False
        except Exception as e:
            logger.error(f"[FCM] Failed to send notification: {str(e)}")
            return False


fcm_service = FCMService()
```

**Update Notification Scheduler to use FCM:**

**File: `app/services/srv_notification.py`**
```python
# Add import
from app.services.srv_fcm import fcm_service
from app.repository.repo_user import UserRepository

def _send_notification(self, reminder: TaskReminder, db):
    """Send notification via FCM"""
    try:
        # Get user to retrieve FCM token
        user_repo = UserRepository(db_session=db)
        user = user_repo.get_by_id(reminder.user_id)
        
        if not user or not user.register_fcm_token:
            raise Exception("User not found or FCM token not available")
        
        # Get task details for notification
        task_repo = TaskRepository(db_session=db)
        task = task_repo.get_task_by_id(reminder.task_id)
        
        if not task:
            raise Exception("Task not found")
        
        # Send notification based on channel
        if reminder.channel == 'APP_NOTIFICATION':
            success = fcm_service.send_notification(
                fcm_token=user.register_fcm_token,
                title="Task Reminder",
                body=f"{task.title} is due in 15 minutes",
                data={
                    'task_id': str(task.task_id),
                    'reminder_id': str(reminder.reminder_id),
                    'type': 'task_reminder'
                }
            )
            
            if not success:
                raise Exception("FCM send failed - token may be expired")
        
        elif reminder.channel == 'SMS':
            # TODO: Implement SMS sending
            logger.info(f"[SMS] Would send SMS to user {user.user_id}")
            
        elif reminder.channel == 'VOICE_CALL':
            # TODO: Implement voice call
            logger.info(f"[VOICE] Would call user {user.user_id}")
        
        logger.info(f"[NOTIFICATION] Sent {reminder.channel} to user {user.user_id}")
        
    except Exception as e:
        logger.error(f"[NOTIFICATION] Send failed: {str(e)}")
        raise
```

---

## Best Practices

### ✅ DO's

1. **Luôn lưu token local trước khi sync server**
   - SharedPreferences là source of truth
   - Backend chỉ là backup

2. **Implement retry mechanism với exponential backoff**
   - Network có thể fail bất cứ lúc nào
   - Retry: 30s → 1m → 5m → 15m

3. **Check và sync token mỗi khi app launch**
   - User có thể miss sync do app killed
   - Re-sync nếu `fcm_token_synced = false`

4. **Sync token sau khi login thành công**
   - Token có thể generate trước khi login
   - Sync ngay sau khi có auth token

5. **Handle token expired gracefully**
   - Catch `UnregisteredError` từ FCM
   - Request refresh token từ client

6. **Log chi tiết mọi event**
   - Token generation
   - Sync attempts
   - Notification sending
   - Errors

### ❌ DON'Ts

1. **KHÔNG để backend generate token**
   - Chỉ FCM SDK mới có quyền generate
   - Backend chỉ nhận và lưu

2. **KHÔNG ignore onNewToken() callback**
   - Đây là event quan trọng nhất
   - Miss event này = miss notifications

3. **KHÔNG sync token mà không có retry**
   - Network luôn không ổn định
   - Cần retry mechanism

4. **KHÔNG quên update timestamp**
   - `update_fcm_time` giúp track freshness
   - Có thể dùng để detect stale tokens

5. **KHÔNG gửi push nếu token NULL**
   - Check token trước khi gọi FCM
   - Handle gracefully nếu không có token

---

## Testing Checklist

### Frontend Tests
- [ ] Token generate on first app launch
- [ ] Token saved to SharedPreferences
- [ ] API call to backend after token generation
- [ ] Retry mechanism works on network failure
- [ ] Token syncs after login
- [ ] Token syncs on app relaunch if previously failed
- [ ] onNewToken() triggered on app reinstall
- [ ] Token cleared on logout

### Backend Tests
- [ ] API accepts valid FCM token
- [ ] Token saved to database with timestamp
- [ ] Duplicate token updates don't create errors
- [ ] Invalid token format rejected
- [ ] Notification sending works with valid token
- [ ] Expired token handled gracefully
- [ ] Scheduler picks up due reminders
- [ ] Status updates (SCHEDULED → SENT/ERROR)

### Integration Tests
- [ ] End-to-end: App install → Token → Backend → Push works
- [ ] Token refresh → Backend update → Push still works
- [ ] App reinstall → New token → Old push stops, new works
- [ ] Multiple devices → Each has unique token
- [ ] Token expires → New token → Push resumes

---

## FAQ

**Q: Frontend có nên tự động refresh token định kỳ không?**
A: Không cần. FCM SDK tự động handle việc này. Chỉ cần listen `onTokenRefresh`.

**Q: Có nên lưu token expiry date không?**
A: Không cần. FCM không expose expiry date. Chỉ cần sync token mới khi `onNewToken()` gọi.

**Q: Backend có nên validate token format không?**
A: Có, validate độ dài (>20 chars) và lưu timestamp. Không cần validate với FCM API (tốn resources).

**Q: Có nên xóa token cũ khi user logout không?**
A: Tùy product decision:
- Xóa: User không nhận push sau logout (secure hơn)
- Giữ: User vẫn nhận push (better engagement)

**Q: Làm sao biết token đã expired?**
A: Backend gọi FCM API → nhận error `UnregisteredError` → mark token invalid → request client refresh.

---

## Monitoring & Alerts

### Metrics cần track
1. **Token Sync Success Rate**: % API calls thành công
2. **Token Age**: Thời gian từ lúc token update lần cuối
3. **Push Delivery Rate**: % notifications delivered thành công
4. **Failed Token Count**: Số lượng tokens expired/invalid

### Alerts cần setup
- Token sync failure rate > 5%
- Push delivery rate < 90%
- Có tokens > 200 ngày không update

---

## Conclusion

Với kiến trúc này:
- ✅ Frontend hoàn toàn kiểm soát token generation
- ✅ Backend chỉ làm persistence layer
- ✅ Retry mechanism đảm bảo không miss sync
- ✅ Multiple safety nets để tránh miss notifications
- ✅ Clear separation of concerns
- ✅ Scalable và maintainable

**Next Steps:**
1. Review document này
2. Implement frontend FCM service
3. Add Firebase Admin SDK to backend
4. Setup monitoring dashboard
5. Test toàn bộ flow
