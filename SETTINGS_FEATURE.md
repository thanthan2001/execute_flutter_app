# ⚙️ Settings Feature - Complete Documentation

## ✅ Overview
Feature **Settings** (Cài đặt) đã được xây dựng hoàn chỉnh với chức năng quản lý dữ liệu hệ thống.

---

## 🏗️ Kiến trúc

### Domain Layer (Sử dụng DashboardRepository)
```
lib/features/settings/domain/
└── usecases/
    └── clear_all_transactions_usecase.dart
```

**Đặc điểm:**
- Tái sử dụng `DashboardRepository.clearAllTransactions()`
- UseCase wrapper cho business logic
- Không cần repository riêng

### Presentation Layer
```
lib/features/settings/presentation/
├── bloc/
│   ├── settings_event.dart        # ClearAllTransactionsEvent
│   ├── settings_state.dart        # Initial, Clearing, Cleared, Error
│   └── settings_bloc.dart         # Bloc logic
└── pages/
    └── settings_screen.dart       # UI chính
```

---

## 🎨 UI Components

### Settings Screen

#### 1. Thông tin ứng dụng (ExpansionTile)
- **Logo**: Icon wallet trong container màu primary
- **Tên app**: "Quản lý chi tiêu"
- **Phiên bản**: "1.0.0"
- **Mở rộng để xem thêm**:
  - Tác giả: "Clean Architecture Team"
  - Liên hệ: "support@example.com"

#### 2. Quản lý dữ liệu
- **Title**: "Xóa toàn bộ dữ liệu giao dịch"
- **Icon**: `delete_sweep` (màu đỏ)
- **Subtitle**: "Xóa tất cả giao dịch đã lưu (không thể hoàn tác)"
- **Trailing**: Chevron right hoặc CircularProgressIndicator (khi đang xóa)
- **Tap**: Hiển thị AlertDialog xác nhận

#### 3. Confirm Dialog
- **Title**: "Xác nhận xóa"
- **Content**: "Bạn có chắc chắn muốn xóa toàn bộ dữ liệu giao dịch không? Hành động này không thể hoàn tác."
- **Actions**:
  - **Hủy** (TextButton) - Đóng dialog
  - **Xóa** (TextButton, màu đỏ, bold) - Dispatch ClearAllTransactionsEvent

---

## 🔧 Integration

### 1. Repository Enhancement
```dart
// DashboardRepository interface
abstract class DashboardRepository {
  Future<Either<Failure, void>> clearAllTransactions();
}

// DashboardRepositoryImpl
@override
Future<Either<Failure, void>> clearAllTransactions() async {
  try {
    await localDataSource.clearAllTransactions();
    return const Right(null);
  } catch (e) {
    return Left(CacheFailure(message: e.toString()));
  }
}
```

### 2. Dependency Injection (`injection_container.dart`)
```dart
// ## Features - Settings
// Bloc
sl.registerFactory(() => SettingsBloc(
  clearAllTransactionsUseCase: sl(),
));

// Use cases
sl.registerLazySingleton(() => ClearAllTransactionsUseCase(sl()));
// Repository: Tái sử dụng DashboardRepository (đã đăng ký)
```

### 3. Router (`app_router.dart`)
```dart
GoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsScreen(),
),
```

### 4. BlocProvider (`app_config.dart`)
```dart
BlocProvider<SettingsBloc>(
  create: (_) => di.sl<SettingsBloc>(),
),
```

### 5. Navigation from Dashboard
```dart
IconButton(
  icon: const Icon(Icons.settings_outlined),
  tooltip: 'Cài đặt',
  onPressed: () {
    context.push('/settings');
  },
),
```

---

## 📋 Features Checklist

### Domain Layer
- [x] ClearAllTransactionsUseCase
- [x] Tái sử dụng DashboardRepository
- [x] Method clearAllTransactions() trong repository interface
- [x] Implementation trong DashboardRepositoryImpl

### Presentation - Bloc
- [x] ClearAllTransactionsEvent
- [x] SettingsInitial state
- [x] ClearingTransactions state
- [x] TransactionsCleared state
- [x] ClearTransactionsError state
- [x] SettingsBloc với event handlers
- [x] Error message mapping

