# Medication Feature - API Integration

## ✅ Đã hoàn thành

### 1. Models & DTOs
- ✅ `TaskDto` - Response model từ API
- ✅ `MedicationDetailDto`, `NutritionDetailDto`, `ExerciseDetailDto` - Detail models
- ✅ `TaskDtoMapper` - Mapper chuyển đổi TaskDto → Medication
- ✅ `BaseResponse<T>` - Generic response wrapper

### 2. API Service
- ✅ `MedicationApiService` - Service layer gọi API
  - `getMedicationTasksByDate(date)` - Lấy medication tasks theo ngày
  - `getTaskDetail(taskId)` - Lấy chi tiết task
  - `completeTask(taskId)` - Đánh dấu task hoàn thành

### 3. Repository
- ✅ `MedicationRepository` - Sử dụng real API
  - ✅ `getMedications()` - Lấy medications hôm nay
  - ✅ `getMedicationsForDate(date)` - Lấy medications theo ngày
  - ✅ `updateMedicationStatus()` - Cập nhật trạng thái (chỉ hỗ trợ "taken")

### 4. Providers
- ✅ `medicationRepositoryProvider` - Inject repository
- ✅ `medicationsProvider` - Load danh sách medications
- ✅ `filteredMedicationsProvider` - Filter theo trạng thái
- ✅ `MedicationNotifier` - Handle actions (take/skip)

## 📋 API Endpoints được sử dụng

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `/api/tasks/patient/medication-tasks` | GET | Lấy medication tasks theo ngày | ✅ Integrated |
| `/api/tasks/{task_id}` | GET | Lấy chi tiết task | ✅ Integrated |
| `/api/tasks/patient/{task_id}/complete` | PUT | Đánh dấu task hoàn thành | ✅ Integrated |

## 🔧 Cách sử dụng trong UI

### 1. Load medications cho ngày hiện tại
```dart
final medicationsAsync = ref.watch(medicationsProvider);

medicationsAsync.when(
  data: (medications) => ListView.builder(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

### 2. Load medications cho ngày cụ thể
```dart
// Set ngày muốn xem
ref.read(selectedDateProvider.notifier).state = DateTime(2026, 1, 15);

// Refresh data
ref.invalidate(medicationsProvider);
```

### 3. Filter medications theo trạng thái
```dart
// Set filter
ref.read(selectedFilterProvider.notifier).state = MedicationFilter.taken;

// Watch filtered medications
final filteredAsync = ref.watch(
  filteredMedicationsProvider(MedicationFilter.taken)
);
```

### 4. Đánh dấu đã uống thuốc
```dart
final notifier = ref.read(medicationNotifierProvider.notifier);
await notifier.takeMedication(medicationId);
```

## ⚠️ Lưu ý

### 1. Authentication
- API yêu cầu Bearer token trong header
- Token được tự động thêm bởi `AuthInterceptor`
- Đảm bảo user đã login trước khi gọi API

### 2. Error Handling
- API errors được handle bởi `BaseApiService`
- Repository sẽ rethrow errors để UI xử lý
- Sử dụng `AsyncValue.error` để hiển thị errors

### 3. Date Format
- API nhận date format: `YYYY-MM-DD`
- `task_duedate` trả về ISO 8601 format
- Mapper tự động parse sang `DateTime`

### 4. Status Mapping
```
API Status → App Status
"completed" → MedicationStatus.taken
"taken"     → MedicationStatus.taken  
"missed"    → MedicationStatus.missed
"pending"   → MedicationStatus.pending
```

## 🚧 TODO - Các API chưa có

1. ❌ Update medication status to "missed" - Backend cần endpoint riêng
2. ❌ Add new medication - Cần endpoint POST
3. ❌ Delete medication - Cần endpoint DELETE
4. ❌ Scan medication barcode/image - Cần AI/OCR service

## 🧪 Testing

### Test với Postman/cURL
```bash
# 1. Login để lấy token
curl -X POST http://14.225.218.83:8005/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test123"}'

# 2. Get medication tasks
curl -X GET "http://14.225.218.83:8005/api/tasks/patient/medication-tasks?task_date=2026-01-10" \
  -H "Authorization: Bearer YOUR_TOKEN"

# 3. Complete task
curl -X PUT "http://14.225.218.83:8005/api/tasks/patient/TASK_ID/complete" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 📝 Migration Notes

### From Fake Data to Real API
- ✅ Removed `_fakeMedications` list
- ✅ Repository now uses `MedicationApiService`
- ✅ Provider automatically refreshes after actions
- ⚠️ Scan/Add/Delete still use placeholder implementation

### Breaking Changes
- None - API response matches existing `Medication` model structure
- Mapper handles all conversions transparently

## 🎯 Next Steps

1. ✅ Test với real backend data
2. ⏳ Implement nutrition tasks API
3. ⏳ Implement workout/exercise tasks API
4. ⏳ Handle offline mode (local caching)
5. ⏳ Add retry logic for failed requests
