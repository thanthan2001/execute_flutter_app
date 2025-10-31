# 📊 Dashboard Feature - Hướng Dẫn Kỹ Thuật Chi Tiết

## 📑 Mục Lục

1. [Tổng Quan](#1-tổng-quan)
2. [Kiến Trúc Clean Architecture](#2-kiến-trúc-clean-architecture)
3. [Cấu Trúc Thư Mục](#3-cấu-trúc-thư-mục)
4. [Luồng Xử Lý Chi Tiết](#4-luồng-xử-lý-chi-tiết)
5. [Presentation Layer](#5-presentation-layer)
6. [Domain Layer](#6-domain-layer)
7. [Data Layer](#7-data-layer)
8. [Ví Dụ Thực Tế](#8-ví-dụ-thực-tế)
9. [Sơ Đồ Quan Hệ](#9-sơ-đồ-quan-hệ)

---

## 1. Tổng Quan

### 🎯 Mục Tiêu

Dashboard là màn hình chính của ứng dụng **MONI - Save & Grow**, cung cấp cái nhìn tổng quan về tình hình tài chính cá nhân.

### ✨ Chức Năng Chính

1. **Hiển thị Tổng Thu/Chi**

   - Tổng thu nhập trong kỳ
   - Tổng chi tiêu trong kỳ
   - Số dư (thu - chi)

2. **Biểu Đồ Tròn Chi Tiêu Theo Nhóm**

   - Phân tích chi tiêu theo từng category
   - Hiển thị phần trăm và màu sắc riêng cho mỗi nhóm
   - Icon đại diện cho từng nhóm

3. **Biểu Đồ Tròn Thu Nhập Theo Nhóm**

   - Phân tích thu nhập theo từng category
   - Tương tự biểu đồ chi tiêu

4. **Chuyển Đổi Biểu Đồ**

   - **Vuốt ngang (swipe)** để chuyển giữa biểu đồ chi tiêu và thu nhập
   - Page indicator để biết đang xem biểu đồ nào
   - Legend động cập nhật theo biểu đồ hiện tại

5. **Biểu Đồ Cột Theo Tháng**

   - So sánh thu nhập và chi tiêu qua các tháng
   - Giúp người dùng nhìn thấy xu hướng tài chính

6. **Bộ Lọc Thời Gian**
   - Hôm nay
   - Tuần này
   - Tháng này
   - Năm này
   - Tùy chỉnh (chọn khoảng ngày)

### 🛠 Công Nghệ Sử Dụng

- **State Management**: flutter_bloc (BLoC pattern)
- **Local Database**: Hive
- **Charts**: fl_chart
- **Icons**: font_awesome_flutter
- **Number Formatting**: intl
- **Dependency Injection**: GetIt

---

## 2. Kiến Trúc Clean Architecture

Dashboard feature được xây dựng theo **Clean Architecture** gồm 3 layer độc lập:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  (UI, Widgets, Bloc, Events, States)                        │
│  - DashboardPage (UI)                                        │
│  - DashboardBloc (State Management)                          │
│  - SwipeableChartSection (Widget)                            │
└────────────────────┬────────────────────────────────────────┘
                     │ depends on
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  (Business Logic, Entities, UseCases, Repository Interface)  │
│  - DashboardSummary (Entity)                                 │
│  - GetDashboardSummaryUseCase                                │
│  - DashboardRepository (Interface)                           │
└────────────────────┬────────────────────────────────────────┘
                     │ implemented by
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  (Repository Implementation, DataSource, Models)             │
│  - DashboardRepositoryImpl                                   │
│  - DashboardLocalDataSource                                  │
│  - TransactionModel, CategoryModel                           │
└─────────────────────────────────────────────────────────────┘
```

### 🎯 Nguyên Tắc

- **Dependency Rule**: Layer bên trong không biết gì về layer bên ngoài
- **Domain Layer** là trung tâm, chứa business logic thuần túy
- **Presentation Layer** chỉ biết về Domain, không biết về Data
- **Data Layer** implement các interface từ Domain

---

## 3. Cấu Trúc Thư Mục

```
lib/features/dashboard/
├── data/
│   ├── datasources/
│   │   ├── dashboard_local_data_source.dart      # Interface DataSource
│   │   ├── dashboard_local_data_source_impl.dart # Implement với Hive
│   │   └── dashboard_mock_data.dart              # Dữ liệu mẫu khởi tạo
│   ├── models/
│   │   ├── category_model.dart                   # Model + Hive adapter
│   │   ├── category_model.g.dart                 # Generated code
│   │   ├── transaction_model.dart                # Model + Hive adapter
│   │   └── transaction_model.g.dart              # Generated code
│   └── repositories/
│       └── dashboard_repository_impl.dart        # Implement repository
│
├── domain/
│   ├── entities/
│   │   ├── category_entity.dart                  # Entity cho Category
│   │   ├── transaction_entity.dart               # Entity cho Transaction
│   │   └── dashboard_summary.dart                # Entity tổng hợp
│   ├── repositories/
│   │   └── dashboard_repository.dart             # Repository interface
│   └── usecases/
│       └── get_dashboard_summary_usecase.dart    # UseCase lấy dashboard data
│
└── presentation/
    ├── bloc/
    │   ├── dashboard_bloc.dart                   # Bloc chính
    │   ├── dashboard_event.dart                  # Các events
    │   └── dashboard_state.dart                  # Các states
    ├── pages/
    │   └── dashboard_page.dart                   # Main screen
    └── widgets/
        ├── summary_card.dart                     # Widget tổng thu/chi
        ├── date_filter_chips.dart                # Bộ lọc thời gian
        ├── swipeable_chart_section.dart          # Charts vuốt ngang
        ├── category_pie_chart.dart               # Biểu đồ tròn reusable
        ├── monthly_bar_chart.dart                # Biểu đồ cột theo tháng
        └── expense_pie_chart.dart                # (Legacy) biểu đồ chi tiêu
```

---

## 4. Luồng Xử Lý Chi Tiết

### 📊 Data Flow Diagram

```
┌──────────────────┐
│   USER ACTION    │
│ (Mở Dashboard)   │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────────────────┐
│      PRESENTATION LAYER                   │
│  ┌────────────────────────────────────┐  │
│  │  DashboardPage (UI)                │  │
│  │  - initState() được gọi            │  │
│  │  - Dispatch LoadDashboard event    │  │
│  └────────┬───────────────────────────┘  │
│           │                               │
│           ▼                               │
│  ┌────────────────────────────────────┐  │
│  │  DashboardBloc                     │  │
│  │  - Nhận LoadDashboard event        │  │
│  │  - Emit DashboardLoading state     │  │
│  │  - Gọi UseCase                     │  │
│  └────────┬───────────────────────────┘  │
└───────────┼───────────────────────────────┘
            │
            ▼
┌──────────────────────────────────────────┐
│      DOMAIN LAYER                         │
│  ┌────────────────────────────────────┐  │
│  │  GetDashboardSummaryUseCase        │  │
│  │  - Nhận parameters (date range)    │  │
│  │  - Gọi Repository.getDashboard()   │  │
│  └────────┬───────────────────────────┘  │
└───────────┼───────────────────────────────┘
            │
            ▼
┌──────────────────────────────────────────┐
│      DATA LAYER                           │
│  ┌────────────────────────────────────┐  │
│  │  DashboardRepositoryImpl           │  │
│  │  - Nhận date range                 │  │
│  │  - Gọi LocalDataSource             │  │
│  └────────┬───────────────────────────┘  │
│           │                               │
│           ▼                               │
│  ┌────────────────────────────────────┐  │
│  │  DashboardLocalDataSource          │  │
│  │  - Query Hive database             │  │
│  │  - Lọc transactions theo date      │  │
│  │  - Load categories                 │  │
│  │  - Trả về List<Model>              │  │
│  └────────┬───────────────────────────┘  │
└───────────┼───────────────────────────────┘
            │
            ▼
┌──────────────────────────────────────────┐
│  REPOSITORY tính toán business logic:    │
│  - Tổng thu (sum transactions income)    │
│  - Tổng chi (sum transactions expense)   │
│  - Số dư (thu - chi)                     │
│  - Chi tiêu theo nhóm (group by catId)   │
│  - Thu nhập theo nhóm (group by catId)   │
│  - Dữ liệu theo tháng (monthly summary)  │
└────────┬─────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────┐
│  Trả về DashboardSummary Entity          │
└────────┬─────────────────────────────────┘
         │
         │ Either<Failure, DashboardSummary>
         │
         ▼
┌──────────────────────────────────────────┐
│      DOMAIN LAYER                         │
│  GetDashboardSummaryUseCase trả kết quả  │
└────────┬─────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────┐
│      PRESENTATION LAYER                   │
│  ┌────────────────────────────────────┐  │
│  │  DashboardBloc                     │  │
│  │  - Nhận Either result              │  │
│  │  - result.fold():                  │  │
│  │    • Left: Emit DashboardError     │  │
│  │    • Right: Emit DashboardLoaded   │  │
│  └────────┬───────────────────────────┘  │
└───────────┼───────────────────────────────┘
            │
            ▼
┌──────────────────────────────────────────┐
│  DashboardPage (UI)                       │
│  - BlocBuilder rebuild                    │
│  - Hiển thị data hoặc error               │
│  - Render charts với data mới             │
└───────────────────────────────────────────┘
```

---

## 5. Presentation Layer

### 📱 DashboardPage (UI)

**File**: `dashboard_page.dart`

**Trách nhiệm**:

- Hiển thị UI cho dashboard
- Lắng nghe state changes từ DashboardBloc
- Dispatch events khi user tương tác

**Các widget chính**:

```dart
class DashboardPage extends StatefulWidget {
  // Main dashboard screen

  @override
  void initState() {
    super.initState();
    // 1. Load categories từ database
    _loadCategories();
    // 2. Dispatch event load dashboard
    context.read<DashboardBloc>().add(const LoadDashboard());
  }
}
```

**UI Components**:

1. **AppBar**

   - Title: "MONI"
   - Actions: PopupMenu (Statistics, Categories, Transactions, Settings)

2. **Date Filter Chips**

   - Hôm nay / Tuần này / Tháng này / Năm này
   - Khi chọn: dispatch `ChangeDateFilter` event

3. **Summary Cards**

   - Tổng thu (màu xanh)
   - Tổng chi (màu đỏ)
   - Số dư (màu xanh/cam tùy dương/âm)

4. **Swipeable Chart Section**

   - PageView với 2 trang
   - Trang 1: Biểu đồ chi tiêu
   - Trang 2: Biểu đồ thu nhập
   - Page indicator (dots)
   - Legend động

5. **Monthly Bar Chart**
   - Biểu đồ cột so sánh thu/chi theo tháng

### 🎛 DashboardBloc

**File**: `dashboard_bloc.dart`

**Trách nhiệm**:

- Quản lý state của dashboard
- Xử lý các events từ UI
- Gọi UseCase để lấy dữ liệu
- Emit states mới

**Constructor**:

```dart
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummaryUseCase getDashboardSummaryUseCase;

  DashboardBloc({
    required this.getDashboardSummaryUseCase,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<ChangeDateFilter>(_onChangeDateFilter);
  }
}
```

### 📤 Events

**File**: `dashboard_event.dart`

```dart
// 1. LoadDashboard - Load dashboard với filter
class LoadDashboard extends DashboardEvent {
  final DateFilter filter;           // Loại filter: today, thisWeek, thisMonth...
  final DateTime? customStartDate;   // Ngày bắt đầu tùy chỉnh
  final DateTime? customEndDate;     // Ngày kết thúc tùy chỉnh
}

// 2. RefreshDashboard - Refresh dashboard (giữ nguyên filter hiện tại)
class RefreshDashboard extends DashboardEvent {
  // Không có parameters
  // Sẽ load lại với filter hiện tại
}

// 3. ChangeDateFilter - Thay đổi bộ lọc thời gian
class ChangeDateFilter extends DashboardEvent {
  final DateFilter filter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
}
```

**Các DateFilter**:

- `DateFilter.today` - Hôm nay
- `DateFilter.thisWeek` - Tuần này
- `DateFilter.thisMonth` - Tháng này (mặc định)
- `DateFilter.thisYear` - Năm này
- `DateFilter.custom` - Tùy chỉnh (cần startDate & endDate)

### 📥 States

**File**: `dashboard_state.dart`

```dart
// 1. DashboardInitial - State ban đầu
class DashboardInitial extends DashboardState {}

// 2. DashboardLoading - Đang load dữ liệu
class DashboardLoading extends DashboardState {}

// 3. DashboardLoaded - Load thành công
class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;     // Data dashboard
  final DateFilter currentFilter;     // Filter hiện tại
}

// 4. DashboardError - Load thất bại
class DashboardError extends DashboardState {
  final String message;               // Thông báo lỗi
}
```

### 🎨 Custom Widgets

#### 1. **SwipeableChartSection**

**File**: `swipeable_chart_section.dart`

```dart
class SwipeableChartSection extends StatefulWidget {
  final Map<String, double> expenseByCategory;   // Chi tiêu theo nhóm
  final Map<String, double> incomeByCategory;    // Thu nhập theo nhóm
  final List<CategoryEntity> categories;         // Danh sách categories

  // Widget này bao gồm:
  // - PageController để quản lý swipe
  // - PageView với 2 CategoryPieChart
  // - Page indicator (dots)
  // - Legend động theo trang hiện tại
}
```

#### 2. **CategoryPieChart**

**File**: `category_pie_chart.dart`

```dart
class CategoryPieChart extends StatelessWidget {
  final Map<String, double> dataByCategory;      // Data theo category
  final Map<String, String> categoryNames;       // categoryId -> name
  final Map<String, Color> categoryColors;       // categoryId -> color
  final String emptyMessage;                     // Message khi không có data

  // Sử dụng fl_chart để vẽ PieChart
  // Mỗi section hiển thị % và màu riêng
}
```

#### 3. **SummaryCard**

**File**: `summary_card.dart`

```dart
class SummaryCard extends StatelessWidget {
  final String title;        // "Tổng thu" / "Tổng chi" / "Số dư"
  final double amount;       // Số tiền
  final IconData icon;       // Icon hiển thị
  final Color color;         // Màu chủ đạo

  // Card hiển thị summary với animation
}
```

---

## 6. Domain Layer

### 📦 Entities

#### 1. **DashboardSummary**

**File**: `dashboard_summary.dart`

```dart
class DashboardSummary extends Equatable {
  final double totalIncome;                      // Tổng thu
  final double totalExpense;                     // Tổng chi
  final double balance;                          // Số dư (thu - chi)
  final Map<String, double> expenseByCategory;   // Chi tiêu theo nhóm
  final Map<String, double> incomeByCategory;    // Thu nhập theo nhóm
  final List<MonthlyData> monthlyData;           // Dữ liệu theo tháng
}
```

#### 2. **TransactionEntity**

**File**: `transaction_entity.dart`

```dart
class TransactionEntity extends Equatable {
  final String id;              // Unique ID
  final String categoryId;      // ID của category
  final String description;     // Mô tả giao dịch
  final double amount;          // Số tiền
  final DateTime date;          // Ngày giao dịch
  final TransactionType type;   // income / expense
}
```

#### 3. **CategoryEntity**

**File**: `category_entity.dart`

```dart
class CategoryEntity extends Equatable {
  final String id;                          // Unique ID
  final String name;                        // Tên nhóm
  final IconData icon;                      // Icon
  final Color color;                        // Màu sắc
  final TransactionCategoryType type;       // income / expense / both
}
```

### ⚙️ UseCases

#### **GetDashboardSummaryUseCase**

**File**: `get_dashboard_summary_usecase.dart`

```dart
class GetDashboardSummaryUseCase
    implements UseCase<DashboardSummary, GetDashboardParams> {
  final DashboardRepository repository;

  GetDashboardSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, DashboardSummary>> call(
    GetDashboardParams params
  ) async {
    return await repository.getDashboardSummary(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

// Parameters
class GetDashboardParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
}
```

**Trách nhiệm**:

- Nhận parameters (date range)
- Gọi repository method
- Trả về `Either<Failure, DashboardSummary>`

**Tại sao cần UseCase?**

- Tách biệt business logic khỏi UI
- Có thể reuse ở nhiều nơi
- Dễ test
- Có thể thêm validation, logging

### 🔌 Repository Interface

**File**: `dashboard_repository.dart`

```dart
abstract class DashboardRepository {
  /// Lấy tổng hợp dashboard trong khoảng thời gian
  Future<Either<Failure, DashboardSummary>> getDashboardSummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Xóa toàn bộ transactions (cho Settings feature)
  Future<Either<Failure, void>> clearAllTransactions();
}
```

**Đây là interface** (contract):

- Domain layer định nghĩa những gì cần
- Data layer sẽ implement chi tiết

---

## 7. Data Layer

### 🏗 Repository Implementation

**File**: `dashboard_repository_impl.dart`

```dart
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;

  DashboardRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // 1. Lấy transactions từ DataSource
      final transactions = await localDataSource.getTransactionsByDateRange(
        startDate ?? DateTime(2000),
        endDate ?? DateTime.now(),
      );

      // 2. Tính toán các metrics
      double totalIncome = 0;
      double totalExpense = 0;
      Map<String, double> expenseByCategory = {};
      Map<String, double> incomeByCategory = {};

      for (var transaction in transactions) {
        final entity = transaction.toEntity();

        if (entity.type == TransactionType.income) {
          totalIncome += entity.amount;
          incomeByCategory[entity.categoryId] =
              (incomeByCategory[entity.categoryId] ?? 0) + entity.amount;
        } else {
          totalExpense += entity.amount;
          expenseByCategory[entity.categoryId] =
              (expenseByCategory[entity.categoryId] ?? 0) + entity.amount;
        }
      }

      // 3. Tính dữ liệu theo tháng
      final monthlyData = _calculateMonthlyData(transactions);

      // 4. Tạo DashboardSummary entity
      final summary = DashboardSummary(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
        expenseByCategory: expenseByCategory,
        incomeByCategory: incomeByCategory,
        monthlyData: monthlyData,
      );

      return Right(summary);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
```

**Trách nhiệm**:

- Lấy raw data từ DataSource
- **Tính toán business logic** (tổng thu, chi, group by category...)
- Convert Model → Entity
- Xử lý exceptions → return Either

### 💾 DataSource

#### **DashboardLocalDataSource Interface**

**File**: `dashboard_local_data_source.dart`

```dart
abstract class DashboardLocalDataSource {
  Future<void> init();

  // Transactions
  Future<List<TransactionModel>> getAllTransactions();
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime start,
    DateTime end
  );
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<void> clearAllTransactions();

  // Categories
  Future<List<CategoryModel>> getAllCategories();
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<void> clearAllCategories();
}
```

#### **DashboardLocalDataSourceImpl**

**File**: `dashboard_local_data_source_impl.dart`

```dart
class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  Box<TransactionModel>? _transactionBox;
  Box<CategoryModel>? _categoryBox;

  @override
  Future<void> init() async {
    _transactionBox = await Hive.openBox<TransactionModel>('transactions');
    _categoryBox = await Hive.openBox<CategoryModel>('categories');
  }

  @override
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final all = _transactionBox!.values.toList();
    return all.where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
             t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // ... các methods khác
}
```

**Trách nhiệm**:

- Tương tác trực tiếp với Hive database
- CRUD operations
- Không có business logic
- Trả về Models (không phải Entities)

### 📋 Models

#### **TransactionModel**

**File**: `transaction_model.dart`

```dart
@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String type; // 'income' or 'expense'

  // Convert Entity → Model
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      categoryId: entity.categoryId,
      description: entity.description,
      amount: entity.amount,
      date: entity.date,
      type: entity.type == TransactionType.income ? 'income' : 'expense',
    );
  }

  // Convert Model → Entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      categoryId: categoryId,
      description: description,
      amount: amount,
      date: date,
      type: type == 'income'
          ? TransactionType.income
          : TransactionType.expense,
    );
  }
}
```

**Models vs Entities**:

- **Model**: Dùng cho Data layer, có Hive annotations
- **Entity**: Dùng cho Domain/Presentation, clean business object
- Cần convert qua lại giữa Model ↔ Entity

---

## 8. Ví Dụ Thực Tế

### 📱 Scenario: User mở Dashboard và chọn filter "Tháng này"

#### **Bước 1: User mở app**

```dart
// main.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

// app.dart → app_binding.dart
await AppBinding.init(); // Khởi tạo DI

// app_router.dart điều hướng đến /splash
// SplashScreen sau 2 giây → context.go('/dashboard')
```

#### **Bước 2: DashboardPage initState()**

```dart
// dashboard_page.dart
@override
void initState() {
  super.initState();

  // Load categories từ database
  _loadCategories();

  // Dispatch event load dashboard với filter mặc định
  context.read<DashboardBloc>().add(const LoadDashboard());
  // ↑ Mặc định filter = DateFilter.thisMonth
}
```

#### **Bước 3: DashboardBloc nhận event**

```dart
// dashboard_bloc.dart
Future<void> _onLoadDashboard(
  LoadDashboard event,
  Emitter<DashboardState> emit,
) async {
  // Step 1: Emit loading state
  emit(DashboardLoading());

  // Step 2: Tính date range từ filter
  final dateRange = _getDateRange(event.filter);
  // Với thisMonth → startDate = đầu tháng, endDate = hiện tại

  // Step 3: Gọi UseCase
  final result = await getDashboardSummaryUseCase(
    GetDashboardParams(
      startDate: dateRange['start'],
      endDate: dateRange['end'],
    ),
  );

  // Step 4: Xử lý kết quả
  result.fold(
    (failure) => emit(DashboardError(message: 'Lỗi tải dữ liệu')),
    (summary) => emit(DashboardLoaded(
      summary: summary,
      currentFilter: event.filter,
    )),
  );
}
```

#### **Bước 4: UseCase xử lý**

```dart
// get_dashboard_summary_usecase.dart
@override
Future<Either<Failure, DashboardSummary>> call(
  GetDashboardParams params
) async {
  // Gọi repository
  return await repository.getDashboardSummary(
    startDate: params.startDate,
    endDate: params.endDate,
  );
}
```

#### **Bước 5: Repository thực hiện business logic**

```dart
// dashboard_repository_impl.dart
@override
Future<Either<Failure, DashboardSummary>> getDashboardSummary({
  DateTime? startDate,
  DateTime? endDate,
}) async {
  try {
    // 1. Lấy transactions từ DataSource
    final transactions = await localDataSource.getTransactionsByDateRange(
      startDate ?? DateTime(2000),
      endDate ?? DateTime.now(),
    );

    // 2. Tính toán metrics
    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, double> expenseByCategory = {};
    Map<String, double> incomeByCategory = {};

    for (var transaction in transactions) {
      final entity = transaction.toEntity();

      if (entity.type == TransactionType.income) {
        totalIncome += entity.amount;
        incomeByCategory[entity.categoryId] =
            (incomeByCategory[entity.categoryId] ?? 0) + entity.amount;
      } else {
        totalExpense += entity.amount;
        expenseByCategory[entity.categoryId] =
            (expenseByCategory[entity.categoryId] ?? 0) + entity.amount;
      }
    }

    // 3. Tính monthly data
    final monthlyData = _calculateMonthlyData(transactions);

    // 4. Return entity
    return Right(DashboardSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      expenseByCategory: expenseByCategory,
      incomeByCategory: incomeByCategory,
      monthlyData: monthlyData,
    ));
  } catch (e) {
    return Left(CacheFailure(message: e.toString()));
  }
}
```

#### **Bước 6: DataSource query database**

```dart
// dashboard_local_data_source_impl.dart
@override
Future<List<TransactionModel>> getTransactionsByDateRange(
  DateTime start,
  DateTime end,
) async {
  final all = _transactionBox!.values.toList();

  return all.where((t) {
    return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
           t.date.isBefore(end.add(const Duration(days: 1)));
  }).toList();
}
```

#### **Bước 7: UI rebuild với data mới**

```dart
// dashboard_page.dart
Widget build(BuildContext context) {
  return Scaffold(
    body: BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state is DashboardError) {
          return Center(child: Text(state.message));
        }

        if (state is DashboardLoaded) {
          final summary = state.summary;

          return ListView(
            children: [
              // Date filter chips
              DateFilterChips(selectedFilter: state.currentFilter),

              // Summary cards
              SummaryCard(
                title: 'Tổng thu',
                amount: summary.totalIncome,
                color: Colors.green,
              ),
              SummaryCard(
                title: 'Tổng chi',
                amount: summary.totalExpense,
                color: Colors.red,
              ),

              // Swipeable charts
              SwipeableChartSection(
                expenseByCategory: summary.expenseByCategory,
                incomeByCategory: summary.incomeByCategory,
                categories: _categories,
              ),

              // Monthly bar chart
              MonthlyBarChart(monthlyData: summary.monthlyData),
            ],
          );
        }

        return Center(child: Text('Kéo xuống để tải dữ liệu'));
      },
    ),
  );
}
```

#### **Bước 8: User chọn filter khác**

```dart
// User tap vào chip "Tuần này"
onPressed: () {
  context.read<DashboardBloc>().add(
    ChangeDateFilter(filter: DateFilter.thisWeek)
  );
}

