 # Memotion — Tài liệu tổng quan (Senior Flutter / MVVM)

Mục tiêu: tài liệu này cung cấp một cái nhìn chi tiết, có cấu trúc về codebase Flutter theo kiến trúc MVVM để giúp người phát triển hoặc AI agent khác nhanh chóng hiểu dự án mà không phải mò từng file.

## Mục lục
- Tổng quan dự án
- Kiến trúc & design principles (MVVM)
- Cấu trúc thư mục chính
- Thành phần hạ tầng (core)
- Các feature module chính
- Quản lý state (Riverpod) — patterns & ví dụ
- Luồng Onboarding (chi tiết bước/flow)
- Router & Navigation
- Lớp API / Networking (pattern, Result wrapper)
- Build / Run / Dev tips
- Testing & CI
- Cách mở rộng / add feature nhanh

---

## 1. Tổng quan dự án
`Memotion` là ứng dụng mobile Flutter hướng tới quản lý/giám sát sức khỏe (medication, nutrition, workout, onboarding, profile...). Dự án sử dụng MVVM để tách biệt View / ViewModel / Model, Riverpod cho state management, và Dio cho networking. Mục tiêu codebase: maintainable, testable, dễ mock service.

Ngôn ngữ tài liệu: tiếng Việt (từng phần file/route sẽ được tham chiếu bằng `backticks`).

## 2. Kiến trúc & design principles (MVVM)
- Model: DTOs / domain models (immutable), thường tạo bằng `freezed` + `json_serializable`.
- ViewModel: là các `Notifier` / `StateNotifier` (hoặc `Notifier` mới) cung cấp trạng thái cho View. ViewModel chứa business logic, gọi repository/service.
- View: `ConsumerWidget` / `HookConsumerWidget` (nếu dùng hooks) chỉ quan sát provider và hiển thị UI.

Nguyên tắc áp dụng:
- Single source of truth: trạng thái feature tập trung trong một provider/notifier.
- Repositories & Services tách riêng: dễ mock và test.
- Error handling qua một `Result`/sealed type để tách success/failure.

## 3. Cấu trúc thư mục chính (tóm tắt)
Project root (liệt kê những thư mục bạn cần quan tâm):
- `lib/` — mã nguồn ứng dụng chính.
	- `lib/core/` — hạ tầng dùng chung: `network/`, `router/`, `theme/`, `storage/`, `utils/`.
	- `lib/features/` — từng feature module: `auth/`, `onboarding/`, `profile/`, `medication/`, `nutrition/`, `workout/`.
	- `lib/shared/widgets/` — các widget tái sử dụng (navigation, cells, inputs).
	- `lib/main.dart` — điểm khởi chạy ứng dụng.

## 4. Thành phần hạ tầng (core)
- `core/network/`:
	- `BaseApiService` — base class khởi tạo `Dio`, chứa helper cho request và error mapping.
	- `ApiConstants` — base URL, endpoints.
	- `Result<T>` (sealed) — `Success`/`Failure` wrapper.
	- `ApiExceptions` — map lỗi từ Dio.
- `core/router/`:
	- `AppRouter` / `AppRoutes` — cấu hình `go_router`, có `StatefulShellRoute` cho bottom navigation.
- `core/theme/`:
	- Theme definitions, colors, typography.
- `core/storage/`:
	- `TokenStorage` dùng `flutter_secure_storage` để lưu token.

## 5. Feature modules (chi tiết)
- `auth/`:
	- Screens: Login, Register.
	- Providers: `AuthNotifier` (login/logout/token handling).
	- Flow: authenticate → lưu token vào secure storage → load `users/me`.

- `onboarding/`:
	- Đây là phần phức tạp nhất: multiple-step flow (17 bước theo codebase).
	- State: một `OnboardingState` gom toàn bộ dữ liệu các bước.
	- Notifier: `OnboardingNotifier` xử lý logic chuyển bước, validate, gọi API để tạo patient/submit các profile.
	- Các phương thức quan trọng (tham khảo trong code): `initUser()`, `submitPatientCreation()`, `submitFinalAssessment()`.
	- Final submission thực hiện gọi tuần tự các endpoint (ví dụ: POST `/api/patient-profiles/general`, POST `/api/patient-profiles/physical-therapy`, ...).

- `medication/`, `nutrition/`, `workout/`:
	- Mỗi module có provider chính (FutureProvider/StateNotifierProvider) để load tasks, filter, cập nhật trạng thái.
	- API endpoints loại: `/api/tasks/patient/medication-tasks`, `/api/tasks/patient/nutrition-tasks`, v.v.

- `profile/`:
	- Hiển thị dữ liệu người dùng từ `/api/users/me`, avatar, health stats.

