# 📊 Dashboard Feature - Luồng Xử Lý Dữ Liệu

## 📋 Tổng Quan

Dashboard feature hiển thị tổng quan tài chính với các thống kê tổng hợp từ transactions. Đây là trang chính khi người dùng mở app.

### 🎯 Chức Năng Chính

- **Tổng quan tài chính:** Hiển thị tổng thu, tổng chi, số dư
- **Thống kê theo category:** Top chi tiêu, top thu nhập
- **Biểu đồ theo tháng:** Bar chart thu chi 6 tháng gần nhất
- **Filter theo thời gian:** Hôm nay, tuần này, tháng này, tùy chỉnh
- **Quick actions:** Thêm giao dịch nhanh, xem chi tiết

---

## 🏗️ Kiến Trúc Clean Architecture

### Cấu Trúc Đơn Giản

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)         │
│  - DashboardPage                    │
│  - DashboardBloc                    │
│  - Widgets (cards, charts)          │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│        Domain Layer (Logic)         │
│  - DashboardSummary Entity          │
│  - GetDashboardSummaryUseCase       │
│  - DashboardRepository Interface    │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      Data Layer (Aggregation)       │
│  - DashboardRepositoryImpl          │
│  - Inject TransactionRepository     │
│  - Tính toán statistics             │
└─────────────┬───────────────────────┘
              │
              ▼
    [TransactionRepository]
    (Không trực tiếp truy cập DB)
```

### Điểm Đặc Biệt

**Dashboard KHÔNG có DataSource riêng!**

- Không trực tiếp truy cập Hive
- Chỉ inject TransactionRepository
- Lấy transactions qua repository
- Tính toán và tổng hợp dữ liệu
- Tuân thủ Clean Architecture: Feature không can thiệp vào data của feature khác

---

## 🔄 Luồng Xử Lý Dữ Liệu

### 1. Load Dashboard Summary

```
User mở app → Dashboard Page hiển thị
         ↓
DashboardPage initState()
         ↓
UI dispatch LoadDashboardSummaryEvent
         ↓
DashboardBloc nhận event
         ↓
BLoC emit DashboardLoadingState
         ↓
BLoC gọi GetDashboardSummaryUseCase.call()
         ↓
UseCase gọi DashboardRepository.getDashboardSummary()
         ↓
Repository gọi TransactionRepository.getAllTransactions()
         ↓
Transaction Repository trả về Either<Failure, List<TransactionEntity>>
         ↓
Dashboard Repository nhận danh sách transactions
         ↓
Repository tính toán:
  1. Filter transactions trong khoảng thời gian (startDate → endDate)
  2. Tính tổng thu (totalIncome):
     - Lặp qua transactions có type = income
     - Cộng dồn amount
  3. Tính tổng chi (totalExpense):
     - Lặp qua transactions có type = expense
     - Cộng dồn amount
  4. Tính số dư (balance = totalIncome - totalExpense)
  5. Group chi tiêu theo category (expenseByCategory):
     - Map<categoryId, totalAmount>
  6. Group thu nhập theo category (incomeByCategory):
     - Map<categoryId, totalAmount>
  7. Tính dữ liệu theo tháng (monthlyData):
     - Group transactions theo month-year
     - Tính tổng thu/chi cho mỗi tháng
     - Sort theo thời gian
         ↓
Repository tạo DashboardSummary entity với tất cả dữ liệu
         ↓
Repository trả Either<Failure, DashboardSummary>
         ↓
UseCase trả về BLoC
         ↓
BLoC emit DashboardLoadedState(summary)
         ↓
UI rebuild với dữ liệu mới:
  - Summary Cards (Thu/Chi/Số dư)
  - Top Categories Chart
  - Monthly Bar Chart
```

**Xử lý lỗi:**

- TransactionRepository trả lỗi → emit DashboardErrorState
- UI hiển thị error message với retry button

---

### 2. Filter Theo Thời Gian

```
User tap vào filter button trên Dashboard
         ↓
UI hiển thị bottom sheet với options:
  - Hôm nay (Today)
  - Tuần này (This Week)
  - Tháng này (This Month)
  - Năm nay (This Year)
  - Tùy chỉnh (Custom Range)
         ↓
User chọn "Tháng này"
         ↓
