# Ask AI - Voice Command Feature Implementation Plan

## Overview

Tích hợp Voice Command vào nút **Ask AI** trên Patient Home Screen. Luồng: Nhấn Ask AI → Xin quyền mic → Ghi âm với waveform animation → Dừng → Gọi API → Nhận key → Điều hướng tự động.

---

## API Spec (POST `/api/voice-command/process`)

- **Request:** `multipart/form-data` với field `voice_audio` (binary: wav/mp3/m4a)
- **Response:**
```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "audio": "<base64 hoặc URL audio phản hồi TTS>",
    "key": "HOME",
    "transcript": "Đưa tôi về trang chủ"
  }
}
```

## Navigation Key Enum

| Key từ API          | Route điều hướng                                                                 |
|---------------------|----------------------------------------------------------------------------------|
| `HOME`              | `/home`                                                                          |
| `MEDICATION`        | `/medication`                                                                    |
| `MEDICATION_DETAIL` | `/medication` (không có trang detail riêng → fallback medication main)            |
| `PHYSICAL`          | `/workout`                                                                       |
| `NUTRITION`         | `/nutrition`                                                                     |
| `START_PHYSICAL`    | `/workout-detail` với workout = bài tập đầu tiên (ưu tiên bài chưa tập)         |

---

## Kiến trúc & Files cần tạo/sửa

### Phase 1: Data Layer

#### 1.1 Model - `lib/features/voice_command/models/voice_command_response.dart`
```dart
class VoiceCommandResponse {
  final String? audio;      // base64 hoặc URL audio TTS
  final String key;          // navigation key enum
  final String? transcript;  // text đã chuyển từ giọng nói
}
```

#### 1.2 Enum - `lib/features/voice_command/models/voice_command_key.dart`
```dart
enum VoiceCommandKey {
  home('HOME'),
  medication('MEDICATION'),
  medicationDetail('MEDICATION_DETAIL'),
  physical('PHYSICAL'),
  nutrition('NUTRITION'),
  startPhysical('START_PHYSICAL'),
  unknown('UNKNOWN');
}
```
- Factory `fromString(String key)` để parse từ API response, fallback `unknown`.

#### 1.3 API Constant - sửa `lib/core/network/api_constants.dart`
```dart
// Voice Command Endpoints
static const String voiceCommandProcess = '/api/voice-command/process';
```

#### 1.4 API Service - `lib/features/voice_command/data/voice_command_api_service.dart`
- Extends `BaseApiService`
- Method `processVoiceCommand(String filePath)`:
  - Tạo `FormData` với `MultipartFile.fromFile(filePath, filename: 'voice_audio')`
  - POST tới `ApiConstants.voiceCommandProcess`
  - **Lưu ý:** Cần custom Dio call (không dùng `base post()`) vì cần set `contentType: 'multipart/form-data'` và có thể tăng timeout cho file lớn.
  - Parse response → `VoiceCommandResponse`

#### 1.5 Repository - `lib/features/voice_command/data/voice_command_repository.dart`
- Nhận `VoiceCommandApiService`
- Method `processVoice(String audioPath)` → `Future<VoiceCommandResponse>`
- Wrap trong try-catch, throw custom exception nếu lỗi

### Phase 2: Provider Layer

#### 2.1 Providers - `lib/features/voice_command/providers/voice_command_provider.dart`

```dart
// API Service provider
final voiceCommandApiServiceProvider = Provider((_) => VoiceCommandApiService());

// Repository provider  
final voiceCommandRepositoryProvider = Provider((ref) =>
  VoiceCommandRepository(ref.watch(voiceCommandApiServiceProvider)));

// StateNotifier cho toàn bộ flow voice command
final voiceCommandProvider = StateNotifierProvider<VoiceCommandNotifier, VoiceCommandState>((ref) =>
  VoiceCommandNotifier(ref.read(voiceCommandRepositoryProvider)));
```

#### 2.2 State - `lib/features/voice_command/providers/voice_command_state.dart`

```dart
enum VoiceCommandStatus {
  idle,           // Chưa bắt đầu
  recording,      // Đang ghi âm
  processing,     // Đang gọi API
  success,        // Có kết quả
  error,          // Lỗi
}

class VoiceCommandState {
  final VoiceCommandStatus status;
  final VoiceCommandResponse? response;
  final String? errorMessage;
  final List<double> waveformData;  // amplitude samples cho visualizer
}
```

#### 2.3 Notifier - `lib/features/voice_command/providers/voice_command_notifier.dart`
- `startRecording()` → check permission → start `Record` plugin → listen amplitude stream → update waveformData
- `stopRecording()` → stop recording → lấy file path
- `processCommand(String filePath)` → set processing → call repo → set success/error
- `reset()` → quay về idle

### Phase 3: UI Layer

#### 3.1 Voice Command Bottom Sheet - `lib/features/voice_command/screens/voice_command_sheet.dart`

**Giao diện:** Modal Bottom Sheet (hoặc full-screen dialog) với các trạng thái:

