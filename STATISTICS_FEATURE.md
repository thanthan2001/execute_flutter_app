# 📊 Statistics Feature - Complete Documentation

## ✅ Overview
Feature **Statistics** đã được xây dựng hoàn chỉnh theo Clean Architecture + Bloc pattern với **Siêu Bộ Lọc** (Advanced Filter) hỗ trợ Day/Month/Year/Range.

---

## 🏗️ Kiến trúc

### Domain Layer
```
lib/features/statistics/domain/
├── entities/
│   ├── filter_options.dart          # FilterOptions với DateMode enum + presets
│   └── statistics_summary.dart       # StatisticsSummary + CategoryStatistics
├── repositories/
│   └── statistics_repository.dart    # Repository interface
└── usecases/
    └── get_statistics_summary_usecase.dart
```

**FilterOptions Key Features:**
- 4 chế độ: `Day` | `Month` | `Year` | `Range`
- Presets: Today, This Week, This Month, This Year, Last 7 Days, Last 30 Days
- Method `getNormalizedDateRange()` normalize time theo mode:
  - **Day** → 00:00:00 đến 23:59:59
  - **Month** → ngày đầu tháng đến ngày cuối tháng
  - **Year** → 1/1 đến 31/12
  - **Range** → giữ nguyên startDate và endDate

### Data Layer
```
lib/features/statistics/data/
└── repositories/
    └── statistics_repository_impl.dart
```

**Repository Logic:**
1. Normalize date range từ FilterOptions
2. Lấy transactions trong khoảng thời gian
3. Filter theo type (all/income/expense)
4. Filter theo category (optional)
5. Tính tổng thu/tổng chi
6. Group theo category và tính percentage
7. Return StatisticsSummary

### Presentation Layer
```
lib/features/statistics/presentation/
├── bloc/
│   ├── statistics_event.dart    # 6 events: Load, ChangeDateMode, UpdateFilter, ApplyFilter, Reset, Refresh
│   ├── statistics_state.dart    # 4 states: Initial, Loading, Loaded, Error
│   └── statistics_bloc.dart     # Bloc logic
├── pages/
│   └── statistics_screen.dart   # Màn hình chính với 3 tabs
└── widgets/
    └── advanced_filter_bottom_sheet.dart  # Siêu Bộ Lọc
```

---

## 🎨 UI Components

### 1. Statistics Screen (3 Tabs)

#### Tab 1: Tất cả
- ✅ Summary cards: Tổng Thu | Tổng Chi
- ✅ Balance card (Số dư = Thu - Chi)
- ✅ Bar chart so sánh Thu vs Chi

#### Tab 2: Tổng thu
- ✅ Total income card (số to ở giữa)
- ✅ Pie chart phân bổ theo category
- ✅ List chi tiết categories (icon + tên + số tiền + %)

#### Tab 3: Tổng chi
- ✅ Total expense card (số to ở giữa)
- ✅ Pie chart phân bổ theo category
- ✅ List chi tiết categories (icon + tên + số tiền + %)

### 2. Siêu Bộ Lọc (Advanced Filter Bottom Sheet)

**Các thành phần:**

1. **Mode Selector** (Chọn chế độ)
   - Chip buttons: Ngày | Tháng | Năm | Khoảng
   - Icons tương ứng cho mỗi mode

2. **Date Pickers** (Động theo mode)
   - **Day mode**: Single date picker
   - **Month mode**: Month dropdown + Year dropdown
   - **Year mode**: Year dropdown
   - **Range mode**: Start date picker + End date picker

3. **Quick Presets** (Lựa chọn nhanh)
   - Hôm nay, Tuần này, Tháng này, Năm này
   - 7 ngày qua, 30 ngày qua
   - Icon flash_on để dễ nhận biết

4. **Category Filter** (Dropdown)
   - "Tất cả" hoặc chọn 1 category cụ thể
   - Hiển thị icon + tên category

5. **Type Filter** (Segmented Button)
   - Tất cả | Thu | Chi
   - Icons với màu sắc tương ứng

6. **Bottom Buttons**
   - **Đặt lại** → Reset về tháng hiện tại
   - **Áp dụng** → ApplyFilter event

---

## 🔧 Integration

### 1. Dependency Injection (`injection_container.dart`)
```dart
// ## Features - Statistics
// Bloc
sl.registerFactory(() => StatisticsBloc(
  getStatisticsSummaryUseCase: sl(),
));

// Use cases
sl.registerLazySingleton(() => GetStatisticsSummaryUseCase(sl()));

// Repository
sl.registerLazySingleton<StatisticsRepository>(
  () => StatisticsRepositoryImpl(
    localDataSource: sl(), // Tái sử dụng DashboardLocalDataSource
  ),
);
```

### 2. Router (`app_router.dart`)
```dart
GoRoute(
  path: '/statistics',
  builder: (context, state) => const StatisticsScreen(),
),
```