UI tính toán date range:
  - startDate = Ngày 1 của tháng hiện tại, 00:00:00
  - endDate = Ngày cuối tháng, 23:59:59
         ↓
UI dispatch LoadDashboardSummaryEvent(startDate, endDate)
         ↓
BLoC emit DashboardLoadingState
         ↓
BLoC gọi UseCase với parameters: startDate, endDate
         ↓
UseCase gọi Repository.getDashboardSummary(startDate, endDate)
         ↓
Repository lấy tất cả transactions từ TransactionRepository
         ↓
Repository filter transactions:
  - transaction.date >= startDate
  - transaction.date <= endDate
         ↓
Repository tính toán lại tất cả statistics với data đã filter
         ↓
Trả về DashboardSummary mới
         ↓
BLoC emit DashboardLoadedState
         ↓
UI rebuild:
  - Summary cards cập nhật số liệu
  - Charts cập nhật dữ liệu
  - Header hiển thị filter hiện tại ("Tháng này")
```

**Date Range Presets:**

```
Hôm nay:
  - start: 00:00:00 hôm nay
  - end: 23:59:59 hôm nay

Tuần này:
  - start: 00:00:00 thứ 2 đầu tuần
  - end: 23:59:59 chủ nhật cuối tuần

Tháng này:
  - start: 00:00:00 ngày 1
  - end: 23:59:59 ngày cuối tháng

Năm nay:
  - start: 00:00:00 ngày 1/1
  - end: 23:59:59 ngày 31/12

Tùy chỉnh:
  - User chọn startDate từ DatePicker
  - User chọn endDate từ DatePicker
  - Validate: startDate <= endDate
```

---

### 3. Refresh Dashboard

```
User kéo xuống (pull to refresh) trên Dashboard
         ↓
UI trigger RefreshIndicator
         ↓
UI dispatch LoadDashboardSummaryEvent
         ↓
BLoC không emit LoadingState (để không che UI)
         ↓
BLoC gọi UseCase
         ↓
UseCase → Repository → TransactionRepository
         ↓
Lấy transactions mới nhất
         ↓
Tính toán lại statistics
         ↓
BLoC emit DashboardLoadedState
         ↓
UI refresh:
  - RefreshIndicator dừng
  - Data cập nhật mới nhất
  - Smooth transition, không flicker
```

**Pull-to-Refresh Benefits:**

- User chủ động refresh data
- Đảm bảo data luôn mới nhất
- Sync khi có thay đổi từ features khác

---

### 4. Navigate Đến Transaction List

```
User tap vào "Xem tất cả" trên dashboard
         ↓
Navigate to TransactionListPage
         ↓
TransactionListPage load danh sách transactions
         ↓
User quay lại Dashboard (back button)
         ↓
Dashboard tự động refresh (onResume)
         ↓
Dispatch LoadDashboardSummaryEvent
         ↓
Cập nhật lại statistics nếu có thay đổi
```

**Auto-Refresh Scenarios:**

```
1. User thêm transaction mới
   → Dashboard refresh khi quay lại

2. User sửa transaction
   → Dashboard refresh statistics

3. User xóa transaction
   → Dashboard cập nhật lại tổng quan

4. User thay đổi filter
   → Dashboard load data mới
```

---

## 📦 Data Flow Chi Tiết

### Domain Layer

**DashboardSummary Entity:**

```
Thuộc tính:
- totalIncome: double (tổng thu nhập)
- totalExpense: double (tổng chi tiêu)
- balance: double (số dư = income - expense)
- expenseByCategory: Map<String, double> (chi tiêu theo category)
- incomeByCategory: Map<String, double> (thu nhập theo category)
- monthlyData: List<MonthlyData> (dữ liệu theo tháng)

MonthlyData:
- month: int (1-12)
- year: int
- income: double (thu trong tháng)
- expense: double (chi trong tháng)
```

**Repository Interface:**

```
DashboardRepository:
- getDashboardSummary({startDate, endDate}):
  → Trả Either<Failure, DashboardSummary>
  → startDate, endDate optional (default: all time)
```

**UseCase:**

```
GetDashboardSummaryUseCase:
- Input: DashboardSummaryParams (startDate, endDate)
- Output: Either<Failure, DashboardSummary>
- Business rule: Tính toán statistics từ transactions
```

---

### Data Layer

**DashboardRepositoryImpl:**

**Dependencies:**

```
Inject:
- TransactionRepository (để lấy transactions)

