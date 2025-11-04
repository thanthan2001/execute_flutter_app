# 📈 Statistics Feature - Luồng Xử Lý Dữ Liệu

## 📋 Tổng Quan

Statistics feature cung cấp phân tích chi tiết về giao dịch với các bộ lọc nâng cao, biểu đồ trực quan và thống kê chuyên sâu.

### 🎯 Chức Năng Chính

- **Phân tích chi tiết:** Thống kê theo category, theo thời gian, theo loại
- **Bộ lọc nâng cao:** Lọc theo ngày/tháng/năm/khoảng thời gian, theo category, theo loại giao dịch
- **Biểu đồ đa dạng:** Pie chart (phân bổ), Bar chart (xu hướng), Line chart (timeline)
- **So sánh:** So sánh thu chi, so sánh periods
- **Export:** Xuất báo cáo (future)

---

## 🏗️ Kiến Trúc Clean Architecture

### Cấu Trúc 3 Tầng

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)         │
│  - StatisticsScreen                 │
│  - StatisticsBloc                   │
│  - AdvancedFilterBottomSheet        │
│  - Chart Widgets                    │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│        Domain Layer (Logic)         │
│  - StatisticsSummary Entity         │
│  - FilterOptions Entity             │
│  - GetStatisticsUseCase             │
│  - StatisticsRepository Interface   │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      Data Layer (Analysis)          │
│  - StatisticsRepositoryImpl         │
│  - Inject TransactionLocalDataSource│
│  - Inject CategoryLocalDataSource   │
│  - Phân tích và tính toán           │
└─────────────┬───────────────────────┘
              │
              ▼
    [TransactionLocalDataSource]
    [CategoryLocalDataSource]
```

### Đặc Điểm Riêng

**Statistics inject TRỰC TIẾP DataSources!**

```
Khác với Dashboard (inject Repository)
Statistics inject cả 2 DataSources:
  - TransactionLocalDataSource: Lấy transactions
  - CategoryLocalDataSource: Lấy category info

Lý do:
  - Cần control query chính xác
  - Cần join data từ 2 sources
  - Performance optimization
  - Complex filtering logic
```

---

## 🔄 Luồng Xử Lý Dữ Liệu

### 1. Load Statistics Với Filter Mặc Định

```
User navigate to Statistics Tab
         ↓
StatisticsScreen initState()
         ↓
Tạo FilterOptions mặc định:
  - dateMode: month (tháng hiện tại)
  - month: tháng hiện tại
  - year: năm hiện tại
  - type: all (tất cả transactions)
  - categoryId: null (tất cả categories)
         ↓
UI dispatch LoadStatisticsEvent(filterOptions)
         ↓
StatisticsBloc nhận event
         ↓
BLoC emit StatisticsLoadingState
         ↓
BLoC gọi GetStatisticsUseCase.call(filter)
         ↓
UseCase gọi StatisticsRepository.getStatistics(filter)
         ↓
Repository bắt đầu xử lý:

Bước 1: Normalize date range từ filter
  → FilterOptions.getNormalizedDateRange()
  → Trả về (startDate, endDate)
  → Ví dụ: Tháng 11/2025 → (2025-11-01 00:00:00, 2025-11-30 23:59:59)

Bước 2: Lấy transactions trong khoảng thời gian
  → Gọi transactionDataSource.getTransactionsByDateRange(startDate, endDate)
  → DataSource filter transactions:
    - !transaction.date.isBefore(startDate)
    - !transaction.date.isAfter(endDate)
  → Trả về List<TransactionModel>

Bước 3: Convert Models → Entities
  → Lặp qua models, gọi model.toEntity()
  → Có List<TransactionEntity>

Bước 4: Lấy tất cả categories để map thông tin
  → Gọi categoryDataSource.getAllCategories()
  → Trả về List<CategoryModel>
  → Convert → List<CategoryEntity>
  → Tạo Map: categoryId → CategoryEntity

Bước 5: Filter transactions theo type (nếu có)
  → Nếu filter.type == income:
    - Chỉ giữ transactions có type = income
  → Nếu filter.type == expense:
    - Chỉ giữ transactions có type = expense
  → Nếu filter.type == all:
    - Giữ tất cả

Bước 6: Filter theo category (nếu có)
  → Nếu filter.categoryId != null:
    - Chỉ giữ transactions có categoryId = filter.categoryId

