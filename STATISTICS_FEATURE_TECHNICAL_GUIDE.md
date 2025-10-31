# 📊 Statistics Feature - Hướng Dẫn Kỹ Thuật Chi Tiết

## 📑 Mục Lục

1. [Tổng Quan](#1-tổng-quan)
2. [Cấu Trúc Thư Mục](#2-cấu-trúc-thư-mục)
3. [Luồng Xử Lý Chính](#3-luồng-xử-lý-chính)
4. [Presentation Layer](#4-presentation-layer)
5. [Domain Layer](#5-domain-layer)
6. [Data Layer](#6-data-layer)
7. [Ví Dụ Chi Tiết: Filter Theo Tháng](#7-ví-dụ-chi-tiết-filter-theo-tháng)
8. [Ưu Điểm Clean Architecture](#8-ưu-điểm-clean-architecture)

---

## 1. Tổng Quan

### 🎯 Mục Tiêu

Statistics feature cung cấp **công cụ thống kê và phân tích** chi tiêu/thu nhập của người dùng theo nhiều chiều: theo nhóm category và theo thời gian, giúp người dùng hiểu rõ hơn về tình hình tài chính cá nhân.

### ✨ Chức Năng Chính

#### 1. **Thống Kê Theo Nhóm Category**

- Hiển thị phân bổ chi tiêu/thu nhập theo từng nhóm
- Tính toán phần trăm đóng góp của mỗi nhóm
- Đếm số lượng giao dịch theo nhóm
- Sắp xếp theo tổng số tiền giảm dần

#### 2. **Thống Kê Theo Thời Gian**

- Filter theo **Ngày**: Chọn 1 ngày cụ thể
- Filter theo **Tháng**: Chọn tháng + năm
- Filter theo **Năm**: Chọn năm
- Filter theo **Khoảng thời gian**: Chọn từ ngày A đến ngày B

#### 3. **Biểu Đồ Trực Quan**

- **PieChart**: Hiển thị phân bổ theo nhóm category
  - Màu sắc theo màu của category
  - Hiển thị phần trăm và số tiền
  - Interactive: touch để xem chi tiết
- **BarChart**: Hiển thị tổng thu vs tổng chi
  - So sánh trực quan thu nhập và chi tiêu
  - Dễ nhận biết xu hướng

#### 4. **Tabs Phân Loại**

- **Tab "Tất cả"**: Hiển thị cả thu và chi, biểu đồ tổng quan
- **Tab "Tổng thu"**: Chỉ hiển thị thu nhập và PieChart thu nhập
- **Tab "Tổng chi"**: Chỉ hiển thị chi tiêu và PieChart chi tiêu

#### 5. **Bộ Lọc Nâng Cao**

- Chọn chế độ thời gian (Day/Month/Year/Range)
- Chọn loại giao dịch (All/Income/Expense)
- Chọn category cụ thể hoặc tất cả
- Preset filters: Hôm nay, Tuần này, Tháng này, Năm này, 7 ngày gần nhất

---

## 2. Cấu Trúc Thư Mục

```
lib/features/statistics/
│
├── presentation/          # UI Layer
│   ├── pages/
│   │   └── statistics_screen.dart          # Màn hình chính với 3 tabs
│   │
│   ├── widgets/
│   │   └── advanced_filter_bottom_sheet.dart  # Bottom sheet bộ lọc
│   │
│   └── bloc/
│       ├── statistics_bloc.dart            # BLoC xử lý state
│       ├── statistics_event.dart           # Các events
│       └── statistics_state.dart           # Các states
│
├── domain/               # Business Logic Layer
│   ├── entities/
│   │   ├── filter_options.dart            # Entity filter options
│   │   └── statistics_summary.dart        # Entity kết quả thống kê
│   │
│   ├── usecases/
│   │   └── get_statistics_summary_usecase.dart  # UseCase lấy thống kê
│   │
│   └── repositories/
│       └── statistics_repository.dart      # Repository interface
│
└── data/                 # Data Layer
    └── repositories/
        └── statistics_repository_impl.dart  # Repository implementation
```

### 📂 Giải Thích Cấu Trúc

#### **Presentation Layer** (`presentation/`)

- **Mục đích**: Hiển thị UI, xử lý tương tác user
- **Chức năng**:
  - StatisticsScreen: Màn hình chính với TabBar và charts
  - AdvancedFilterBottomSheet: Modal bottom sheet cho filter
  - StatisticsBloc: Quản lý state, xử lý events
  - Hiển thị biểu đồ (PieChart, BarChart)

#### **Domain Layer** (`domain/`)

- **Mục đích**: Business logic độc lập
- **Chức năng**:
  - Định nghĩa FilterOptions (các tùy chọn lọc)
  - Định nghĩa StatisticsSummary (kết quả thống kê)
  - GetStatisticsSummaryUseCase (logic tính toán)
  - Repository interface (contract)

#### **Data Layer** (`data/`)

- **Mục đích**: Xử lý dữ liệu từ data source
- **Chức năng**:
  - Implement repository interface
  - Lấy transactions từ DashboardLocalDataSource
  - Lấy categories để map thông tin
  - Tính toán, group theo category
  - Tính toán phần trăm

---

## 3. Luồng Xử Lý Chính

### 📊 Sơ Đồ Tổng Quan

```
┌─────────────────────────────┐
│   StatisticsScreen (UI)     │
│   - Hiển thị charts         │
│   - 3 tabs: All/Income/Exp  │
│   - Filter button           │
└──────────────┬──────────────┘
               │ Dispatch Event
               ▼
┌─────────────────────────────┐
│      StatisticsBloc         │
│   - Quản lý state           │
│   - Xử lý events            │
│   - Lưu filter hiện tại     │
└──────────────┬──────────────┘
               │ Call UseCase
               ▼
┌─────────────────────────────┐
│ GetStatisticsSummaryUseCase │
│   - Business logic          │
│   - Validate params         │
└──────────────┬──────────────┘
               │ Execute
               ▼
┌─────────────────────────────┐
│   StatisticsRepository      │
│      (Interface)            │
└──────────────┬──────────────┘
               │ Implement
               ▼
┌─────────────────────────────┐
│ StatisticsRepositoryImpl    │
│   - Lấy transactions        │
│   - Filter theo điều kiện   │
│   - Tính toán thống kê      │
│   - Group theo category     │
└──────────────┬──────────────┘
               │ Query data
               ▼
┌─────────────────────────────┐
│  DashboardLocalDataSource   │
│   - Hive database           │
│   - getTransactionsByDateRange() │
│   - getAllCategories()      │
└─────────────────────────────┘
```

### 🔄 Chi Tiết Các Luồng Xử Lý

#### **A. Load Thống Kê Lần Đầu**

```
1. StatisticsScreen.initState()
   ↓ Trigger LoadStatistics event

2. StatisticsBloc receives LoadStatistics
   ↓ emit(StatisticsLoading)
   ↓ Tạo filter mặc định (tháng hiện tại)

3. Call GetStatisticsSummaryUseCase(defaultFilter)
   ↓ Pass filter params

4. StatisticsRepositoryImpl.getStatistics()
   ↓ Normalize date range từ filter
   ↓ Query transactions trong khoảng thời gian
   ↓ Query tất cả categories
   ↓ Filter theo type (income/expense/all)
   ↓ Group transactions by category
   ↓ Tính tổng thu, tổng chi, balance
   ↓ Tính percentage cho mỗi category
   ↓ Sắp xếp theo amount giảm dần

5. Return StatisticsSummary
   ↓ Chứa tất cả dữ liệu đã tính toán

6. StatisticsBloc receives result
   ↓ emit(StatisticsLoaded(filter, summary))

7. UI rebuilds
   ↓ Hiển thị summary cards
   ↓ Vẽ charts (PieChart, BarChart)
   ↓ Hiển thị filter info
```

#### **B. Thay Đổi Filter**

```
1. User nhấn nút Filter
   ↓ Show AdvancedFilterBottomSheet

2. User chọn các options
   ↓ DateMode, TransactionType, Category
   ↓ (chưa apply, chỉ update UI trong modal)

3. User nhấn "Áp dụng"
   ↓ Dispatch ApplyFilter(newOptions)

4. StatisticsBloc._onApplyFilter()
   ↓ emit(StatisticsLoading)
   ↓ Call useCase với newOptions

5. Repository tính toán lại
   ↓ với filter mới

6. Return new StatisticsSummary
   ↓

7. Bloc emits StatisticsLoaded
   ↓ với filter mới và summary mới

8. UI updates
   ↓ Hiển thị dữ liệu mới
   ↓ Update charts
   ↓ Update filter info text
```

#### **C. Refresh Dữ Liệu**

```
1. User kéo xuống (Pull to Refresh)
   ↓ Trigger RefreshStatistics event

2. StatisticsBloc._onRefreshStatistics()
   ↓ Giữ nguyên filter hiện tại
   ↓ Call useCase lại

3. Repository query lại database
   ↓ Có thể có transactions mới

4. Return updated summary
   ↓

5. UI updates với data mới nhất
```

---

## 4. Presentation Layer

### 🎨 StatisticsScreen

**File**: `presentation/pages/statistics_screen.dart`

**Vai trò**:

- Màn hình chính của feature Statistics
- Chứa TabBar với 3 tabs: Tất cả, Tổng thu, Tổng chi
- AppBar với nút Filter
- Hiển thị loading, error, hoặc data states

**Cấu trúc**:

```
StatisticsScreen (StatefulWidget)
├── AppBar
│   ├── Title: "Thống kê"
│   └── Actions: [Filter button]
│
├── TabBar
│   ├── Tab 1: Tất cả (icon: dashboard)
│   ├── Tab 2: Tổng thu (icon: arrow_downward)
│   └── Tab 3: Tổng chi (icon: arrow_upward)
│
└── BlocBuilder<StatisticsBloc, StatisticsState>
    ├── StatisticsLoading → CircularProgressIndicator
    ├── StatisticsError → Error widget
    └── StatisticsLoaded → TabBarView
        ├── Tab 1: _buildAllTab()
        ├── Tab 2: _buildIncomeTab()
        └── Tab 3: _buildExpenseTab()
```

**Các Widget Con**:

- `_buildFilterInfo()`: Hiển thị filter đang áp dụng (ví dụ: "Tháng 10/2025")
- `_buildSummaryCard()`: Card hiển thị tổng thu/chi
- `_buildBalanceCard()`: Card hiển thị số dư (thu - chi)
- `_buildCombinedChart()`: BarChart so sánh thu vs chi
- `_buildPieChart()`: PieChart phân bổ theo category
- `_buildCategoryList()`: List các category với số tiền và %

### 🎛️ AdvancedFilterBottomSheet

**File**: `presentation/widgets/advanced_filter_bottom_sheet.dart`

**Vai trò**:

- Modal bottom sheet cho phép user chọn filter
- Hiển thị các tùy chọn filter
- Không tự dispatch event, trả về FilterOptions qua callback

**Các Thành Phần**:

```
AdvancedFilterBottomSheet
├── Date Mode Selector
│   ├── Radio: Ngày
│   ├── Radio: Tháng
│   ├── Radio: Năm
│   └── Radio: Khoảng thời gian
│
├── Date Pickers (động theo mode)
│   ├── Day mode: DatePicker chọn 1 ngày
│   ├── Month mode: Month + Year pickers
│   ├── Year mode: Year picker
│   └── Range mode: Start date + End date pickers
│
├── Transaction Type Selector
│   ├── Chip: Tất cả
│   ├── Chip: Thu nhập
│   └── Chip: Chi tiêu
│
├── Category Selector
│   └── Dropdown: Chọn category hoặc "Tất cả"
│
├── Preset Filters (Quick actions)
│   ├── Hôm nay
│   ├── Tuần này
│   ├── Tháng này
│   ├── Năm này
│   └── 7 ngày gần nhất
│
└── Action Buttons
    ├── Reset: Reset về mặc định
    └── Áp dụng: Trả về FilterOptions
```

### 🧩 StatisticsBloc

**File**: `presentation/bloc/statistics_bloc.dart`

**Vai trò**:

- Quản lý toàn bộ state của Statistics feature
- Xử lý tất cả events từ UI
- Gọi UseCase để lấy dữ liệu
- Lưu trữ filter hiện tại và pending filter

**Thuộc Tính**:

- `getStatisticsSummaryUseCase`: UseCase để lấy thống kê
- `_pendingFilter`: Filter tạm (user đang chỉnh trong modal)

**Event Handlers**:

| Event                 | Handler                    | Mô Tả                            |
| --------------------- | -------------------------- | -------------------------------- |
| `LoadStatistics`      | `_onLoadStatistics()`      | Load lần đầu với filter mặc định |
| `ChangeDateMode`      | `_onChangeDateMode()`      | Thay đổi chế độ thời gian        |
| `UpdateFilterOptions` | `_onUpdateFilterOptions()` | Cập nhật filter tạm (chưa apply) |
| `ApplyFilter`         | `_onApplyFilter()`         | Áp dụng filter và reload data    |
| `ResetFilter`         | `_onResetFilter()`         | Reset về filter mặc định         |
| `RefreshStatistics`   | `_onRefreshStatistics()`   | Refresh với filter hiện tại      |

---

## 5. Domain Layer

### 🎯 Entities

#### **FilterOptions**

**File**: `domain/entities/filter_options.dart`

**Mục đích**: Đại diện cho các tùy chọn lọc dữ liệu thống kê

**Thuộc Tính**:

- `dateMode`: Chế độ thời gian (Day/Month/Year/Range)
- `singleDate`: Ngày cụ thể (dùng cho Day mode)
- `month`: Tháng (1-12, dùng cho Month mode)
- `year`: Năm (dùng cho Month và Year mode)
- `startDate`: Ngày bắt đầu (dùng cho Range mode)
- `endDate`: Ngày kết thúc (dùng cho Range mode)
- `categoryId`: Lọc theo category (null = tất cả)
- `type`: Loại giao dịch (All/Income/Expense)

**Factory Methods**:

- `defaultFilter()`: Tháng hiện tại
- `today()`: Hôm nay
- `thisWeek()`: Tuần này
- `thisMonth()`: Tháng này
- `thisYear()`: Năm này
- `last7Days()`: 7 ngày gần nhất
- `last30Days()`: 30 ngày gần nhất

**Methods**:

- `getNormalizedDateRange()`: Convert filter thành DateTimeRange chuẩn

#### **StatisticsSummary**

**File**: `domain/entities/statistics_summary.dart`

**Mục đích**: Chứa kết quả thống kê đã tính toán

**Thuộc Tính**:

- `totalIncome`: Tổng thu nhập (double)
- `totalExpense`: Tổng chi tiêu (double)
- `balance`: Số dư = thu - chi (double)
- `incomeByCategory`: List thống kê thu theo category
- `expenseByCategory`: List thống kê chi theo category

#### **CategoryStatistics**

**File**: `domain/entities/statistics_summary.dart`

**Mục đích**: Thống kê của 1 category

**Thuộc Tính**:

- `categoryId`: ID category
- `categoryName`: Tên category
- `categoryIconCodePoint`: Icon code point
- `categoryIconFontFamily`: Font family của icon
- `categoryIconFontPackage`: Font package (nullable)
- `categoryColorValue`: Màu sắc (Color.value)
- `amount`: Tổng số tiền
- `percentage`: Phần trăm so với tổng (0-100)
- `transactionCount`: Số lượng giao dịch

### 🔧 UseCase

#### **GetStatisticsSummaryUseCase**

**File**: `domain/usecases/get_statistics_summary_usecase.dart`

**Vai trò**:

- Encapsulate business logic lấy thống kê
- Validate input (FilterOptions)
- Gọi repository để lấy dữ liệu

**Input**: `FilterOptions`

**Output**: `Either<Failure, StatisticsSummary>`

**Flow**:

```
call(FilterOptions params)
  ↓
Validate params (được thực hiện tự động)
  ↓
repository.getStatistics(filter: params)
  ↓
Return Either<Failure, StatisticsSummary>
```

### 📄 Repository Interface

#### **StatisticsRepository**

**File**: `domain/repositories/statistics_repository.dart`

**Vai trò**: Định nghĩa contract cho data layer

**Method**:

```dart
Future<Either<Failure, StatisticsSummary>> getStatistics({
  required FilterOptions filter,
});
```

**Đặc điểm**:

- Abstract class (interface)
- Không implement, chỉ define contract
- Data layer sẽ implement interface này
- Cho phép dễ dàng mock trong testing

---

## 6. Data Layer

### 💾 StatisticsRepositoryImpl

**File**: `data/repositories/statistics_repository_impl.dart`

**Vai trò**:

- Implement StatisticsRepository interface
- Xử lý logic lấy và tính toán dữ liệu thống kê
- Tương tác với DashboardLocalDataSource

**Dependencies**:

- `DashboardLocalDataSource`: Để query transactions và categories từ Hive

**Method: getStatistics()**

**Các Bước Xử Lý**:

```
Step 1: Normalize Date Range
├── Dựa vào dateMode trong filter
├── Convert thành startDate và endDate cụ thể
└── Ví dụ: Month 10/2025 → 01/10/2025 00:00:00 đến 31/10/2025 23:59:59

Step 2: Query Transactions
├── localDataSource.getTransactionsByDateRange(startDate, endDate)
├── Lấy tất cả transactions trong khoảng thời gian
└── Convert từ Model sang Entity

Step 3: Query Categories
├── localDataSource.getAllCategories()
├── Lấy tất cả categories để map thông tin
└── Tạo Map<categoryId, category> để lookup nhanh

Step 4: Filter By Type
├── Nếu filter.type == Income: Chỉ lấy transactions thu nhập
├── Nếu filter.type == Expense: Chỉ lấy transactions chi tiêu
└── Nếu filter.type == All: Giữ nguyên tất cả

Step 5: Filter By Category (Optional)
├── Nếu filter.categoryId != null
└── Chỉ lấy transactions của category đó

Step 6: Calculate Totals
├── Loop qua filtered transactions
├── Cộng dồn totalIncome (nếu type = Income)
├── Cộng dồn totalExpense (nếu type = Expense)
└── balance = totalIncome - totalExpense

Step 7: Group By Category
├── Tạo Map<categoryId, List<Transaction>>
├── Riêng cho Income: incomeByCategory
└── Riêng cho Expense: expenseByCategory

Step 8: Create CategoryStatistics
├── Loop qua từng category group
├── Tính amount = sum của tất cả transactions trong group
├── Tính percentage = (amount / total) * 100
├── Đếm transactionCount
├── Map thông tin category (name, icon, color)
└── Sắp xếp theo amount giảm dần

Step 9: Build StatisticsSummary
├── Gộp tất cả thông tin
└── Return Right(summary)

Step 10: Error Handling
├── Catch exceptions
└── Return Left(CacheFailure)
```

**Đặc Điểm**:

- Không có business logic phức tạp (đã có trong domain)
- Chỉ tập trung vào data processing
- Xử lý chuyển đổi Model ↔ Entity
- Xử lý errors và wrap trong Either

---

## 7. Ví Dụ Chi Tiết: Filter Theo Tháng

### 📅 Kịch Bản

> **User muốn xem thống kê chi tiêu của tháng 10/2025**

### 🎬 Luồng Xử Lý Chi Tiết

#### **Bước 1: User Mở Modal Filter**

```
StatisticsScreen
  ↓ User nhấn nút Filter (AppBar actions)
  ↓
showModalBottomSheet(
  context: context,
  builder: (_) => AdvancedFilterBottomSheet(
    currentFilter: bloc.pendingFilter,
  ),
)
  ↓
Bottom sheet hiển thị
```

**UI Modal Hiển Thị**:

- Date Mode: Đang chọn "Tháng" (default)
- Month Picker: Tháng 10
- Year Picker: 2025
- Type: Tất cả
- Category: Tất cả

#### **Bước 2: User Chọn Tháng 10/2025**

```
User tương tác với Month Picker
  ↓
setState() trong AdvancedFilterBottomSheet
  ↓
Update _selectedMonth = 10
Update _selectedYear = 2025
  ↓
UI rebuild, hiển thị "Tháng 10/2025"
```

**State Local Trong Modal**:

```dart
DateMode _dateMode = DateMode.month;
int _selectedMonth = 10;
int _selectedYear = 2025;
TransactionType _type = TransactionType.all;
String? _categoryId = null;
```

#### **Bước 3: User Nhấn "Áp Dụng"**

```
AdvancedFilterBottomSheet
  ↓
Tạo FilterOptions từ state hiện tại
  ↓
final options = FilterOptions(
  dateMode: DateMode.month,
  month: 10,
  year: 2025,
  type: TransactionType.all,
  categoryId: null,
);
  ↓
Navigator.pop(context); // Đóng modal
  ↓
Return về StatisticsScreen
```

#### **Bước 4: StatisticsScreen Nhận FilterOptions**

```
StatisticsScreen._showFilterBottomSheet()
  ↓
await showModalBottomSheet<FilterOptions>(...)
  ↓
if (result != null) {
  context.read<StatisticsBloc>().add(
    ApplyFilter(options: result),
  );
}
  ↓
Dispatch ApplyFilter event
```

#### **Bước 5: StatisticsBloc Xử Lý ApplyFilter**

```
StatisticsBloc._onApplyFilter(ApplyFilter event, Emitter emit)
  ↓
emit(StatisticsLoading())
  ↓ UI hiển thị loading indicator
  ↓
final result = await getStatisticsSummaryUseCase(event.options);
  ↓ Call UseCase với filter mới
```

**State Transition**:

```
StatisticsLoaded(filter: oldFilter, summary: oldSummary)
  ↓
StatisticsLoading()
  ↓
... processing ...
  ↓
StatisticsLoaded(filter: newFilter, summary: newSummary)
```

#### **Bước 6: UseCase Thực Thi**

```
GetStatisticsSummaryUseCase.call(FilterOptions params)
  ↓
params = FilterOptions(
  dateMode: DateMode.month,
  month: 10,
  year: 2025,
  type: TransactionType.all,
  categoryId: null,
)
  ↓
return await repository.getStatistics(filter: params);
```

#### **Bước 7: Repository Xử Lý**

```
StatisticsRepositoryImpl.getStatistics(filter)
  ↓
Step 1: Normalize date range
  ↓
startDate = DateTime(2025, 10, 1, 0, 0, 0)
endDate = DateTime(2025, 10, 31, 23, 59, 59)
  ↓
Step 2: Query transactions
  ↓
final transactions = await localDataSource
  .getTransactionsByDateRange(startDate, endDate);
  ↓
Giả sử có 50 transactions trong tháng 10/2025
  ↓
Step 3: Query categories
  ↓
final categories = await localDataSource.getAllCategories();
  ↓
Tạo categoryMap để lookup
  ↓
Step 4: Filter by type
  ↓
type = All → Giữ nguyên 50 transactions
  ↓
Step 5: Skip (categoryId = null)
  ↓
Step 6: Calculate totals
  ↓
Loop qua 50 transactions:
  - 20 transactions Income → totalIncome = 15,000,000 VNĐ
  - 30 transactions Expense → totalExpense = 8,500,000 VNĐ
  - balance = 15,000,000 - 8,500,000 = 6,500,000 VNĐ
  ↓
Step 7: Group by category
  ↓
Income group:
  - "Lương": [tx1, tx2, ...] → 12,000,000
  - "Thưởng": [tx10, tx11] → 3,000,000
Expense group:
  - "Ăn uống": [tx20, tx21, ...] → 3,500,000
  - "Đi lại": [tx30, tx31, ...] → 2,000,000
  - "Mua sắm": [tx40, tx41, ...] → 3,000,000
  ↓
Step 8: Create CategoryStatistics
  ↓
incomeStats = [
  CategoryStatistics(
    categoryName: "Lương",
    amount: 12,000,000,
    percentage: 80.0,
    transactionCount: 18,
    ...
  ),
  CategoryStatistics(
    categoryName: "Thưởng",
    amount: 3,000,000,
    percentage: 20.0,
    transactionCount: 2,
    ...
  ),
]

expenseStats = [
  CategoryStatistics(
    categoryName: "Ăn uống",
    amount: 3,500,000,
    percentage: 41.2,
    transactionCount: 12,
    ...
  ),
  CategoryStatistics(
    categoryName: "Mua sắm",
    amount: 3,000,000,
    percentage: 35.3,
    transactionCount: 10,
    ...
  ),
  CategoryStatistics(
    categoryName: "Đi lại",
    amount: 2,000,000,
    percentage: 23.5,
    transactionCount: 8,
    ...
  ),
]
  ↓
Step 9: Build summary
  ↓
final summary = StatisticsSummary(
  totalIncome: 15,000,000,
  totalExpense: 8,500,000,
  balance: 6,500,000,
  incomeByCategory: incomeStats,
  expenseByCategory: expenseStats,
);
  ↓
return Right(summary);
```

#### **Bước 8: Bloc Nhận Kết Quả**

```
StatisticsBloc._onApplyFilter() (continued)
  ↓
result.fold(
  (failure) => emit(StatisticsError(...)),
  (summary) {
    _pendingFilter = event.options; // Sync
    emit(StatisticsLoaded(
      activeFilter: event.options,
      summary: summary,
    ));
  },
);
```

**State Sau Khi Emit**:

```dart
StatisticsLoaded(
  activeFilter: FilterOptions(
    dateMode: DateMode.month,
    month: 10,
    year: 2025,
    type: TransactionType.all,
    categoryId: null,
  ),
  summary: StatisticsSummary(
    totalIncome: 15,000,000,
    totalExpense: 8,500,000,
    balance: 6,500,000,
    incomeByCategory: [2 items],
    expenseByCategory: [3 items],
  ),
)
```

#### **Bước 9: UI Rebuild**

```
BlocBuilder<StatisticsBloc, StatisticsState>
  ↓
state is StatisticsLoaded
  ↓
Rebuild TabBarView với data mới
  ↓
Tab 1 (Tất cả):
  ├── Filter info: "Tháng 10/2025"
  ├── Summary cards:
  │   ├── Tổng Thu: 15,000,000đ
  │   ├── Tổng Chi: 8,500,000đ
  │   └── Số Dư: +6,500,000đ
  └── BarChart: Cột thu (15M) vs cột chi (8.5M)

Tab 2 (Tổng Thu):
  ├── Summary: 15,000,000đ
  ├── PieChart:
  │   ├── Lương: 80% (màu xanh)
  │   └── Thưởng: 20% (màu vàng)
  └── CategoryList:
      ├── Lương: 12,000,000đ (80%) - 18 GD
      └── Thưởng: 3,000,000đ (20%) - 2 GD

Tab 3 (Tổng Chi):
  ├── Summary: 8,500,000đ
  ├── PieChart:
  │   ├── Ăn uống: 41.2% (màu đỏ)
  │   ├── Mua sắm: 35.3% (màu cam)
  │   └── Đi lại: 23.5% (màu xanh dương)
  └── CategoryList:
      ├── Ăn uống: 3,500,000đ (41.2%) - 12 GD
      ├── Mua sắm: 3,000,000đ (35.3%) - 10 GD
      └── Đi lại: 2,000,000đ (23.5%) - 8 GD
```

### 📊 Kết Quả Cuối Cùng

User thấy:

- ✅ Thống kê chi tiêu/thu nhập của tháng 10/2025
- ✅ Biểu đồ trực quan cho từng loại
- ✅ Chi tiết từng category với số tiền, phần trăm, số lượng giao dịch
- ✅ Có thể chuyển tab để xem riêng Thu hoặc Chi

---

## 8. Ưu Điểm Clean Architecture

### 🏆 Trong Feature Statistics

#### 1. **Tách Biệt Rõ Ràng (Separation of Concerns)**

```
Presentation (UI)
  └── Chỉ quan tâm: Hiển thị charts, handle user input

Domain (Business Logic)
  └── Chỉ quan tâm: Định nghĩa entities, use cases

Data (Data Access)
  └── Chỉ quan tâm: Query database, tính toán, mapping
```

**Lợi ích**:

- Dev UI không cần biết data được lưu ở đâu (Hive, API, SQLite...)
- Dev backend có thể thay đổi data source mà không ảnh hưởng UI
- Business logic độc lập, có thể tái sử dụng

#### 2. **Testability - Dễ Test**

**Domain Layer**:

```dart
// Test UseCase không cần database thật
test('GetStatisticsSummaryUseCase returns summary', () async {
  final mockRepository = MockStatisticsRepository();
  when(mockRepository.getStatistics(filter: any))
    .thenAnswer((_) async => Right(mockSummary));

  final useCase = GetStatisticsSummaryUseCase(mockRepository);
  final result = await useCase(FilterOptions.thisMonth());

  expect(result.isRight(), true);
});
```

**Presentation Layer**:

```dart
// Test Bloc không cần UseCase thật
blocTest<StatisticsBloc, StatisticsState>(
  'emits [Loading, Loaded] when ApplyFilter succeeds',
  build: () {
    when(mockUseCase.call(any))
      .thenAnswer((_) async => Right(mockSummary));
    return StatisticsBloc(getStatisticsSummaryUseCase: mockUseCase);
  },
  act: (bloc) => bloc.add(ApplyFilter(options: testFilter)),
  expect: () => [
    StatisticsLoading(),
    StatisticsLoaded(activeFilter: testFilter, summary: mockSummary),
  ],
);
```

#### 3. **Maintainability - Dễ Bảo Trì**

**Ví dụ: Thêm filter mới "Quý"**

```
Step 1: Update Domain
├── enum DateMode { ..., quarter } // domain/entities/filter_options.dart
├── Add quarter property to FilterOptions
└── Add getNormalizedDateRange() logic for quarter

Step 2: Update Data
├── Repository tự động xử lý (dựa vào startDate/endDate)
└── Không cần sửa gì thêm!

Step 3: Update Presentation
├── Add radio option trong AdvancedFilterBottomSheet
└── Add handler trong StatisticsBloc (nếu cần logic đặc biệt)

✅ Mỗi layer chỉ sửa ở phần liên quan
✅ Không ảnh hưởng lẫn nhau
```

#### 4. **Scalability - Dễ Mở Rộng**

**Ví dụ: Thêm chart mới (LineChart theo thời gian)**

```
Cần thêm:
├── Domain Layer
│   ├── Entity mới: TimeSeriesData
│   └── Method mới trong repository: getTimeSeriesData()
│
├── Data Layer
│   └── Implement getTimeSeriesData() trong repository impl
│
└── Presentation Layer
    ├── Widget mới: TimeSeriesLineChart
    └── Event/State mới nếu cần

Không cần sửa:
├── ✅ Các UseCase hiện tại
├── ✅ Các Entity hiện tại
└── ✅ UI của charts cũ
```

#### 5. **Reusability - Tái Sử Dụng**

**FilterOptions Entity**:

```
Được sử dụng ở nhiều nơi:
├── Statistics Feature (feature này)
├── Transaction List Feature (có thể filter transactions)
├── Export Report Feature (filter trước khi export)
└── Budget Feature (filter để tính budget usage)
```

**GetStatisticsSummaryUseCase**:

```
Có thể gọi từ:
├── StatisticsBloc (feature Statistics)
├── DashboardBloc (hiển thị tóm tắt trên Dashboard)
├── ReportBloc (tạo report PDF)
└── Widget Builder (custom widget ở bất kỳ đâu)
```

#### 6. **Dependency Rule - Không Phụ Thuộc Ngược**

```
Direction of Dependencies:
Presentation ──> Domain <── Data
      │                        │
      └────── Concrete ────────┘

Domain không biết gì về:
  ✅ Flutter widgets
  ✅ Hive database
  ✅ BLoC pattern
  ✅ UI framework

Domain chỉ chứa:
  ✅ Pure Dart objects
  ✅ Business rules
  ✅ Abstract interfaces
```

**Lợi ích**:

- Domain có thể chạy trên bất kỳ platform nào (Web, Desktop, CLI...)
- Domain có thể test nhanh chóng (không cần Flutter framework)
- Thay đổi UI framework không ảnh hưởng domain

#### 7. **Error Handling Nhất Quán**

```
Repository returns: Either<Failure, StatisticsSummary>
  ↓
UseCase returns: Either<Failure, StatisticsSummary>
  ↓
Bloc handles: result.fold(
  (failure) => emit(StatisticsError(...)),
  (success) => emit(StatisticsLoaded(...)),
)
  ↓
UI shows: Error widget hoặc Data widget
```

**Ưu điểm**:

- Error được handle nhất quán ở mọi layer
- Dễ thêm error tracking (Sentry, Firebase Crashlytics)
- User luôn thấy thông báo lỗi hợp lý

#### 8. **Flexibility - Linh Hoạt Thay Đổi Data Source**

**Hiện tại**: Dữ liệu từ Hive (local)

**Nếu muốn sync với server**:

```
Step 1: Tạo RemoteDataSource
├── class StatisticsRemoteDataSource
└── Future<StatisticsSummaryModel> getStatisticsFromApi(filter)

Step 2: Update Repository Impl
├── Thêm dependency: RemoteDataSource
└── Logic: Try remote first, fallback to local
    ↓
    try {
      final remote = await remoteDataSource.getStatistics(filter);
      await localDataSource.cacheStatistics(remote); // Cache
      return Right(remote.toEntity());
    } catch (e) {
      // Fallback to cache
      final local = await localDataSource.getStatistics(filter);
      return Right(local.toEntity());
    }

✅ Domain Layer: KHÔNG ĐỔI GÌ CẢ!
✅ Presentation Layer: KHÔNG ĐỔI GÌ CẢ!
✅ Chỉ sửa Data Layer (Repository Impl)
```

---

## 9. Tổng Kết

### ✨ Key Takeaways

1. **Statistics Feature** cung cấp công cụ mạnh mẽ để phân tích tài chính cá nhân
2. **Filter linh hoạt** với nhiều chế độ: Day, Month, Year, Range
3. **Biểu đồ trực quan**: PieChart, BarChart giúp dễ hiểu dữ liệu
4. **Clean Architecture** đảm bảo code dễ maintain, test, và scale

### 🎯 Luồng Chính Cần Nhớ

```
UI (StatisticsScreen)
  ↓ [Event]
Bloc (StatisticsBloc)
  ↓ [UseCase Call]
UseCase (GetStatisticsSummaryUseCase)
  ↓ [Repository Call]
Repository Interface (StatisticsRepository)
  ↓ [Implementation]
Repository Impl (StatisticsRepositoryImpl)
  ↓ [Data Query & Calculation]
Data Source (DashboardLocalDataSource → Hive)
  ↑ [StatisticsSummary]
Back to Bloc
  ↑ [State]
UI Updates với Charts & Lists
```

### 🚀 Điểm Mạnh Của Thiết Kế

- ✅ **Separation of Concerns**: Mỗi layer có trách nhiệm riêng
- ✅ **Testable**: Mock dễ dàng, test độc lập từng layer
- ✅ **Maintainable**: Sửa đổi một chỗ không ảnh hưởng các chỗ khác
- ✅ **Scalable**: Dễ thêm features mới
- ✅ **Reusable**: Entities, UseCases có thể dùng lại
- ✅ **Flexible**: Đổi data source không cần sửa business logic

### 📚 Tài Liệu Liên Quan

- [Category Feature Technical Guide](./CATEGORY_FEATURE_TECHNICAL_GUIDE.md)
- [Transaction Feature Technical Guide](./TRANSACTION_FEATURE_TECHNICAL_GUIDE.md)
- [Dashboard Feature Technical Guide](./DASHBOARD_FEATURE_TECHNICAL_GUIDE.md)

---

**Tác giả**: Development Team  
**Cập nhật lần cuối**: October 31, 2025  
**Version**: 1.0.0