KHÔNG inject:
- TransactionLocalDataSource (vi phạm Clean Architecture)
- CategoryRepository (không cần thiết)
```

**Logic tính toán getDashboardSummary:**

```
Bước 1: Lấy tất cả transactions
  → Gọi transactionRepository.getAllTransactions()
  → Nhận Either<Failure, List<TransactionEntity>>

Bước 2: Handle Either result
  → Nếu Left(failure): Return Left(failure) luôn
  → Nếu Right(transactions): Tiếp tục xử lý

Bước 3: Filter theo date range
  → Nếu có startDate và endDate:
    → Filter: transaction.date >= startDate
    → Filter: transaction.date <= endDate
  → Nếu không có: Lấy tất cả

Bước 4: Khởi tạo variables
  → totalIncome = 0
  → totalExpense = 0
  → expenseByCategory = {}
  → incomeByCategory = {}
  → monthlyDataMap = {}

Bước 5: Loop qua transactions
  For each transaction:
    → Nếu type = income:
      - totalIncome += amount
      - incomeByCategory[categoryId] += amount
      - monthlyData[month-year].income += amount
    → Nếu type = expense:
      - totalExpense += amount
      - expenseByCategory[categoryId] += amount
      - monthlyData[month-year].expense += amount

Bước 6: Tính balance
  → balance = totalIncome - totalExpense

Bước 7: Sort monthlyData
  → Sort theo year, sau đó theo month
  → Ascending order (tháng cũ → tháng mới)

Bước 8: Tạo DashboardSummary entity
  → Gán tất cả properties đã tính toán

Bước 9: Return result
  → Right(dashboardSummary)

Catch exceptions:
  → Left(CacheFailure(message))
```

**Date Filter Logic:**

```
Default behavior (không có startDate/endDate):
  → Lấy tất cả transactions từ ngày đầu tiên

With startDate and endDate:
  → So sánh chính xác:
    - !transaction.date.isBefore(startDate)
    - !transaction.date.isAfter(endDate)
  → Tương đương: startDate <= date <= endDate
```

---

### Presentation Layer

**DashboardBloc:**

**Events:**

```
- LoadDashboardSummaryEvent:
  → startDate: DateTime? (optional)
  → endDate: DateTime? (optional)
  → Trigger load dashboard data

- RefreshDashboardEvent:
  → Giống LoadDashboardSummaryEvent
  → Nhưng không show loading indicator
```

**States:**

```
- DashboardInitialState:
  → State khởi tạo

- DashboardLoadingState:
  → Đang load data
  → Hiển thị loading indicator

- DashboardLoadedState:
  → Load thành công
  → Chứa DashboardSummary
  → UI render data

- DashboardErrorState:
  → Có lỗi xảy ra
  → Chứa error message
  → Hiển thị error UI với retry button
```

**UI Components:**

**1. DashboardPage (Main Screen):**

```
Layout:
┌─────────────────────────────────┐
│  AppBar: "Dashboard"            │
│  [Filter] [Settings]            │
├─────────────────────────────────┤
│  Summary Cards (Row):           │
│  ┌──────┐ ┌──────┐ ┌──────┐   │
│  │ Thu  │ │ Chi  │ │ Số dư│   │
│  └──────┘ └──────┘ └──────┘   │
├─────────────────────────────────┤
│  Top Chi Tiêu:                  │
│  🍴 Ăn uống: 500,000đ [▓▓▓  ]  │
│  🚗 Di chuyển: 300,000đ [▓▓   ] │
│  🛒 Mua sắm: 200,000đ [▓     ]  │
├─────────────────────────────────┤
│  Biểu Đồ 6 Tháng:              │
│  ┌─┬─┬─┬─┬─┬─┐                │
│  │▓│▓│▓│▓│▓│▓│ Thu             │
│  │▓│▓│▓│▓│▓│▓│ Chi             │
│  └─┴─┴─┴─┴─┴─┘                │
│  5  6  7  8  9  10             │
├─────────────────────────────────┤
│  [Xem tất cả giao dịch]        │
└─────────────────────────────────┘
```

**2. Summary Cards Widget:**

```
Features:
- Hiển thị tổng thu với icon và màu xanh
- Hiển thị tổng chi với icon và màu đỏ
- Hiển thị số dư với màu động (xanh nếu >0, đỏ nếu <0)
- Format số tiền: #,###đ
- Responsive width (3 cards trong 1 row)
- Gradient background
- Shadow effect
```

**3. Top Categories Widget:**

```
Features:
- Hiển thị top 5 categories chi tiêu nhiều nhất
- Mỗi item:
  - Icon category với màu
  - Tên category
  - Số tiền
  - Progress bar (tỷ lệ so với tổng)