Bước 7: Tính tổng thu và tổng chi
  → Loop qua filteredTransactions:
    - Nếu type = income: totalIncome += amount
    - Nếu type = expense: totalExpense += amount

Bước 8: Group theo category
  → Tạo 2 Maps:
    - incomeByCategory: Map<categoryId, List<TransactionEntity>>
    - expenseByCategory: Map<categoryId, List<TransactionEntity>>
  → Loop và phân loại

Bước 9: Tạo CategoryStatistics
  → Với mỗi category có transactions:
    - Tính tổng amount
    - Đếm số lượng transactions
    - Lấy thông tin category (name, icon, color)
    - Tính percentage: (categoryAmount / totalAmount) * 100
    - Tạo CategoryStatistics entity

Bước 10: Sort category statistics
  → Sort theo amount DESC (nhiều nhất lên đầu)

Bước 11: Tạo StatisticsSummary
  → Gán tất cả dữ liệu đã tính:
    - totalIncome, totalExpense, balance
    - incomeCategories: List<CategoryStatistics>
    - expenseCategories: List<CategoryStatistics>
    - transactionCount, averageTransaction
    - filter: FilterOptions (để UI biết filter hiện tại)
         ↓
Repository trả Either<Failure, StatisticsSummary>
         ↓
UseCase trả về BLoC
         ↓
BLoC emit StatisticsLoadedState(summary)
         ↓
UI rebuild với dữ liệu:
  - Header: Tổng quan (thu, chi, số dư)
  - Pie Chart: Phân bổ chi tiêu theo category
  - Bar Chart: Top categories
  - List: Chi tiết từng category với %
  - Transaction count và average
```

**Xử lý lỗi:**

- DataSource lỗi → emit StatisticsErrorState
- Không có data → emit Empty state
- UI hiển thị error với retry button

---

### 2. Thay Đổi Filter

```
User tap vào Filter button trên StatisticsScreen
         ↓
UI mở AdvancedFilterBottomSheet
         ↓
Bottom sheet hiển thị các options:

┌─────────────────────────────────────┐
│  Bộ Lọc Nâng Cao                    │
├─────────────────────────────────────┤
│  Thời gian:                         │
│  ○ Ngày     [Chọn ngày]            │
│  ○ Tháng    [Chọn tháng/năm]      │
│  ● Năm      [Chọn năm]             │
│  ○ Khoảng   [Từ] [Đến]            │
├─────────────────────────────────────┤
│  Loại giao dịch:                    │
│  ● Tất cả                           │
│  ○ Thu nhập                         │
│  ○ Chi tiêu                         │
├─────────────────────────────────────┤
│  Danh mục:                          │
│  [Dropdown] Tất cả danh mục ▼      │
├─────────────────────────────────────┤
│  [Hủy]           [Áp dụng]         │
└─────────────────────────────────────┘
         ↓
User chọn:
  - Thời gian: Năm 2025
  - Loại: Chi tiêu
  - Danh mục: "Ăn uống"
         ↓
User nhấn "Áp dụng"
         ↓
UI tạo FilterOptions mới:
  - dateMode: year
  - year: 2025
  - type: expense
  - categoryId: "an-uong-id"
         ↓
UI dispatch LoadStatisticsEvent(newFilter)
         ↓
BLoC nhận event → gọi UseCase với filter mới
         ↓
Repository xử lý với filter mới:

  → Normalize date: 2025-01-01 đến 2025-12-31
  → Lấy transactions trong năm 2025
  → Filter chỉ expense
  → Filter chỉ category "Ăn uống"
  → Tính toán statistics chỉ với subset này
         ↓
BLoC emit StatisticsLoadedState(newSummary)
         ↓
UI rebuild:
  - Header hiển thị filter: "Năm 2025 - Chi tiêu - Ăn uống"
  - Charts chỉ hiển thị data của "Ăn uống"
  - Statistics chi tiết cho category này
  - Show transactions list của category
```

**Filter Combinations:**

```
Date Modes:
  1. Day: Chọn 1 ngày cụ thể
  2. Month: Chọn tháng + năm
  3. Year: Chọn năm
  4. Range: Chọn startDate + endDate

Transaction Types:
  - All: Tất cả transactions
  - Income: Chỉ thu nhập
  - Expense: Chỉ chi tiêu

Category Filter:
  - null: Tất cả categories
  - categoryId: 1 category cụ thể
```

---

### 3. Chuyển Đổi Giữa Các Chế Độ Xem

```
StatisticsScreen có 3 tabs:

Tab 1: Tổng Quan (Overview)
  → Pie chart phân bổ
  → Tổng thu, tổng chi, số dư
  → Top categories

Tab 2: Thu Nhập (Income)
  → Filter tự động: type = income
  → Dispatch LoadStatisticsEvent với filter type=income
  → Hiển thị chỉ income statistics
  → Bar chart thu nhập theo category
  → List categories thu nhập

Tab 3: Chi Tiêu (Expense)
  → Filter tự động: type = expense
  → Dispatch LoadStatisticsEvent với filter type=expense
  → Hiển thị chỉ expense statistics
  → Pie chart chi tiêu theo category
  → List categories chi tiêu với %
```

**Tab Switching Flow:**

```
User tap vào "Chi tiêu" tab
         ↓
UI update FilterOptions:
  - Giữ nguyên dateMode, date range
  - Thay đổi type = expense
  - Giữ nguyên categoryId (nếu có)
         ↓
UI dispatch LoadStatisticsEvent(updatedFilter)
         ↓
BLoC load lại data với filter mới
         ↓
UI hiển thị expense statistics
```

---

### 4. Drill Down Vào Category

```
User tap vào category "Ăn uống" trong Pie Chart
         ↓
UI navigate to Category Detail Screen (hoặc update filter)
         ↓
Option 1: Update current screen
  → UI update FilterOptions: categoryId = "an-uong"
  → Dispatch LoadStatisticsEvent
  → Hiển thị statistics chỉ cho "Ăn uống"
  → Hiển thị list transactions của category này

Option 2: Navigate to new screen
  → CategoryDetailScreen(categoryId, dateRange)
  → Load transactions của category
  → Hiển thị timeline
  → Hiển thị xu hướng chi tiêu
```

---

### 5. So Sánh Các Khoảng Thời Gian

```
User chọn "So sánh" mode
         ↓
UI hiển thị 2 date range pickers:
  - Period 1: [Tháng 10/2025]
  - Period 2: [Tháng 11/2025]
         ↓
User chọn và nhấn "So sánh"
         ↓
UI dispatch 2 LoadStatisticsEvent song song:
  - Event 1 với filter period 1
  - Event 2 với filter period 2
         ↓
BLoC load 2 StatisticsSummary
         ↓
BLoC emit CompareStatisticsLoadedState(summary1, summary2)
         ↓
UI hiển thị comparison:
  - Side by side comparison
  - Percentage change: +20% chi tiêu
  - Charts overlay
  - Top changes categories
```

---

## 📦 Data Flow Chi Tiết

### Domain Layer

**FilterOptions Entity:**

```
Thuộc tính:
- dateMode: DateMode (day/month/year/range)
- singleDate: DateTime? (cho mode day)
- month: int? (1-12, cho mode month)
- year: int? (cho mode month và year)
- startDate: DateTime? (cho mode range)
- endDate: DateTime? (cho mode range)
- categoryId: String? (filter theo category)
- type: TransactionType (all/income/expense)

Methods:
- getNormalizedDateRange(): (DateTime start, DateTime end)
  → Convert filter options → concrete date range
  → Xử lý logic phức tạp của từng mode
```

**StatisticsSummary Entity:**

```
Thuộc tính:
- totalIncome: double
- totalExpense: double
- balance: double
- incomeCategories: List<CategoryStatistics>
- expenseCategories: List<CategoryStatistics>
- transactionCount: int
- averageTransaction: double
- filter: FilterOptions (để track filter hiện tại)

CategoryStatistics:
- category: CategoryEntity (id, name, icon, color)
- amount: double (tổng amount)
- transactionCount: int (số lượng)
- percentage: double (% so với tổng)
- transactions: List<TransactionEntity> (chi tiết)
```

**Repository Interface:**

```
StatisticsRepository:
- getStatistics(filter: FilterOptions):
  → Either<Failure, StatisticsSummary>
  → Main method để lấy statistics với filter
```

**UseCase:**

```
GetStatisticsUseCase:
- Input: StatisticsParams(filter: FilterOptions)
- Output: Either<Failure, StatisticsSummary>
- Logic: Validate filter → call repository
```

---

### Data Layer

**StatisticsRepositoryImpl:**

**Dependencies:**

```
Inject:
- TransactionLocalDataSource (để query transactions)
- CategoryLocalDataSource (để lấy category info)