// Bloc nhận event, gọi lại LoadDashboard với filter mới
// → Quá trình lặp lại từ Bước 3
```

---

## 9. Sơ Đồ Quan Hệ

### 🏗 Class Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         PRESENTATION                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐           ┌──────────────────┐            │
│  │  DashboardPage   │──uses───▶ │ DashboardBloc    │            │
│  │  (StatefulWidget)│           │ (Bloc)           │            │
│  └──────────────────┘           └────────┬─────────┘            │
│           │                               │                      │
│           │ renders                       │ uses                 │
│           ▼                               ▼                      │
│  ┌──────────────────┐           ┌──────────────────┐            │
│  │ SwipeableChart   │           │ DashboardEvent   │            │
│  │ Section          │           │ DashboardState   │            │
│  └──────────────────┘           └──────────────────┘            │
│                                                                  │
└────────────────────────┬─────────────────────────────────────────┘
                         │ depends on
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                           DOMAIN                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────┐       │
│  │         GetDashboardSummaryUseCase                   │       │
│  │  ┌────────────────────────────────────────────────┐  │       │
│  │  │ call(GetDashboardParams params)                │  │       │
│  │  │   → repository.getDashboardSummary()           │  │       │
│  │  │   → return Either<Failure, DashboardSummary>   │  │       │
│  │  └────────────────────────────────────────────────┘  │       │
│  └───────────────────────┬──────────────────────────────┘       │
│                          │ uses                                  │
│                          ▼                                       │
│  ┌──────────────────────────────────────────────────────┐       │
│  │      DashboardRepository (Interface)                 │       │
│  │  ┌────────────────────────────────────────────────┐  │       │
│  │  │ getDashboardSummary({startDate, endDate})      │  │       │
│  │  │   → Either<Failure, DashboardSummary>          │  │       │
│  │  └────────────────────────────────────────────────┘  │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐  │
│  │ DashboardSummary │  │ TransactionEntity│  │CategoryEntity│  │
│  │ (Entity)         │  │ (Entity)         │  │(Entity)      │  │
│  └──────────────────┘  └──────────────────┘  └──────────────┘  │
│                                                                  │
└────────────────────────┬─────────────────────────────────────────┘
                         │ implemented by
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                            DATA                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────┐       │
│  │    DashboardRepositoryImpl (implements Interface)    │       │
│  │  ┌────────────────────────────────────────────────┐  │       │
│  │  │ getDashboardSummary()                          │  │       │
│  │  │   1. Get transactions from DataSource          │  │       │
│  │  │   2. Calculate totalIncome, totalExpense       │  │       │
│  │  │   3. Group by category                         │  │       │
│  │  │   4. Calculate monthly data                    │  │       │
│  │  │   5. Return DashboardSummary entity            │  │       │
│  │  └────────────────────────────────────────────────┘  │       │
│  └───────────────────────┬──────────────────────────────┘       │
│                          │ uses                                  │
│                          ▼                                       │
│  ┌──────────────────────────────────────────────────────┐       │
│  │    DashboardLocalDataSource (Interface)              │       │
│  │  ┌────────────────────────────────────────────────┐  │       │
│  │  │ getTransactionsByDateRange(start, end)         │  │       │
│  │  │ getAllCategories()                             │  │       │
│  │  │ addTransaction(model)                          │  │       │
│  │  │ ...                                            │  │       │
│  │  └────────────────────────────────────────────────┘  │       │
│  └───────────────────────┬──────────────────────────────┘       │
│                          │ implemented by                        │
│                          ▼                                       │
│  ┌──────────────────────────────────────────────────────┐       │
│  │   DashboardLocalDataSourceImpl (Hive)               │       │
│  │  ┌────────────────────────────────────────────────┐  │       │
│  │  │ Box<TransactionModel> _transactionBox          │  │       │
│  │  │ Box<CategoryModel> _categoryBox                │  │       │
│  │  │                                                │  │       │
│  │  │ getTransactionsByDateRange() {                │  │       │
│  │  │   return _transactionBox.values               │  │       │
│  │  │     .where((t) => date in range)              │  │       │
│  │  │ }                                             │  │       │
│  │  └────────────────────────────────────────────────┘  │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐                     │
│  │ TransactionModel │  │  CategoryModel   │                     │
│  │ (@HiveType)      │  │  (@HiveType)     │                     │
│  │  - toEntity()    │  │  - toEntity()    │                     │
│  │  - fromEntity()  │  │  - fromEntity()  │                     │
│  └──────────────────┘  └──────────────────┘                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 🔄 Sequence Diagram

```
User          DashboardPage     DashboardBloc     UseCase        Repository      DataSource      Hive
 │                 │                 │               │              │               │             │
 │─Open App──────▶│                 │               │              │               │             │
 │                 │──LoadDashboard─▶│               │              │               │             │
 │                 │                 │──call()──────▶│              │               │             │
 │                 │                 │               │──getDashboard()──────────────▶│             │
 │                 │                 │               │              │──getTransactions()──────────▶│
 │                 │                 │               │              │               │──query()───▶│
 │                 │                 │               │              │               │◀─results───│
 │                 │                 │               │              │◀─models───────│             │
 │                 │                 │               │              │               │             │
 │                 │                 │               │              │ Calculate:    │             │
 │                 │                 │               │              │ - totalIncome │             │
 │                 │                 │               │              │ - totalExpense│             │
 │                 │                 │               │              │ - byCategory  │             │
 │                 │                 │               │              │               │             │
 │                 │                 │               │◀─Either<Summary>─────────────│             │
 │                 │                 │◀─Either<Summary>────────────│              │             │
 │                 │◀─DashboardLoaded│               │              │               │             │
 │◀─UI Update─────│                 │               │              │               │             │
 │                 │                 │               │              │               │             │