- Sorted by amount (cao → thấp)
- Tap vào category → filter transactions theo category đó
```

**4. Monthly Bar Chart Widget:**

```
Features:
- Hiển thị 6 tháng gần nhất
- Mỗi tháng: 2 bars (thu + chi)
- Màu: Xanh lá (thu), Đỏ (chi)
- Trục Y: Amount
- Trục X: Tháng (M5, M6, M7...)
- Tooltip khi hover: Chi tiết thu/chi
- Responsive height
- Animation khi load
```

**5. Filter Bottom Sheet:**

```
Options:
- Radio buttons:
  ○ Hôm nay
  ○ Tuần này
  ○ Tháng này
  ○ Năm nay
  ○ Tùy chỉnh

Nếu chọn "Tùy chỉnh":
  → Hiển thị 2 DatePickers
  → Từ ngày: [Chọn ngày]
  → Đến ngày: [Chọn ngày]
  → Button "Áp dụng"
```

---

## 🔗 Dependencies và Tương Tác

### Với Transaction Feature

**Dashboard → Transaction:**

```
Dashboard inject TransactionRepository
Dashboard gọi getAllTransactions()
Dashboard không modify transactions
Dashboard chỉ đọc và tổng hợp dữ liệu
```

**Không được làm:**

```
❌ Dashboard inject TransactionLocalDataSource
❌ Dashboard trực tiếp truy cập Hive
❌ Dashboard modify transactions
❌ Dashboard tạo/xóa transactions
```

**One-way dependency:**

```
Dashboard → TransactionRepository
Transaction không biết về Dashboard
Clean separation of concerns
```

---

### Với Category Feature

**Dashboard không trực tiếp tương tác Category:**

```
Dashboard lấy categoryId từ transactions
Dashboard KHÔNG load thông tin category (tên, icon, màu)
Transactions đã chứa categoryId
Dashboard chỉ cần ID để group
```

**Nếu cần hiển thị tên category:**

```
Option 1: Load categories trong BLoC
  → Inject CategoryManagementRepository
  → Load 1 lần khi init
  → Map categoryId → category info

Option 2: Lưu category info trong transaction
  → Denormalize data
  → Trade-off: Dễ hiển thị nhưng khó sync

Hiện tại: Chưa implement (chỉ hiển thị categoryId)
```

---

## 🎯 Business Logic

### Tính Toán Statistics

**Tổng Thu (Total Income):**

```
Filter transactions với type = income
Sum tất cả amount
Format: #,###đ
```

**Tổng Chi (Total Expense):**

```
Filter transactions với type = expense
Sum tất cả amount
Format: #,###đ
```

**Số Dư (Balance):**

```
balance = totalIncome - totalExpense
Hiển thị:
  - Nếu > 0: Màu xanh, prefix "+"
  - Nếu < 0: Màu đỏ, prefix "-"
  - Nếu = 0: Màu xám
```

**Chi Tiêu Theo Category:**

```
Group transactions (type=expense) theo categoryId
Tính sum amount cho mỗi category
Sort theo amount DESC (nhiều nhất → ít nhất)
Top 5 categories
Tính % so với tổng chi: (categoryAmount / totalExpense) * 100
```

**Thu Nhập Theo Category:**

```
Tương tự chi tiêu, nhưng filter type=income
Group và tính sum
Sort DESC
```

**Dữ Liệu Theo Tháng:**

```
Group transactions theo month-year
Với mỗi tháng:
  - Tính tổng thu (transactions có type=income)
  - Tính tổng chi (transactions có type=expense)
  - Lưu vào MonthlyData(month, year, income, expense)
Sort theo thời gian (cũ → mới)
Lấy 6 tháng gần nhất để hiển thị chart
```

---

## 🎨 UI/UX Flow

### Happy Path - Mở Dashboard

```
1. User mở app → Splash screen
2. App navigate to Dashboard
3. DashboardPage load:
   - Hiển thị skeleton loading
   - Dispatch LoadDashboardSummaryEvent