Không inject:
- TransactionRepository (không cần vì cần control trực tiếp query)
- CategoryRepository (tương tự)
```

**Method getStatistics() Chi Tiết:**

```
Bước 1: Normalize Date Range
  → Gọi filter.getNormalizedDateRange()
  → Xử lý từng dateMode:

    DateMode.day:
      → startDate = singleDate at 00:00:00
      → endDate = singleDate at 23:59:59

    DateMode.month:
      → startDate = DateTime(year, month, 1)
      → endDate = DateTime(year, month+1, 0, 23, 59, 59)
      → Ví dụ: Tháng 11 → 2025-11-01 đến 2025-11-30 23:59:59

    DateMode.year:
      → startDate = DateTime(year, 1, 1)
      → endDate = DateTime(year, 12, 31, 23, 59, 59)

    DateMode.range:
      → startDate = filter.startDate
      → endDate = filter.endDate

Bước 2: Query Transactions
  → transactionDataSource.getTransactionsByDateRange(start, end)
  → DataSource filter chính xác:
    - !date.isBefore(start) AND !date.isAfter(end)
  → Trả List<TransactionModel>

Bước 3: Convert và Filter
  → Convert models → entities
  → Apply type filter:
    - all: Giữ tất cả
    - income: Filter type = income
    - expense: Filter type = expense
  → Apply category filter:
    - null: Giữ tất cả
    - categoryId: Filter matching categoryId

Bước 4: Load Categories
  → categoryDataSource.getAllCategories()
  → Convert → entities
  → Tạo Map<categoryId, CategoryEntity>

Bước 5: Calculate Totals
  → totalIncome = sum(transactions where type=income)
  → totalExpense = sum(transactions where type=expense)
  → balance = totalIncome - totalExpense
  → transactionCount = filteredTransactions.length
  → averageTransaction = (totalIncome + totalExpense) / count

Bước 6: Group By Category
  → Loop filteredTransactions:
    - If income: Add to incomeByCategory[categoryId]
    - If expense: Add to expenseByCategory[categoryId]

Bước 7: Create CategoryStatistics
  → For each category group:
    - Get category info from map
    - Calculate total amount
    - Count transactions
    - Calculate percentage = (amount / totalAmount) * 100
    - Create CategoryStatistics object

Bước 8: Sort
  → Sort incomeCategories by amount DESC
  → Sort expenseCategories by amount DESC

Bước 9: Create Summary
  → Tạo StatisticsSummary với all data
  → Include filter để UI biết context

Bước 10: Return
  → Right(statisticsSummary)

Error Handling:
  → Catch any exception
  → Log error
  → Return Left(CacheFailure(message))
```

**Date Filter Implementation:**

```
DataSource method: getTransactionsByDateRange(start, end)

Logic:
  allTransactions = box.values.toList()
  filtered = allTransactions.where((tx) {
    return !tx.date.isBefore(start) && !tx.date.isAfter(end)
  })
  return filtered.toList()

Đảm bảo:
  - Inclusive start date
  - Inclusive end date
  - Không bị off-by-one error
```

---

### Presentation Layer

**StatisticsBloc:**

**Events:**

```
- LoadStatisticsEvent:
  - filter: FilterOptions
  - Trigger load statistics với filter cụ thể

- UpdateFilterEvent:
  - newFilter: FilterOptions
  - Update filter và reload

- ComparePeriodsEvent:
  - filter1: FilterOptions
  - filter2: FilterOptions
  - Load và so sánh 2 periods
```

**States:**

```
- StatisticsInitialState

- StatisticsLoadingState:
  - Hiển thị loading

- StatisticsLoadedState:
  - summary: StatisticsSummary
  - Chứa tất cả data đã tính toán

- StatisticsEmptyState:
  - Không có transactions trong filter
  - Hiển thị empty state với gợi ý

- StatisticsErrorState:
  - error: String
  - Hiển thị error với retry

- CompareStatisticsLoadedState:
  - summary1: StatisticsSummary
  - summary2: StatisticsSummary
  - change: ComparisonResult