### Presentation - UI
- [x] Settings Screen
- [x] App info section (ExpansionTile)
- [x] Logo, tên app, phiên bản
- [x] Tác giả và liên hệ
- [x] Data management section
- [x] Clear data tile (màu đỏ)
- [x] Loading indicator khi đang xóa
- [x] Confirm AlertDialog
- [x] BlocListener cho success/error
- [x] SnackBar notifications

### Integration
- [x] Đăng ký trong DI container
- [x] Thêm route `/settings`
- [x] BlocProvider trong app_config
- [x] Navigation từ Dashboard

---

## 🚀 Cách sử dụng

### 1. Mở Settings Screen
```dart
// Từ Dashboard - Bấm icon Settings (settings_outlined)
context.push('/settings');
```

### 2. Xem thông tin ứng dụng
- Tap vào "Thông tin ứng dụng" để mở rộng
- Xem logo, tên app, phiên bản, tác giả, liên hệ

### 3. Xóa toàn bộ dữ liệu giao dịch
```dart
// Tap vào "Xóa toàn bộ dữ liệu giao dịch"
// → Hiện AlertDialog xác nhận
// → Bấm "Xóa" để confirm
// → SettingsBloc dispatch ClearAllTransactionsEvent
// → Repository xóa data từ Hive
// → Hiện SnackBar "Đã xóa toàn bộ giao dịch"
// → Auto pop về màn trước
```

---

## 📊 Data Flow

```
User tap "Xóa toàn bộ dữ liệu giao dịch"
    ↓
Hiển thị AlertDialog xác nhận
    ↓
User bấm "Xóa"
    ↓
ClearAllTransactionsEvent (dispatch)
    ↓
SettingsBloc.onClearAllTransactions()
    ↓
emit ClearingTransactions (loading state)
    ↓
ClearAllTransactionsUseCase(NoParams)
    ↓
DashboardRepository.clearAllTransactions()
    ↓
DashboardLocalDataSource.clearAllTransactions()
    ↓
Hive: transactionsBox.clear()
    ↓
Return Right(null)
    ↓
SettingsBloc emit TransactionsCleared
    ↓
BlocListener: Show SnackBar + Pop screen
```

---

## 🎯 Key Features

### 1. Confirmation Dialog
```dart
// Dialog hiển thị cảnh báo rõ ràng
AlertDialog(
  title: 'Xác nhận xóa',
  content: 'Bạn có chắc chắn muốn xóa toàn bộ dữ liệu giao dịch không? 
            Hành động này không thể hoàn tác.',
  actions: [
    TextButton('Hủy'),
    TextButton('Xóa', style: red + bold),
  ],
)
```

### 2. Loading State
```dart
// Khi đang xóa:
- Tile disabled
- Icon màu xám
- Text màu xám
- Hiện CircularProgressIndicator thay vì chevron
```

### 3. User Feedback
```dart
// Success:
SnackBar(
  content: 'Đã xóa toàn bộ giao dịch',
  backgroundColor: Colors.green,
)
Navigator.pop() // Auto quay về

// Error:
SnackBar(
  content: 'Lỗi: ${state.message}',
  backgroundColor: Colors.red,
)
```

### 4. Repository Reuse
```dart
// Không tạo SettingsRepository riêng
// Tái sử dụng DashboardRepository.clearAllTransactions()
// → Code cleaner, ít duplication
```

---

## 🧪 Testing Guide

### 1. Test UI Display
```dart
// Mở Settings screen
- Verify: AppBar title = "Cài đặt"
- Verify: Có ExpansionTile "Thông tin ứng dụng"
- Verify: Có ListTile "Xóa toàn bộ dữ liệu giao dịch" (màu đỏ)
```

### 2. Test App Info
```dart
// Tap vào ExpansionTile
- Verify: Mở rộng hiển thị:
  * Logo (Icon wallet)
  * Tên app: "Quản lý chi tiêu"
  * Phiên bản: "1.0.0"
  * Tác giả: "Clean Architecture Team"
  * Liên hệ: "support@example.com"
```