4. Data load thành công:
   - Skeleton fade out
   - Cards fade in với animation
   - Numbers count up (animated)
   - Charts render với animation
5. User xem tổng quan:
   - Thu: 5,000,000đ (xanh)
   - Chi: 3,500,000đ (đỏ)
   - Số dư: +1,500,000đ (xanh)
6. User scroll xuống:
   - Xem top categories
   - Xem biểu đồ 6 tháng
7. User pull to refresh:
   - RefreshIndicator hiển thị
   - Data reload
   - UI cập nhật mượt mà
```

### Filter Workflow

```
1. User tap Filter button
2. Bottom sheet slide up
3. Options hiển thị với radio buttons
4. User chọn "Tháng này"
5. Sheet close với animation
6. Dashboard reload:
   - Loading overlay (không che toàn bộ UI)
   - Cards cập nhật với fade transition
   - Charts redraw
7. Header hiển thị: "Tháng này (01/11 - 30/11)"
```

### Error Handling

```
Scenario 1: Không có transactions
  → Hiển thị empty state:
    - Icon piggy bank
    - "Chưa có giao dịch nào"
    - Button "Thêm giao dịch đầu tiên"

Scenario 2: Database error
  → Error state:
    - Icon warning
    - "Không thể tải dữ liệu"
    - Button "Thử lại"
    - User tap "Thử lại" → Retry load

Scenario 3: Network error (future API)
  → Hiển thị cached data
  → Banner: "Hiển thị dữ liệu offline"
```

---

## 📊 Performance Optimization

**Caching Strategy:**

```
BLoC giữ DashboardSummary trong state
Không reload khi back từ screen khác
Chỉ reload khi:
  - User pull to refresh
  - Có transaction mới được thêm
  - User thay đổi filter
```

**Computation Optimization:**

```
Tính toán chạy trong Repository (data layer)
Không block UI thread
Dart single-threaded nhưng đủ nhanh cho <10k transactions
Future improvement: Compute isolate nếu cần
```

**Chart Rendering:**

```
Sử dụng fl_chart package
Render optimization:
  - Chỉ vẽ 6 tháng gần nhất
  - Giới hạn số điểm dữ liệu
  - Throttle animation
```

---

## ✅ Implementation Checklist

- [x] DashboardSummary entity
- [x] MonthlyData entity
- [x] DashboardRepository interface
- [x] DashboardRepositoryImpl inject TransactionRepository
- [x] GetDashboardSummaryUseCase
- [x] DashboardBloc với Events và States
- [x] DashboardPage UI
- [x] Summary Cards widget
- [x] Top Categories widget (cơ bản)
- [x] Monthly Bar Chart widget
- [x] Filter bottom sheet
- [x] Pull to refresh
- [x] Error handling
- [x] Empty state
- [x] Loading state
- [x] Date filter logic

---

## 🔮 Future Enhancements

**Version 2.0:**

- Compare với tháng trước (% tăng/giảm)
- Insights AI: "Chi tiêu ăn uống tăng 20% so với tháng trước"
- Pie chart cho distribution categories
- Export report PDF

**Version 3.0:**

- Budget vs Actual comparison
- Forecast spending (ML prediction)
- Custom dashboard widgets
- Multiple dashboards (Personal, Business, Family)

---

## 🎓 Design Principles Applied

**1. Single Responsibility:**

- Dashboard chỉ hiển thị tổng quan
- Không quản lý transactions
- Không quản lý categories

**2. Dependency Inversion:**

- Dashboard depend vào TransactionRepository interface
- Không depend vào implementation cụ thể
- Dễ dàng swap implementation

**3. Open/Closed:**

- Dễ mở rộng thêm widgets mới
- Không cần sửa logic core
- Plugin architecture cho future widgets

**4. Clean Architecture:**

- Domain layer thuần túy (no framework)
- Data layer chỉ aggregate, không own data
- Presentation layer chỉ UI logic

**5. Separation of Concerns:**

- BLoC: State management
- Repository: Data aggregation
- UseCase: Business rules
- UI: Presentation only

Đây là mô hình lý tưởng của Dashboard feature tuân thủ Clean Architecture! 🚀