```

**UI Components:**

**1. StatisticsScreen (Main Page):**

```
Layout:
┌─────────────────────────────────────┐
│  AppBar                             │
│  "Thống kê"    [Filter] [Compare]  │
├─────────────────────────────────────┤
│  Filter Chips (nếu có):            │
│  [x Tháng 11] [x Chi tiêu]         │
├─────────────────────────────────────┤
│  Tabs: Tổng quan | Thu | Chi       │
├─────────────────────────────────────┤
│  Summary Header:                    │
│  Thu: 5M | Chi: 3M | Số dư: +2M    │
├─────────────────────────────────────┤
│  Pie Chart (Expense breakdown)      │
│  ┌──────────────────┐               │
│  │    ▓▓▓▓▓         │               │
│  │  ▓▓▓▓▓▓▓▓        │               │
│  │    ▓▓▓▓          │               │
│  └──────────────────┘               │
├─────────────────────────────────────┤
│  Category List:                     │
│  🍴 Ăn uống    1,200,000đ  40% ▓▓▓ │
│  🚗 Di chuyển    800,000đ  27% ▓▓  │
│  🛒 Mua sắm      500,000đ  17% ▓   │
│  ⚡ Giải trí     480,000đ  16% ▓   │
├─────────────────────────────────────┤
│  Detail Stats:                      │
│  Số giao dịch: 45                   │
│  Trung bình: 66,667đ/giao dịch     │
└─────────────────────────────────────┘
```

**2. AdvancedFilterBottomSheet:**

```
Sections:
1. Date Filter:
   - Radio group: Day/Month/Year/Range
   - Conditional pickers dựa vào selection
   - Validation: startDate <= endDate

2. Type Filter:
   - Radio group: All/Income/Expense
   - Default: All

3. Category Filter:
   - Dropdown với search
   - Load từ CategoryRepository
   - Group by type
   - Show icon + color + name

4. Actions:
   - Reset button: Clear filters
   - Cancel button: Close sheet
   - Apply button: Apply và load data