## 6. Quản lý state (Riverpod) — patterns & ví dụ
- Provider types được dùng:
	- `Provider` — giá trị tĩnh hoặc service provider.
	- `StateProvider` — state đơn giản, local.
	- `FutureProvider` — load async data (tasks, profile).
	- `StateNotifierProvider` / `NotifierProvider` — state phức tạp, MVVM viewmodels.

Ví dụ pattern (pseudocode):
```dart
final onboardingNotifierProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(
	OnboardingNotifier.new,
);

class OnboardingNotifier extends Notifier<OnboardingState> {
	@override
	OnboardingState build() => const OnboardingState();

	Future<void> submitFinalAssessment() async {
		state = state.copyWith(submitting: true);
		final result1 = await repo.postGeneralProfile(state.general);
		if (result1 is Failure) { state = state.copyWith(error: result1.error); return; }
		final result2 = await repo.postPhysicalTherapy(state.physical);
		// ... handle result
		state = state.copyWith(submitting: false);
	}
}
```

Pattern khuyến nghị:
- Keep notifiers thin: chỉ orchestration và state transitions.
- Move API calls/response parsing vào repository/service.
- Map exceptions -> domain errors ở service layer.

## 7. Luồng Onboarding (chi tiết)
1. `initUser()` — load `/api/users/me` nếu đã login.
2. Thực hiện tuần tự từng step, lưu tạm trong `OnboardingState`.
3. `submitPatientCreation()` — endpoint tạo patient (caretaker → patient mapping).
4. Bước đánh giá cuối (`submitFinalAssessment()`): gửi nhiều payloads theo thứ tự yêu cầu backend.
5. Sau thành công — chuyển hướng tới `main shell` (Home).

Ghi chú: luồng có nhiều thao tác side-effect (API calls) nên trong test cần mock service trả về success/failure.

## 8. Router & Navigation
- `go_router` được cấu hình với một `StatefulShellRoute` cho bottom navigation (Home, Medication, Nutrition, Workout, Profile).
- Onboarding có route riêng theo step: `/onboarding/:step` (có thể từ 1..17).
- Cấu trúc route khuyến nghị (ví dụ):
	- `/auth/login`, `/auth/register`
	- `/onboarding/1` ... `/onboarding/17`
	- `/main` (shell) with branches `/main/home`, `/main/medication`, ...

## 9. Lớp API / Networking — pattern
- Dùng `Dio` với `BaseApiService`.
- Kết quả trả về luôn được wrap bằng `Result<T>` (Success | Failure) để caller dễ xử lý.

Pseudocode:
```dart
class BaseApiService {
	final Dio _dio;
	Future<Result<T>> get<T>(String path, T Function(dynamic) parser) async {
		try {
			final res = await _dio.get(path);
			return Success(parser(res.data));
		} on DioException catch (e) {
			return Failure(ApiException.fromDioError(e));
		}
	}
}
```

Ghi chú: Khi thêm endpoint mới — tạo DTO `freezed` -> update service -> update repository -> provider -> UI.

## 10. Build / Run / Dev tips
- Cài đặt dependencies:
```bash
flutter pub get
```
- Sinh code (freezed / json_serializable):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
- Chạy app:
```bash
flutter run
```
- Lint/format: tuân theo `analysis_options.yaml`.

## 11. Testing & QA
- Unit tests: thư mục `test/` (ví dụ `widget_test.dart`).
- Test các Notifier bằng cách mock repository/service.
- Widget tests: render `ConsumerWidget` với `ProviderScope(overrides: [...])` để inject mocks.

## 12. Cách thêm feature nhanh (checklist)
1. Tạo thư mục `lib/features/<feature>/`.
2. Thêm DTOs (`freezed`) trong `model/` hoặc `data/` của feature.
3. Tạo `service/repository` gọi API trong `lib/core/network/` hoặc feature-level service.
4. Tạo `Notifier`/ViewModel trong feature và expose qua `StateNotifierProvider`.
5. Tạo `Screen`/`Widgets` trong feature và thêm route vào `AppRouter`.
6. Viết unit test cho notifier + widget test cho màn hình.
7. Chạy `build_runner` để sinh code nếu cần.

## 13. Các tập tin quan trọng để mở đầu (quick links)
- Entry: `lib/main.dart`
- Router: `lib/core/router/` (xem `AppRouter`/`AppRoutes`)
- Onboarding principal notifier: `lib/features/onboarding/` (tìm `OnboardingNotifier`)
- Base API: `lib/core/network/` (tìm `BaseApiService`, `Result`)

## 14. Lời khuyên từ Senior Flutter
- Giữ `View` không chứa logic; ViewModel chịu hết logic.
- Test ViewModel nhiều hơn UI.
- Chia nhỏ state (avoid giant monolithic states) — nhưng với onboarding có thể gom tạm.
- Document rõ sequence API cho onboarding (thứ tự gọi rất quan trọng).
