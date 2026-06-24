# Medication Scan Feature - Tài liệu tích hợp

## Tổng quan
Feature scan thuốc đã được tích hợp hoàn toàn vào app Memotion theo kiến trúc MVVM. Feature này cho phép người dùng chụp ảnh thuốc (bao bì hoặc viên thuốc) và tự động nhận diện thông tin thuốc thông qua API AI.

## Luồng hoạt động

```
User → Medication Screen → Tap FAB (Scan Icon) → Camera/Gallery
     → Chụp/Chọn ảnh → Upload to API → Hiển thị kết quả
```

## Các file đã tạo/sửa đổi

### 1. DTO Models (với Freezed)
**File:** `lib/features/medication/models/medication_scan_dto.dart`
- `MedicationScanResponse`: Response từ API
- `MedicationScanData`: Data chứa medication info hoặc error
- `MedicationDto`: Thông tin thuốc chi tiết từ scan

### 2. API Service Layer
**File:** `lib/features/medication/data/medication_scan_service.dart`
- Kế thừa từ `BaseApiService`
- Method `scanMedicationImage(File imageFile)`: Upload ảnh dạng multipart/form-data
- Tự động xử lý error thông qua DioException

**File:** `lib/core/network/api_constants.dart` (đã cập nhật)
- Thêm endpoint: `scanMedicationImage = '/api/medication-library/scan-image'`

### 3. State Management (Riverpod + Notifier)
**File:** `lib/features/medication/providers/scan_medication_state.dart`
- State class với Freezed
- Properties: `isScanning`, `isSuccess`, `scannedMedication`, `errorMessage`, `imagePath`

**File:** `lib/features/medication/providers/scan_medication_notifier.dart`
- `ScanMedicationNotifier` extends `Notifier<ScanMedicationState>`
- Methods:
  - `scanMedication(File imageFile)`: Thực hiện scan và update state
  - `reset()`: Reset về initial state
  - `clearError()`: Xóa error message
- Provider: `scanMedicationNotifierProvider`

### 4. UI Layer
**File:** `lib/features/medication/screens/scan_medication_screen.dart`
- `ScanMedicationScreen`: Main screen cho scan feature
- Features:
  - Hướng dẫn sử dụng (instructions card)
  - 2 options: Camera hoặc Gallery (dùng `image_picker`)
  - Loading state với CircularProgressIndicator
  - Success state: Hiển thị thông tin thuốc đầy đủ
  - Error state: Hiển thị lỗi và nút "Try Again"
  - Placeholder state khi chưa có ảnh

### 5. Routing
**File:** `lib/core/router/app_router.dart` (đã có sẵn)
- Route đã được config: `/medication/scan` (nested route)
- Navigation: `context.push('/medication/scan')`

**File:** `lib/features/medication/screens/medication_main_screen.dart` (đã có sẵn)
- FloatingActionButton ở bottom-right
- Icon: `Icons.qr_code_scanner`
- Onpress: Navigate to scan screen

## API Specification

### Endpoint
```
POST /api/medication-library/scan-image
```

### Request
- Content-Type: `multipart/form-data`
- Field: `file` (image file: PNG, JPG, JPEG, GIF, WebP)

### Response (Success 200)
```json
{
  "code": "200",
  "message": "",
  "data": {
    "message": "string",
    "medication": {
      "name": "string",
      "description": "string",
      "dosage": "string",
      "frequency_per_day": 0,
      "notes": "string",
      "image_path": "string",
      "medication_id": "uuid"
    },
    "agent_error": "string"
  }
}
```

## Cách sử dụng

### 1. Từ Medication Main Screen
1. Tap vào FloatingActionButton (icon QR scanner) ở góc phải dưới
2. Màn hình scan sẽ mở ra

### 2. Trong Scan Screen
1. Chọn "Take Photo" để mở camera
2. Hoặc "Choose from Gallery" để chọn ảnh có sẵn
3. Sau khi chụp/chọn, ảnh sẽ tự động upload
4. Chờ kết quả (loading indicator)
5. Xem thông tin thuốc nếu thành công
6. Tap "Add to List" để thêm vào danh sách (TODO: chưa implement)
7. Hoặc "Scan Again" để scan thuốc khác

## Xử lý Error

### Client-side errors
- Camera permission denied: SnackBar thông báo
- Gallery permission denied: SnackBar thông báo
- Network error: Hiển thị error state

### Server-side errors
- Medication not found: Hiển thị `agent_error` message
- API error: Hiển thị error message từ exception

## Dependencies

Đã có sẵn trong `pubspec.yaml`:
- `image_picker: ^1.0.7` - Chụp ảnh/chọn từ gallery
- `camera: ^0.11.3` - Hỗ trợ camera features
- `dio: ^5.4.0` - HTTP client cho API calls
- `freezed` + `json_serializable` - Code generation

## Permissions cần thiết

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan medication</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select medication images</string>
```

## Testing

### Manual Testing
1. **Happy path:**
   - Chụp ảnh thuốc rõ ràng
   - Verify kết quả hiển thị đúng

2. **Error cases:**
   - Ảnh không phải thuốc
   - Network offline
   - API timeout

3. **Edge cases:**
   - Cancel camera/gallery
   - Rotate device
   - App background/foreground

### Code Generation
Khi thay đổi DTO models, chạy:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Cải tiến trong tương lai

1. **Add to Medication List**: Tích hợp thêm thuốc vào danh sách chính
2. **History**: Lưu lịch sử các lần scan
3. **Offline support**: Cache kết quả scan
4. **Multiple medications**: Scan nhiều thuốc trong một ảnh
5. **Barcode scanning**: Scan barcode/QR code trên bao bì thuốc

## Architecture Pattern

```
View (ScanMedicationScreen)
    ↓ watch/read
ViewModel (ScanMedicationNotifier)
    ↓ gọi
Service (MedicationScanService)
    ↓ HTTP
API (Backend)
```

Tuân thủ MVVM pattern:
- View chỉ render UI và observe state
- ViewModel chứa business logic
- Service layer gọi API
- State management qua Riverpod

## Liên hệ & Support

Nếu có vấn đề:
1. Check console logs
2. Verify API endpoint và authentication
3. Test với Postman trước
4. Check permissions trên device

---

**Version:** 1.0.0
**Last Updated:** 2026-01-21
**Author:** Claude Code (Senior Flutter Dev)