```

**3. Pie Chart Widget:**

```
Features:
- Hiển thị top 6 categories (lớn nhất)
- Others category cho phần còn lại
- Touch interaction: Tap để highlight
- Legend với màu sắc categories
- Percentage labels
- Animation khi load
- Center text: Tổng amount
```

**4. Category Statistics List:**

```
Mỗi item:
- Icon với màu category
- Tên category
- Amount (format #,###đ)
- Percentage bar
- Transaction count badge
- Tap → Navigate to category detail
- Show trend icon (↑↓) nếu có comparison
```

**5. Comparison View:**

```
Layout: Split screen
Left: Period 1 data
Right: Period 2 data

Highlights:
- Percentage change cards
- Color coded (green up, red down)
- Diff arrows
- Charts overlay với 2 colors
- Top increases/decreases categories
```

---

## 🔗 Dependencies và Tương Tác

### Với Transaction Feature

**Statistics → TransactionLocalDataSource:**

```
Direct injection (không qua Repository)
Lý do:
  - Cần query flexibility
  - Performance optimization
  - Complex filtering
  - Custom date range logic

Statistics KHÔNG modify transactions
Chỉ read-only operations
```

### Với Category Feature

**Statistics → CategoryLocalDataSource:**

```
Direct injection để lấy category info
Load 1 lần để map categoryId → CategoryEntity
Cache trong BLoC state
Reuse cho subsequent calculations
```

---

## 🎯 Business Logic

### Date Range Normalization

**Challenge:**

```
User có thể chọn nhiều loại filters:
- Ngày cụ thể
- Tháng + năm
- Năm
- Khoảng thời gian tùy chỉnh

Cần normalize tất cả về (startDate, endDate)
```

**Solution:**

```
FilterOptions.getNormalizedDateRange() method:

Xử lý từng case:
1. Day mode:
   - start/end trong cùng ngày

2. Month mode:
   - start = ngày 1 của tháng
   - end = ngày cuối của tháng
   - Handle edge cases (tháng 2, năm nhuận)

3. Year mode:
   - start = 1/1 của năm
   - end = 31/12 của năm

4. Range mode:
   - Validate startDate <= endDate
   - Return as-is

Return tuple (start, end) để dễ sử dụng
```

### Category Statistics Calculation

**Requirement:**

```
Tính tổng amount cho mỗi category
Tính percentage so với tổng
Tính transaction count
Sort theo amount
```

**Algorithm:**

```
1. Group transactions by categoryId
2. For each group:
   - Sum amounts
   - Count transactions
3. Calculate total amount across all groups
4. For each group:
   - percentage = (groupAmount / totalAmount) * 100
5. Sort groups by amount DESC
6. Create CategoryStatistics objects
7. Attach category info (name, icon, color)
```

### Empty State Handling

**Cases:**

```
Case 1: Không có transactions nào
  → "Chưa có giao dịch"
  → Button "Thêm giao dịch đầu tiên"

Case 2: Có transactions nhưng không match filter
  → "Không có giao dịch trong khoảng thời gian này"
  → Button "Thay đổi bộ lọc"
  → Show current filter
  → Suggest: "Thử chọn tháng khác"

Case 3: Category không có transactions
  → "Chưa có giao dịch cho danh mục này"
  → Button "Thêm giao dịch"
```

---

## 🎨 UI/UX Flow

### Happy Path - Xem Thống Kê

```
1. User tap "Thống kê" tab
2. UI load với filter default (tháng hiện tại)
3. Loading skeleton hiển thị
4. Data load xong:
   - Summary cards animate in
   - Pie chart draw với animation
   - Category list fade in
5. User xem tổng quan
6. User scroll để xem chi tiết
7. User tap category → Drill down
8. User back → Quay lại statistics
```

### Filter Workflow

```
1. User tap Filter button
2. AdvancedFilterBottomSheet slide up
3. Current filter pre-selected
4. User thay đổi:
   - Chọn "Năm 2025"
   - Chọn "Chi tiêu"
5. User tap "Áp dụng"
6. Sheet close
7. Loading overlay
8. Data reload với filter mới
9. UI update:
   - Header hiển thị filter active
   - Charts redraw
   - Numbers update với animation
10. Filter chips hiển thị (có thể xóa quick)
```

### Comparison Workflow

```
1. User tap "So sánh" button
2. UI show comparison dialog
3. User chọn 2 periods:
   - Period 1: Tháng 10
   - Period 2: Tháng 11
4. User tap "So sánh"
5. Load 2 datasets song song
6. UI hiển thị split view
7. Highlight changes:
   - Chi tiêu tăng 20%
   - Ăn uống tăng nhất: +30%
   - Di chuyển giảm: -15%
8. User có thể switch views
9. User tap "Đóng" → Back to normal view
```

---

## 📊 Performance Considerations

**Query Optimization:**

```
- Filter ở DataSource level (Hive query)
- Không load tất cả rồi filter in-memory
- Use indexed queries nếu có
- Cache category info (load 1 lần)
```

**Computation:**

```
- Group operations efficient với Map
- Single pass để tính totals
- Lazy evaluation cho charts
- Throttle filter changes (debounce)
```

**Memory:**

```
- Không giữ raw transactions in state
- Chỉ giữ aggregated data
- Release resources khi dispose
- Use const widgets where possible
```

---

## ✅ Implementation Checklist

- [x] FilterOptions entity với getNormalizedDateRange()
- [x] StatisticsSummary entity
- [x] CategoryStatistics entity
- [x] StatisticsRepository interface
- [x] StatisticsRepositoryImpl inject 2 DataSources
- [x] GetStatisticsUseCase
- [x] StatisticsBloc với comprehensive events/states
- [x] StatisticsScreen UI
- [x] AdvancedFilterBottomSheet
- [x] Pie Chart widget
- [x] Bar Chart widget
- [x] Category statistics list
- [x] Summary cards
- [x] Empty states
- [x] Error handling
- [x] Date range normalization logic
- [x] Category statistics calculation

---

## 🔮 Future Enhancements

**Version 2.0:**

- Line charts cho timeline
- Heatmap calendar view
- Trend analysis (tăng/giảm theo time)
- Anomaly detection (chi tiêu bất thường)

**Version 3.0:**

- Custom report builder
- Scheduled reports (email/notification)
- Export to Excel, PDF, Google Sheets
- AI insights và recommendations

**Version 4.0:**

- Budget vs Actual tracking
- Forecast future spending (ML)
- Goal tracking
- Multi-currency support với conversion

---

## 🎓 Design Decisions

**1. Why Inject DataSources Directly?**

```
Pros:
- Fine-grained query control
- Better performance (no extra layer)
- Complex filtering logic
- Join operations between 2 sources

Cons:
- Couple với implementation
- Harder to swap data sources

Decision: Pros outweigh cons cho Statistics feature
```

**2. Why Separate FilterOptions Entity?**

```
Pros:
- Reusable across features
- Encapsulate filter logic
- Easy to serialize (save user preferences)
- Type-safe

Better than: Map<String, dynamic> filter
```

**3. Why CategoryStatistics Separate Entity?**

```
Pros:
- Clear structure
- Include all needed info
- Easier to test
- Better type checking

Alternative: Just use Map
Rejected: Không type-safe, khó maintain
```

Đây là mô hình hoàn chỉnh của Statistics Feature! 📈