### 3. Test Clear Data Flow
```dart
// Step 1: Tap "Xóa toàn bộ dữ liệu giao dịch"
- Verify: Hiện AlertDialog với message cảnh báo

// Step 2: Bấm "Hủy"
- Verify: Dialog đóng, không có gì xảy ra

// Step 3: Tap lại, bấm "Xóa"
- Verify: Tile disabled + loading indicator
- Verify: Dialog đóng
- Wait for result...
- Verify: SnackBar "Đã xóa toàn bộ giao dịch" (green)
- Verify: Auto pop về Dashboard

// Step 4: Kiểm tra Dashboard
- Verify: Tất cả giao dịch đã bị xóa
- Verify: Dashboard shows empty state hoặc reset data
```

### 4. Test Error Case
```dart
// Mock repository để return failure
- Tap "Xóa toàn bộ dữ liệu giao dịch"
- Bấm "Xóa"
- Verify: SnackBar "Lỗi: [error message]" (red)
- Verify: Tile trở về enabled (không pop)
```

### 5. Test State Management
```dart
// Verify Bloc states:
1. Initial → SettingsInitial
2. User tap Xóa → ClearingTransactions (loading)
3. Success → TransactionsCleared (show success)
4. Error → ClearTransactionsError (show error)
```

---

## 💡 Tips

1. **Cảnh báo rõ ràng**: Dialog có message "không thể hoàn tác" để user cân nhắc

2. **Màu sắc phân biệt**: Nút "Xóa" màu đỏ + bold để nhấn mạnh hành động nguy hiểm

3. **Loading indicator**: Disable tile và hiện loading khi đang xóa để tránh spam

4. **Auto pop**: Sau khi xóa thành công, tự động quay về Dashboard để user thấy kết quả

5. **Tái sử dụng repository**: Settings không cần repository riêng, dùng DashboardRepository

---

## 🎨 UI Highlights

- **Material 3 Design** với ExpansionTile, ListTile, AlertDialog
- **Màu sắc cảnh báo**: Red cho delete action
- **Icons rõ nghĩa**: delete_sweep, info_outline, settings_outlined
- **Loading states**: CircularProgressIndicator khi processing
- **SnackBar feedback**: Green for success, Red for error
- **Responsive**: Disable tile khi đang xóa

---

## 🔗 File Structure Summary

```
lib/features/settings/
├── domain/
│   └── usecases/
│       └── clear_all_transactions_usecase.dart (16 lines)
└── presentation/
    ├── bloc/
    │   ├── settings_event.dart (12 lines)
    │   ├── settings_state.dart (36 lines)
    │   └── settings_bloc.dart (46 lines)
    └── pages/
        └── settings_screen.dart (240 lines)

TOTAL: ~350 lines of code
```

---

## 🔄 Related Features

Settings feature liên quan đến:
- **Dashboard**: Tái sử dụng DashboardRepository và LocalDataSource
- **Transaction**: Xóa toàn bộ transactions từ Hive
- **Category**: Không xóa categories (chỉ xóa transactions)

---

## 🚨 Important Notes

1. **Xóa chỉ transactions**: Method `clearAllTransactions()` chỉ xóa giao dịch, không xóa categories

2. **Không thể hoàn tác**: Hive box được clear hoàn toàn, data không thể recover

3. **Refresh Dashboard**: Sau khi xóa, Dashboard sẽ cần refresh để hiển thị empty state

4. **Context usage**: AlertDialog sử dụng context gốc (không phải dialogContext) để dispatch event

---

## ✅ Status: COMPLETE & READY TO USE

Feature Settings đã sẵn sàng với đầy đủ chức năng:
- ✅ Clean Architecture tuân thủ
- ✅ Bloc pattern cho state management
- ✅ UI thân thiện với cảnh báo rõ ràng
- ✅ Confirm dialog an toàn
- ✅ Loading states và feedback
- ✅ Integration hoàn chỉnh (DI + Router + BlocProvider)
- ✅ Navigation từ Dashboard

**Chạy ngay**: `flutter run` và tap icon settings trên Dashboard!