```

---

## 📚 Tổng Kết

### ✅ Ưu Điểm Clean Architecture

1. **Separation of Concerns**

   - Mỗi layer có trách nhiệm riêng biệt
   - UI không biết về database implementation
   - Business logic độc lập với framework

2. **Testability**

   - UseCase dễ test (mock repository)
   - Repository dễ test (mock data source)
   - UI test không cần database thật

3. **Maintainability**

   - Thay đổi UI không ảnh hưởng business logic
   - Thay đổi database (Hive → SQLite) chỉ sửa Data layer
   - Dễ tìm bug (biết bug ở layer nào)

4. **Scalability**

   - Dễ thêm feature mới
   - Dễ thêm data source mới (API, Firebase...)
   - Code reusable

5. **Collaboration**
   - Team có thể làm việc song song trên các layer
   - Contract rõ ràng (Repository interface)

### 🔧 Cách Mở Rộng

#### 1. **Thêm Filter Mới**

```dart
// 1. Thêm enum trong dashboard_state.dart
enum DateFilter {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  lastMonth,    // ← NEW
  last3Months,  // ← NEW
  custom,
}

// 2. Thêm case trong _getDateRange() của DashboardBloc
case DateFilter.lastMonth:
  return {
    'start': DateTime(now.year, now.month - 1, 1),
    'end': DateTime(now.year, now.month, 0),
  };