### 3. BlocProvider (`app_config.dart`)
```dart
BlocProvider<StatisticsBloc>(
  create: (_) => di.sl<StatisticsBloc>(),
),
```

### 4. Navigation from Dashboard
```dart
IconButton(
  icon: const Icon(Icons.bar_chart),
  tooltip: 'Thống kê',
  onPressed: () {
    context.push('/statistics');
  },
),
```

---

## 📋 Features Checklist

### Domain Layer
- [x] FilterOptions entity với DateMode enum
- [x] TransactionType enum (all/income/expense)
- [x] StatisticsSummary entity
- [x] CategoryStatistics entity
- [x] Presets: Today, This Week, This Month, This Year, Last 7/30 Days
- [x] Method getNormalizedDateRange()
- [x] StatisticsRepository interface
- [x] GetStatisticsSummaryUseCase

### Data Layer
- [x] StatisticsRepositoryImpl
- [x] Logic normalize time range theo mode
- [x] Filter transactions theo date range
- [x] Filter theo type (all/income/expense)
- [x] Filter theo category (optional)
- [x] Tính tổng thu/chi
- [x] Group theo category
- [x] Tính percentage
- [x] Tái sử dụng DashboardLocalDataSource

### Presentation - Bloc
- [x] LoadStatistics event
- [x] ChangeDateMode event
- [x] UpdateFilterOptions event
- [x] ApplyFilter event
- [x] ResetFilter event
- [x] RefreshStatistics event
- [x] StatisticsInitial state
- [x] StatisticsLoading state
- [x] StatisticsLoaded state (với activeFilter + summary)
- [x] StatisticsError state

### Presentation - UI
- [x] Statistics Screen với 3 tabs
- [x] Tab "Tất cả" với summary cards + bar chart
- [x] Tab "Tổng thu" với total card + pie chart + list
- [x] Tab "Tổng chi" với total card + pie chart + list
- [x] Advanced Filter Bottom Sheet
- [x] Mode selector (Day/Month/Year/Range)
- [x] Date pickers động theo mode
- [x] Quick presets (6 options)
- [x] Category filter dropdown
- [x] Type filter (segmented button)
- [x] Reset và Apply buttons
- [x] Filter info display (hiển thị filter hiện tại)
- [x] Empty state ("Không có dữ liệu")
- [x] Error state với retry button
- [x] Pull-to-refresh
- [x] Pie charts (fl_chart)
- [x] Bar charts (fl_chart)
- [x] Category items với icon + amount + percentage

### Integration
- [x] Đăng ký trong DI container
- [x] Thêm route `/statistics`
- [x] BlocProvider trong app_config
- [x] Navigation từ Dashboard

---

## 🚀 Cách sử dụng

### 1. Mở Statistics Screen
```dart
// Từ Dashboard
context.push('/statistics');
```

### 2. Xem thống kê
- Mặc định load tháng hiện tại
- Chuyển tab để xem chi tiết Thu/Chi
- Pull-to-refresh để làm mới data

### 3. Sử dụng Filter
```dart
// Bấm nút filter icon (Icons.filter_alt_outlined)
// → Mở Advanced Filter Bottom Sheet

// Chọn mode: Day | Month | Year | Range
// Chọn thời gian tương ứng
// Hoặc dùng preset nhanh
// Chọn category (optional)
// Chọn type (all/income/expense)
// Bấm "Áp dụng"
```

### 4. Reset Filter
```dart
// Bấm "Đặt lại" trong filter
// → Quay về tháng hiện tại
```

---

## 📊 Data Flow

```
User bấm "Áp dụng" trong Filter
    ↓
ApplyFilter event (với FilterOptions)
    ↓
StatisticsBloc.onApplyFilter()
    ↓
GetStatisticsSummaryUseCase(filterOptions)
    ↓
StatisticsRepositoryImpl.getStatistics()
    ↓
1. Normalize date range theo mode
2. Lấy transactions trong range
3. Filter theo type và category
4. Tính tổng + group theo category
5. Return StatisticsSummary
    ↓
StatisticsBloc emit StatisticsLoaded
    ↓
UI update (tabs + charts + lists)
```

---

## 🎯 Key Features

### 1. Normalize Time Range
```dart
// Day mode
final start = DateTime(2025, 10, 31, 0, 0, 0);
final end = DateTime(2025, 10, 31, 23, 59, 59);

// Month mode (Tháng 10/2025)
final start = DateTime(2025, 10, 1, 0, 0, 0);
final end = DateTime(2025, 10, 31, 23, 59, 59);

// Year mode (Năm 2025)
final start = DateTime(2025, 1, 1, 0, 0, 0);
final end = DateTime(2025, 12, 31, 23, 59, 59);

// Range mode
final start = userSelectedStart;
final end = userSelectedEnd;
```

### 2. Category Statistics Calculation
```dart
// Tính percentage
final percentage = totalIncome > 0 
  ? (categoryAmount / totalIncome) * 100 
  : 0.0;

// Sắp xếp theo amount giảm dần
incomeStats.sort((a, b) => b.amount.compareTo(a.amount));
```