| Status       | UI                                                                                  |
|-------------|--------------------------------------------------------------------------------------|
| `recording` | Waveform visualizer (animated bars) + nút Stop (hình vuông đỏ) + "Đang nghe..."     |
| `processing`| CircularProgressIndicator + "Đang xử lý..."                                         |
| `success`   | Icon check + transcript text + auto-close sau 1s rồi navigate + phát audio đồng thời |
| `error`     | Icon error + message + nút "Thử lại"                                                |

**Waveform Visualizer:**
- Widget custom `AudioWaveform` hiển thị ~30-40 bars animated
- Nhận `List<double>` amplitude từ state
- Mỗi bar height = normalized amplitude × maxHeight
- Animation: bars update real-time khi nói, có idle animation nhẹ khi im lặng
- Style tham khảo Google Assistant (bars tròn, gradient màu primary)

#### 3.2 Navigation Handler - `lib/features/voice_command/utils/voice_command_navigator.dart`

```dart
class VoiceCommandNavigator {
  static void navigate(BuildContext context, VoiceCommandKey key, WidgetRef ref) {
    switch (key) {
      case VoiceCommandKey.home:
        context.go('/home');
      case VoiceCommandKey.medication:
      case VoiceCommandKey.medicationDetail:
        context.go('/medication');
      case VoiceCommandKey.physical:
        context.go('/workout');
      case VoiceCommandKey.nutrition:
        context.go('/nutrition');
      case VoiceCommandKey.startPhysical:
        // Lấy danh sách workout từ provider, tìm bài chưa tập đầu tiên
        // → context.push('/workout-detail', extra: firstWorkout)
        _navigateToFirstWorkout(context, ref);
      case VoiceCommandKey.unknown:
        // Show snackbar "Không hiểu lệnh"
        break;
    }
  }

  /// Phát audio TTS đồng thời với navigate (fire-and-forget)
  static Future<void> playResponseAudio(String? base64Audio) async {
    if (base64Audio == null || base64Audio.isEmpty) return;
    final bytes = base64Decode(base64Audio);
    final player = AudioPlayer();
    await player.play(BytesSource(bytes));
    player.onPlayerComplete.listen((_) => player.dispose());
  }
}
```

### Phase 4: Kết nối vào Home Screen

#### 4.1 Sửa `lib/features/home/screens/patient/patient_home_screen.dart`

```dart
VoiceRecordButton(
  size: VoiceRecordButtonSize.large,
  onPressed: () => _showVoiceCommandSheet(context),
  label: 'Ask AI',
)
```

- `_showVoiceCommandSheet(context)`: 
  - Check & request `Permission.microphone`
  - Nếu granted → `showModalBottomSheet(...)` hiện `VoiceCommandSheet`
  - Nếu denied → show dialog hướng dẫn bật quyền trong Settings

### Phase 5: Audio Recording Setup

#### 5.1 Package cần thêm vào `pubspec.yaml`
```yaml
dependencies:
  record: ^5.1.0          # Ghi âm (hỗ trợ amplitude stream)
  audioplayers: ^6.0.0     # Phát audio TTS response (nếu cần)
```

#### 5.2 Android Permission - sửa `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

#### 5.3 Permission request trong flow
- Dùng `permission_handler` (đã có trong project)
- Request `Permission.microphone` khi user nhấn Ask AI lần đầu
- Nếu permanently denied → `openAppSettings()`

---

## Thứ tự triển khai (Task Order)

1. **Thêm packages** (`record`, `audioplayers`) + Android permission
2. **Model + Enum** (`VoiceCommandResponse`, `VoiceCommandKey`)
3. **API constant + API Service** (endpoint + multipart upload)
4. **Repository**
5. **State + Notifier + Providers**
6. **AudioWaveform widget** (custom animated bars)
7. **VoiceCommandSheet** (bottom sheet với các trạng thái)
8. **VoiceCommandNavigator** (điều hướng theo key)
9. **Kết nối vào PatientHomeScreen** (onPressed + permission flow)
10. **Test end-to-end** trên thiết bị thật (mic không hoạt động trên emulator)

---

## Lưu ý kỹ thuật

- **Audio format:** `record` package mặc định output `.m4a` (AAC) trên Android → API hỗ trợ.
- **Amplitude stream:** `record` cung cấp `onAmplitudeChanged` stream → dùng cho waveform.
- **File cleanup:** Xóa file audio tạm sau khi API trả kết quả.
- **Timeout:** API voice processing có thể mất 5-10s (STT + LLM + TTS) → set timeout riêng ~30s.
- **TTS audio response (phát song song navigate):**
  - API trả `data.audio` (base64 string) → decode thành bytes → ghi ra temp file hoặc dùng `audioplayers` `BytesSource`.
  - Khi nhận response thành công: **đồng thời** gọi `audioplayers.play()` **VÀ** `VoiceCommandNavigator.navigate()`.
  - Audio phát nền, không block navigation. Nếu user thoát app hoặc chuyển màn thì audio vẫn phát hết (fire-and-forget).
  - Dispose player sau khi phát xong (`onPlayerComplete` listener).
- **START_PHYSICAL logic:** Cần read workout list từ `exerciseTasksProvider`, filter bài chưa complete, lấy bài đầu tiên → push `/workout-detail`.
- **Patient only:** Chỉ hiện nút Ask AI trên `PatientHomeScreen`, không hiện trên Caretaker view (hiện tại đã đúng).