```

#### 2. **Thêm Remote API**

```dart
// 1. Tạo RemoteDataSource
abstract class DashboardRemoteDataSource {
  Future<List<TransactionModel>> getTransactionsFromAPI();
}

// 2. Update Repository
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;
  final DashboardRemoteDataSource remoteDataSource;  // ← NEW
  final NetworkInfo networkInfo;                      // ← NEW

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary() async {
    if (await networkInfo.isConnected) {
      // Sync với API
      final remoteData = await remoteDataSource.getTransactionsFromAPI();
      await localDataSource.syncTransactions(remoteData);
    }

    // Load từ local
    final transactions = await localDataSource.getAllTransactions();
    // ...
  }
}
```

#### 3. **Thêm Chart Mới**

```dart
// 1. Tạo widget mới trong presentation/widgets/
class TrendLineChart extends StatelessWidget {
  final List<MonthlyData> data;
  // ...
}

// 2. Thêm vào dashboard_page.dart
MonthlyBarChart(monthlyData: summary.monthlyData),
TrendLineChart(data: summary.monthlyData),  // ← NEW
```

### 🐛 Debug Tips

1. **Print logs ở từng layer**

```dart
// UseCase
print('📞 UseCase: Calling repository with params: $params');

// Repository
print('🏗 Repository: Fetched ${transactions.length} transactions');

// DataSource
print('💾 DataSource: Query returned ${results.length} items');

// Bloc
print('🎛 Bloc: Emitting DashboardLoaded state');
```

2. **Kiểm tra Either result**

```dart
result.fold(
  (failure) {
    print('❌ Error: ${failure.message}');
    print('❌ Type: ${failure.runtimeType}');
  },
  (success) {
    print('✅ Success: $success');
  },
);
```

3. **Bloc Observer**

```dart
class MyBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('🎯 Event: ${event.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('🔄 Transition: ${transition.currentState.runtimeType} → ${transition.nextState.runtimeType}');
  }
}
```

### 📖 Tài Liệu Tham Khảo

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter BLoC Documentation](https://bloclibrary.dev/)
- [Hive Documentation](https://docs.hivedb.dev/)
- [fl_chart Documentation](https://pub.dev/packages/fl_chart)
- [Dependency Injection with GetIt](https://pub.dev/packages/get_it)

---

**Tài liệu được tạo cho**: MONI - Save & Grow  
**Version**: 1.0.0  
**Ngày cập nhật**: October 31, 2025  
**Tác giả**: Thân Thân