### 3. Filter Combination
```dart
// User có thể combine:
- Date mode (Day/Month/Year/Range)
- Category (specific hoặc all)
- Type (income/expense/all)

// Ví dụ: "Tất cả chi tiêu của nhóm Ăn uống trong tháng 10/2025"
FilterOptions(
  dateMode: DateMode.month,
  month: 10,
  year: 2025,
  categoryId: 'food',
  type: TransactionType.expense,
)
```

---

## 🧪 Testing Guide

### 1. Test Filter Modes
```dart
// Test Day mode
- Chọn "Ngày" → Pick 31/10/2025
- Verify: Chỉ hiển thị transactions của ngày đó

// Test Month mode
- Chọn "Tháng" → Pick Tháng 10/2025
- Verify: Hiển thị tất cả transactions từ 1/10 đến 31/10

// Test Year mode
- Chọn "Năm" → Pick 2025
- Verify: Hiển thị tất cả transactions của năm 2025

// Test Range mode
- Chọn "Khoảng" → Pick 1/10 đến 15/10
- Verify: Hiển thị transactions trong khoảng đó
```

### 2. Test Presets
```dart
// Bấm "Hôm nay" → Verify date = hôm nay
// Bấm "Tuần này" → Verify range = tuần hiện tại
// Bấm "Tháng này" → Verify month = tháng hiện tại
// Bấm "7 ngày qua" → Verify range = 7 ngày cuối
```

### 3. Test Category Filter
```dart
// Chọn "Tất cả" → Hiển thị tất cả categories
// Chọn "Ăn uống" → Chỉ hiển thị category Ăn uống
```

### 4. Test Type Filter
```dart
// Chọn "Tất cả" → Hiển thị cả thu và chi
// Chọn "Thu" → Chỉ hiển thị income
// Chọn "Chi" → Chỉ hiển thị expense
```

### 5. Test Charts
```dart
// Tab "Tất cả": Bar chart thu vs chi
// Tab "Tổng thu": Pie chart phân bổ income theo category
// Tab "Tổng chi": Pie chart phân bổ expense theo category
```

### 6. Test Edge Cases
```dart
// Không có data → Show "Không có dữ liệu"
// Error → Show error message + retry button
// Pull-to-refresh → Reload data
// Reset filter → Quay về tháng hiện tại
```

---

## 💡 Tips

1. **Dùng Presets cho nhanh**: Thay vì chọn từng ngày/tháng, dùng presets "Hôm nay", "Tháng này", "7 ngày qua"

2. **Combine filters**: Có thể kết hợp category + type để xem chi tiết, ví dụ "Chi tiêu của nhóm Ăn uống trong tuần này"

3. **Check filter info**: Luôn có card hiển thị filter đang áp dụng ở đầu mỗi tab

4. **Pie charts chỉ hiển thị top 5**: Để dễ đọc, chỉ hiển thị 5 categories lớn nhất

---

## 🎨 UI Highlights

- **Material 3 Design** với cards, elevation, rounded corners
- **Màu sắc phân biệt**: Green cho thu, Red cho chi
- **Icons đầy đủ**: Icons từ FontAwesome với full metadata (codePoint, fontFamily, fontPackage)
- **Responsive**: Pull-to-refresh, smooth transitions
- **User-friendly**: Presets nhanh, clear button labels, tooltips

---

## 🔗 File Structure Summary

```
lib/features/statistics/
├── domain/
│   ├── entities/
│   │   ├── filter_options.dart (170 lines)
│   │   └── statistics_summary.dart (60 lines)
│   ├── repositories/
│   │   └── statistics_repository.dart (12 lines)
│   └── usecases/
│       └── get_statistics_summary_usecase.dart (16 lines)
├── data/
│   └── repositories/
│       └── statistics_repository_impl.dart (165 lines)
└── presentation/
    ├── bloc/
    │   ├── statistics_event.dart (56 lines)
    │   ├── statistics_state.dart (52 lines)
    │   └── statistics_bloc.dart (180 lines)
    ├── pages/
    │   └── statistics_screen.dart (600+ lines)
    └── widgets/
        └── advanced_filter_bottom_sheet.dart (650+ lines)

TOTAL: ~2000 lines of code
```

---

## ✅ Status: COMPLETE & READY TO USE

Feature Statistics đã sẵn sàng với đầy đủ chức năng:
- ✅ Clean Architecture tuân thủ
- ✅ Bloc pattern cho state management
- ✅ Siêu Bộ Lọc với 4 modes + 6 presets
- ✅ 3 tabs: Tất cả, Tổng thu, Tổng chi
- ✅ Charts: Bar chart + Pie charts
- ✅ Category breakdown với percentage
- ✅ Pull-to-refresh, error handling
- ✅ Integration hoàn chỉnh (DI + Router + BlocProvider)
- ✅ Navigation từ Dashboard

**Chạy ngay**: `flutter run` và tap icon bar_chart trên Dashboard!
