# 💰 Transaction Feature - Hướng Dẫn Kỹ Thuật Chi Tiết

## 📑 Mục Lục

1. [Tổng Quan](#1-tổng-quan)
2. [Cấu Trúc Thư Mục](#2-cấu-trúc-thư-mục)
3. [Luồng Xử Lý CRUD](#3-luồng-xử-lý-crud)
4. [Presentation Layer](#4-presentation-layer)
5. [Domain Layer](#5-domain-layer)
6. [Data Layer](#6-data-layer)
7. [Ví Dụ Chi Tiết: Thêm Giao Dịch](#7-ví-dụ-chi-tiết-thêm-giao-dịch)
8. [Sơ Đồ Quan Hệ](#8-sơ-đồ-quan-hệ)

---

## 1. Tổng Quan

### 🎯 Mục Tiêu

Transaction feature cung cấp đầy đủ các chức năng **CRUD** (Create, Read, Update, Delete) để quản lý giao dịch thu chi cá nhân.

### ✨ Chức Năng Chính

#### 1. **Create - Thêm Giao Dịch Mới**

- Form nhập thông tin: số tiền, mô tả, ngày, loại (thu/chi), nhóm
- Validation dữ liệu đầu vào
- Format số tiền theo chuẩn Việt Nam (2.000.000đ)
- Chọn category từ danh sách có sẵn
- Chọn ngày với DatePicker

#### 2. **Read - Xem Danh Sách Giao Dịch**

- Hiển thị tất cả giao dịch theo thứ tự ngày mới nhất
- Sắp xếp theo ngày giảm dần
- Hiển thị đầy đủ thông tin: icon, tên nhóm, số tiền, ngày, mô tả
- Filter theo loại: Tất cả / Thu nhập / Chi tiêu
- Group by ngày để dễ xem

#### 3. **Update - Cập Nhật Giao Dịch**

- Edit form với dữ liệu pre-fill
- Validate và cập nhật
- Refresh danh sách sau khi cập nhật

#### 4. **Delete - Xóa Giao Dịch**

- Confirm dialog trước khi xóa
- Swipe to delete
- Xóa khỏi database
- Refresh danh sách

### 🛠 Công Nghệ Sử Dụng

- **State Management**: flutter_bloc (BLoC pattern)
- **Local Database**: Hive (tái sử dụng DashboardLocalDataSource)
- **Date Picker**: Flutter built-in
- **Validation**: Custom validators
- **Number Formatting**: intl + CurrencyInputFormatter
- **Error Handling**: Either pattern (dartz)

---

## 2. Cấu Trúc Thư Mục

```
lib/features/transaction/
├── data/
│   └── repositories/
│       └── transaction_repository_impl.dart    # Implement repository
│       # Note: Tái sử dụng DashboardLocalDataSource
│       # Không cần tạo DataSource riêng
│
├── domain/
│   ├── repositories/
│   │   └── transaction_repository.dart         # Repository interface
│   └── usecases/
│       ├── get_all_transactions_usecase.dart   # READ: Get all
│       ├── get_all_categories_usecase.dart     # READ: Get categories
│       ├── add_transaction_usecase.dart        # CREATE: Add new
│       ├── update_transaction_usecase.dart     # UPDATE: Edit
│       └── delete_transaction_usecase.dart     # DELETE: Remove
│
└── presentation/
    ├── bloc/
    │   ├── transaction_bloc.dart               # Bloc chính
    │   ├── transaction_event.dart              # Các events
    │   └── transaction_state.dart              # Các states
    ├── pages/
    │   ├── transaction_list_page.dart          # Danh sách giao dịch
    │   └── add_edit_transaction_page.dart      # Form thêm/sửa
    └── widgets/
        ├── transaction_list_item.dart          # Item trong list
        └── transaction_filter_chips.dart       # Filter: All/Income/Expense
```

### 📝 Note về DataSource

Transaction feature **tái sử dụng** `DashboardLocalDataSource` đã có sẵn thay vì tạo mới:

- Tránh duplicate code
- Dữ liệu consistency
- Dễ maintain

---

## 3. Luồng Xử Lý CRUD

### 📊 Tổng Quan Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    USER INTERACTIONS                             │
└────────┬────────────────────────────────────────────────────────┘
         │
         ├─ View List ────────────────────────────────┐
         ├─ Add Transaction ──────────────────────────┤
         ├─ Edit Transaction ─────────────────────────┤
         └─ Delete Transaction ───────────────────────┤
                                                       │
         ┌─────────────────────────────────────────────┘
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                            │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  TransactionListPage / AddEditTransactionPage             │ │
│  │  - User tương tác (tap button, nhập form, swipe...)       │ │
│  │  - Dispatch event tương ứng                               │ │
│  └────────┬───────────────────────────────────────────────────┘ │
│           │                                                      │
│           ▼                                                      │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  TransactionBloc                                           │ │
│  │  - Nhận event từ UI                                        │ │
│  │  - Emit loading state                                      │ │
│  │  - Gọi UseCase tương ứng                                   │ │
│  │  - Emit success/error state                                │ │
│  └────────┬───────────────────────────────────────────────────┘ │
└───────────┼──────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                        DOMAIN LAYER                              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  UseCases (Business Logic)                                 │ │
│  │                                                             │ │
│  │  GetAllTransactionsUseCase                                 │ │
│  │    └─ Lấy danh sách tất cả giao dịch                       │ │
│  │                                                             │ │
│  │  AddTransactionUseCase                                     │ │
│  │    └─ Thêm giao dịch mới                                   │ │
│  │                                                             │ │
│  │  UpdateTransactionUseCase                                  │ │
│  │    └─ Cập nhật giao dịch existing                          │ │
│  │                                                             │ │
│  │  DeleteTransactionUseCase                                  │ │
│  │    └─ Xóa giao dịch theo ID                                │ │
│  │                                                             │ │
│  │  GetAllCategoriesUseCase                                   │ │
│  │    └─ Lấy danh sách categories để chọn                     │ │
│  └────────┬───────────────────────────────────────────────────┘ │
│           │ calls                                                │
│           ▼                                                      │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  TransactionRepository (Interface)                         │ │
│  │  - getAllTransactions()                                    │ │
│  │  - addTransaction(entity)                                  │ │
│  │  - updateTransaction(entity)                               │ │
│  │  - deleteTransaction(id)                                   │ │
│  │  - getAllCategories()                                      │ │
│  └────────┬───────────────────────────────────────────────────┘ │
└───────────┼──────────────────────────────────────────────────────┘
            │ implemented by
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                         DATA LAYER                               │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  TransactionRepositoryImpl                                 │ │
│  │  - Convert Entity ↔ Model                                  │ │
│  │  - Call DashboardLocalDataSource                           │ │
│  │  - Handle exceptions → return Either                       │ │
│  └────────┬───────────────────────────────────────────────────┘ │
│           │ uses                                                 │
│           ▼                                                      │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  DashboardLocalDataSource (Hive)                           │ │
│  │  - getAllTransactions()                                    │ │
│  │  - addTransaction(model)                                   │ │
│  │  - updateTransaction(model)                                │ │
│  │  - deleteTransaction(id)                                   │ │
│  │  - getAllCategories()                                      │ │
│  └────────┬───────────────────────────────────────────────────┘ │
└───────────┼──────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                         HIVE DATABASE                            │
│  Box<TransactionModel>                                           │
│  Box<CategoryModel>                                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Presentation Layer

### 📱 UI Screens

#### 1. **TransactionListPage**

**File**: `transaction_list_page.dart`

**Trách nhiệm**:

- Hiển thị danh sách giao dịch
- Filter theo loại (Tất cả/Thu/Chi)
- Navigate đến form thêm/sửa
- Xử lý swipe to delete

**UI Components**:

```dart
class TransactionListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách giao dịch'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => context.push('/transactions/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          TransactionFilterChips(),

          // List
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoading) {
                return CircularProgressIndicator();
              }

              if (state is TransactionLoaded) {
                return ListView.builder(
                  itemCount: state.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = state.transactions[index];
                    return TransactionListItem(
                      transaction: transaction,
                      onTap: () => _editTransaction(transaction),
                      onDelete: () => _deleteTransaction(transaction.id),
                    );
                  },
                );
              }

              return Text('No data');
            },
          ),
        ],
      ),
    );
  }
}
```

#### 2. **AddEditTransactionPage**

**File**: `add_edit_transaction_page.dart`

**Trách nhiệm**:

- Form nhập/sửa giao dịch
- Validation
- Submit data

**Form Fields**:

- Số tiền (TextField với CurrencyInputFormatter)
- Mô tả (TextField)
- Ngày (DatePicker)
- Loại (Income/Expense Segment)
- Nhóm (Dropdown Categories)

### 🎛 TransactionBloc

**File**: `transaction_bloc.dart`

```dart
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetAllTransactionsUseCase getAllTransactionsUseCase;
  final GetAllCategoriesUseCase getAllCategoriesUseCase;
  final AddTransactionUseCase addTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;

  TransactionBloc({
    required this.getAllTransactionsUseCase,
    required this.getAllCategoriesUseCase,
    required this.addTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
  }) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<ChangeTransactionFilter>(_onChangeTransactionFilter);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<RefreshTransactions>(_onRefreshTransactions);
  }
}
```

**Đặc điểm**:

- Quản lý 5 UseCases
- Handle 6 loại events
- Emit các states tương ứng với từng action

### 📤 Events

**File**: `transaction_event.dart`

```dart
// 1. LoadTransactions - Load danh sách lần đầu
class LoadTransactions extends TransactionEvent {
  // Không có parameters
}

// 2. ChangeTransactionFilter - Thay đổi filter
class ChangeTransactionFilter extends TransactionEvent {
  final TransactionFilter filter;  // all / income / expense
}

// 3. AddTransaction - Thêm giao dịch mới
class AddTransaction extends TransactionEvent {
  final TransactionEntity transaction;
}

// 4. UpdateTransaction - Cập nhật giao dịch
class UpdateTransaction extends TransactionEvent {
  final TransactionEntity transaction;
}

// 5. DeleteTransaction - Xóa giao dịch
class DeleteTransaction extends TransactionEvent {
  final String id;
}

// 6. RefreshTransactions - Refresh danh sách
class RefreshTransactions extends TransactionEvent {
  // Internally gọi LoadTransactions
}
```

### 📥 States

**File**: `transaction_state.dart`

```dart
// 1. TransactionInitial - State ban đầu
class TransactionInitial extends TransactionState {}

// 2. TransactionLoading - Đang load dữ liệu
class TransactionLoading extends TransactionState {}

// 3. TransactionLoaded - Load thành công
class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;    // Danh sách giao dịch
  final List<CategoryEntity> categories;         // Danh sách categories
  final TransactionFilter currentFilter;         // Filter hiện tại

  // copyWith() để update state partially
  TransactionLoaded copyWith({...});
}

// 4. TransactionActionInProgress - Đang thực hiện action (add/update/delete)
class TransactionActionInProgress extends TransactionState {}

// 5. TransactionActionSuccess - Action thành công
class TransactionActionSuccess extends TransactionState {
  final String message;  // "Thêm thành công", "Xóa thành công"...
}

// 6. TransactionError - Có lỗi xảy ra
class TransactionError extends TransactionState {
  final String message;
}
```

**State Flow**:

```
TransactionInitial
    ↓ LoadTransactions event
TransactionLoading
    ↓ Success
TransactionLoaded
    ↓ AddTransaction event
TransactionActionInProgress
    ↓ Success
TransactionActionSuccess
    ↓ Auto reload
TransactionLoading
    ↓
TransactionLoaded (with new data)
```

### 🔄 Bloc Event Handlers

#### **\_onLoadTransactions**

```dart
Future<void> _onLoadTransactions(
  LoadTransactions event,
  Emitter<TransactionState> emit,
) async {
  emit(TransactionLoading());

  // Load transactions và categories song song
  final transactionsResult = await getAllTransactionsUseCase(NoParams());
  final categoriesResult = await getAllCategoriesUseCase(NoParams());

  // Check results
  if (transactionsResult.isLeft() || categoriesResult.isLeft()) {
    emit(TransactionError(message: 'Không thể tải dữ liệu'));
    return;
  }

  // Extract data
  final transactions = transactionsResult.getOrElse(() => []);
  final categories = categoriesResult.getOrElse(() => []);

  // Emit loaded state
  emit(TransactionLoaded(
    transactions: transactions,
    categories: categories,
    currentFilter: TransactionFilter.all,
  ));
}
```

#### **\_onAddTransaction**

```dart
Future<void> _onAddTransaction(
  AddTransaction event,
  Emitter<TransactionState> emit,
) async {
  // Lưu state để restore nếu lỗi
  final previousState = state;

  // Show loading
  emit(TransactionActionInProgress());

  // Call UseCase
  final result = await addTransactionUseCase(
    AddTransactionParams(transaction: event.transaction),
  );

  // Handle result
  result.fold(
    // Error case
    (failure) {
      emit(TransactionError(message: 'Không thể thêm giao dịch'));
      // Restore previous state
      if (previousState is TransactionLoaded) {
        emit(previousState);
      }
    },
    // Success case
    (_) {
      emit(TransactionActionSuccess(message: 'Thêm giao dịch thành công'));
      // Reload to get fresh data
      add(LoadTransactions());
    },
  );
}
```

---

## 5. Domain Layer

### 📦 Entities

#### **TransactionEntity**

**File**: Shared từ Dashboard feature

```dart
class TransactionEntity extends Equatable {
  final String id;              // UUID
  final String categoryId;      // FK to Category
  final String description;     // "Mua cà phê", "Nhận lương"...
  final double amount;          // 50000.0
  final DateTime date;          // 2025-10-31
  final TransactionType type;   // income / expense

  // Enum
  enum TransactionType { income, expense }
}
```

### ⚙️ UseCases

Transaction feature có **5 UseCases** chính:

#### 1. **GetAllTransactionsUseCase** (READ)

**File**: `get_all_transactions_usecase.dart`

```dart
class GetAllTransactionsUseCase
    implements UseCase<List<TransactionEntity>, NoParams> {
  final TransactionRepository repository;

  GetAllTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(NoParams params) async {
    return await repository.getAllTransactions();
  }
}
```

**Trách nhiệm**:

- Lấy tất cả giao dịch từ repository
- Không có parameters (NoParams)
- Trả về danh sách TransactionEntity
- Repository sẽ sort theo ngày mới nhất

**Khi nào gọi?**

- Khi mở TransactionListPage lần đầu
- Sau khi thêm/sửa/xóa giao dịch (để refresh)
- Khi pull-to-refresh

---

#### 2. **AddTransactionUseCase** (CREATE)

**File**: `add_transaction_usecase.dart`

```dart
class AddTransactionUseCase implements UseCase<void, AddTransactionParams> {
  final TransactionRepository repository;

  AddTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTransactionParams params) async {
    return await repository.addTransaction(params.transaction);
  }
}

// Parameters
class AddTransactionParams extends Equatable {
  final TransactionEntity transaction;

  const AddTransactionParams({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}
```

**Trách nhiệm**:

- Thêm giao dịch mới vào database
- Nhận TransactionEntity từ UI
- Validate có thể thêm ở đây (nếu cần business rules)

**Validation có thể thêm**:

```dart
@override
Future<Either<Failure, void>> call(AddTransactionParams params) async {
  // Business validation
  if (params.transaction.amount <= 0) {
    return Left(ValidationFailure(message: 'Số tiền phải lớn hơn 0'));
  }

  if (params.transaction.description.isEmpty) {
    return Left(ValidationFailure(message: 'Vui lòng nhập mô tả'));
  }

  return await repository.addTransaction(params.transaction);
}
```

**Khi nào gọi?**

- User nhấn "Lưu" ở AddTransactionPage
- Form đã validate ở UI level
- UseCase có thể thêm business validation

---

#### 3. **UpdateTransactionUseCase** (UPDATE)

**File**: `update_transaction_usecase.dart`

```dart
class UpdateTransactionUseCase
    implements UseCase<void, UpdateTransactionParams> {
  final TransactionRepository repository;

  UpdateTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateTransactionParams params) async {
    return await repository.updateTransaction(params.transaction);
  }
}

// Parameters
class UpdateTransactionParams extends Equatable {
  final TransactionEntity transaction;

  const UpdateTransactionParams({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}
```

**Trách nhiệm**:

- Cập nhật giao dịch existing
- Transaction phải có ID hợp lệ
- Update toàn bộ fields

**Khi nào gọi?**

- User edit transaction và nhấn "Lưu"
- Transaction entity được pre-fill với data cũ
- User chỉ sửa một số fields

---

#### 4. **DeleteTransactionUseCase** (DELETE)

**File**: `delete_transaction_usecase.dart`

```dart
class DeleteTransactionUseCase
    implements UseCase<void, DeleteTransactionParams> {
  final TransactionRepository repository;

  DeleteTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTransactionParams params) async {
    return await repository.deleteTransaction(params.id);
  }
}

// Parameters
class DeleteTransactionParams extends Equatable {
  final String id;

  const DeleteTransactionParams({required this.id});

  @override
  List<Object?> get props => [id];
}
```

**Trách nhiệm**:

- Xóa giao dịch theo ID
- Chỉ cần ID, không cần toàn bộ entity

**Khi nào gọi?**

- User swipe to delete
- User tap icon delete và confirm
- Sau khi show confirmation dialog

---

#### 5. **GetAllCategoriesUseCase** (READ)

**File**: `get_all_categories_usecase.dart`

```dart
class GetAllCategoriesUseCase
    implements UseCase<List<CategoryEntity>, NoParams> {
  final TransactionRepository repository;

  GetAllCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) async {
    return await repository.getAllCategories();
  }
}
```

**Trách nhiệm**:

- Lấy danh sách categories để hiển thị trong dropdown
- Dùng khi add/edit transaction (chọn category)
- NoParams vì lấy tất cả

**Khi nào gọi?**

- Khi mở AddEditTransactionPage
- Khi load TransactionListPage (để map category info)

---

### 🔌 Repository Interface

**File**: `transaction_repository.dart`

```dart
abstract class TransactionRepository {
  // READ operations
  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions();
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByType(
    TransactionType type,
  );
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id);
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories();

  // WRITE operations
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction);
  Future<Either<Failure, void>> updateTransaction(TransactionEntity transaction);
  Future<Either<Failure, void>> deleteTransaction(String id);
}
```

**Tại sao cần interface?**

- Domain layer chỉ định nghĩa "cái gì" (what)
- Data layer implement "như thế nào" (how)
- Dễ test (mock repository)
- Dễ thay đổi implementation (Hive → SQLite → API)

---

## 6. Data Layer

### 🏗 Repository Implementation

**File**: `transaction_repository_impl.dart`

```dart
class TransactionRepositoryImpl implements TransactionRepository {
  final DashboardLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions() async {
    try {
      // 1. Get models from DataSource
      final models = await localDataSource.getAllTransactions();

      // 2. Convert Model → Entity
      final entities = models.map((model) => model.toEntity()).toList();

      // 3. Business logic: Sort by date descending
      entities.sort((a, b) => b.date.compareTo(a.date));

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      // 1. Convert Entity → Model
      final model = TransactionModel.fromEntity(transaction);

      // 2. Save to DataSource
      await localDataSource.addTransaction(model);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await localDataSource.updateTransaction(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await localDataSource.deleteTransaction(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories() async {
    try {
      final models = await localDataSource.getAllCategories();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
```

**Trách nhiệm**:

- Convert Entity ↔ Model
- Call DataSource methods
- Catch exceptions → return Either
- Thêm business logic (như sort)

---

### 💾 DataSource

Transaction feature **TÁI SỬ DỤNG** `DashboardLocalDataSource`:

**File**: `dashboard_local_data_source.dart` (đã có sẵn)

```dart
abstract class DashboardLocalDataSource {
  // Transactions
  Future<List<TransactionModel>> getAllTransactions();
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);

  // Categories
  Future<List<CategoryModel>> getAllCategories();
}
```

**Implementation**: `dashboard_local_data_source_impl.dart`

```dart
class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  Box<TransactionModel>? _transactionBox;

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    return _transactionBox!.values.toList();
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionBox!.put(transaction.id, transaction);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionBox!.put(transaction.id, transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _transactionBox!.delete(id);
  }
}
```

**Hive Operations**:

- `box.values.toList()` - Get all
- `box.put(key, value)` - Add/Update
- `box.delete(key)` - Delete
- `box.get(key)` - Get by key

---

## 7. Ví Dụ Chi Tiết: Thêm Giao Dịch

### 📱 Scenario: User thêm giao dịch "Mua cà phê - 25.000đ"

#### **Bước 1: User mở AddTransactionPage**

```dart
// User tap nút "+" từ TransactionListPage
await context.push('/transactions/add');

// AddEditTransactionPage được render
class AddEditTransactionPage extends StatefulWidget {
  final TransactionEntity? transaction;  // null khi add, có data khi edit

  @override
  void initState() {
    super.initState();
    // Load categories để hiển thị dropdown
    context.read<TransactionBloc>().add(LoadTransactions());
  }
}
```

#### **Bước 2: User nhập thông tin**

```dart
// Form fields
TextField(
  controller: _amountController,
  inputFormatters: [CurrencyInputFormatter()],
  // User nhập: "25000" → Hiển thị: "25.000"
)

TextField(
  controller: _descriptionController,
  // User nhập: "Mua cà phê"
)

// User chọn category từ dropdown
DropdownButton<String>(
  items: categories.map((cat) => DropdownMenuItem(
    value: cat.id,
    child: Text(cat.name),
  )).toList(),
  onChanged: (categoryId) {
    setState(() => selectedCategoryId = categoryId);
  },
)

// User chọn ngày
DatePicker.showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  onDateSelected: (date) {
    setState(() => selectedDate = date);
  },
)

// User chọn loại
SegmentedButton(
  segments: [
    ButtonSegment(value: TransactionType.expense, label: Text('Chi')),
    ButtonSegment(value: TransactionType.income, label: Text('Thu')),
  ],
  selected: {selectedType},
  onSelectionChanged: (Set<TransactionType> newSelection) {
    setState(() => selectedType = newSelection.first);
  },
)
```

#### **Bước 3: User nhấn "Lưu"**

```dart
// Trong AddEditTransactionPage
void _handleSave() {
  // 1. Validate
  if (!_formKey.currentState!.validate()) {
    return;
  }

  // 2. Parse amount từ formatted string
  final amount = CurrencyInputFormatter.getNumericValue(
    _amountController.text
  ); // "25.000" → 25000.0

  // 3. Tạo TransactionEntity
  final transaction = TransactionEntity(
    id: widget.transaction?.id ?? Uuid().v4(),  // Generate UUID nếu add mới
    categoryId: selectedCategoryId!,
    description: _descriptionController.text,
    amount: amount!,
    date: selectedDate,
    type: selectedType,
  );

  // 4. Dispatch event đến Bloc
  context.read<TransactionBloc>().add(
    AddTransaction(transaction: transaction),
  );
}
```

#### **Bước 4: TransactionBloc xử lý event**

```dart
// transaction_bloc.dart
Future<void> _onAddTransaction(
  AddTransaction event,
  Emitter<TransactionState> emit,
) async {
  print('🎛 Bloc: Received AddTransaction event');
  print('🎛 Transaction: ${event.transaction.description}');

  // Lưu state hiện tại để restore nếu lỗi
  final previousState = state;

  // Step 1: Emit loading state
  emit(TransactionActionInProgress());
  print('🎛 Bloc: Emitting TransactionActionInProgress');

  // Step 2: Call UseCase
  final result = await addTransactionUseCase(
    AddTransactionParams(transaction: event.transaction),
  );
  print('📞 Bloc: Called AddTransactionUseCase');

  // Step 3: Handle result
  result.fold(
    // Error case
    (failure) {
      print('❌ Bloc: Error - ${failure.message}');
      emit(TransactionError(message: 'Không thể thêm giao dịch'));

      // Restore previous state để user không mất data đang xem
      if (previousState is TransactionLoaded) {
        emit(previousState);
      }
    },
    // Success case
    (_) {
      print('✅ Bloc: Success');
      emit(TransactionActionSuccess(message: 'Thêm giao dịch thành công'));

      // Reload transactions để get fresh data
      add(LoadTransactions());
    },
  );
}
```

#### **Bước 5: UseCase thực thi**

```dart
// add_transaction_usecase.dart
@override
Future<Either<Failure, void>> call(AddTransactionParams params) async {
  print('📞 UseCase: Received params');
  print('📞 Amount: ${params.transaction.amount}');
  print('📞 Description: ${params.transaction.description}');

  // Call repository
  final result = await repository.addTransaction(params.transaction);
  print('📞 UseCase: Repository call completed');

  return result;
}
```

#### **Bước 6: Repository thực hiện**

```dart
// transaction_repository_impl.dart
@override
Future<Either<Failure, void>> addTransaction(
  TransactionEntity transaction,
) async {
  try {
    print('🏗 Repository: Converting Entity to Model');

    // 1. Convert Entity → Model
    final model = TransactionModel.fromEntity(transaction);

    print('🏗 Model ID: ${model.id}');
    print('🏗 Model amount: ${model.amount}');
    print('🏗 Model type: ${model.type}');

    // 2. Call DataSource to save
    print('🏗 Repository: Calling DataSource.addTransaction()');
    await localDataSource.addTransaction(model);

    print('✅ Repository: Transaction saved successfully');
    return const Right(null);
  } catch (e) {
    print('❌ Repository: Error - $e');
    return Left(CacheFailure(message: e.toString()));
  }
}
```

#### **Bước 7: DataSource lưu vào Hive**

```dart
// dashboard_local_data_source_impl.dart
@override
Future<void> addTransaction(TransactionModel transaction) async {
  print('💾 DataSource: Saving to Hive');
  print('💾 Box: ${_transactionBox!.name}');
  print('💾 Transaction ID: ${transaction.id}');

  // Save to Hive
  await _transactionBox!.put(transaction.id, transaction);

  print('✅ DataSource: Saved successfully');
  print('💾 Total transactions in box: ${_transactionBox!.length}');
}
```

#### **Bước 8: Bloc reload data**

```dart
// Sau khi emit TransactionActionSuccess, Bloc dispatch LoadTransactions
add(LoadTransactions());

// LoadTransactions được xử lý
Future<void> _onLoadTransactions(...) async {
  emit(TransactionLoading());

  // Get fresh data from UseCase
  final result = await getAllTransactionsUseCase(NoParams());

  result.fold(
    (failure) => emit(TransactionError(...)),
    (transactions) {
      emit(TransactionLoaded(
        transactions: transactions,  // Bao gồm transaction vừa thêm
        categories: [...],
        currentFilter: TransactionFilter.all,
      ));
    },
  );
}
```

#### **Bước 9: UI cập nhật**

```dart
// AddEditTransactionPage
BlocListener<TransactionBloc, TransactionState>(
  listener: (context, state) {
    if (state is TransactionActionSuccess) {
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );

      // Pop về TransactionListPage
      Navigator.of(context).pop();
    }

    if (state is TransactionError) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Lỗi'),
          content: Text(state.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Đóng'),
            ),
          ],
        ),
      );
    }
  },
  child: ...,
)

// TransactionListPage
BlocBuilder<TransactionBloc, TransactionState>(
  builder: (context, state) {
    if (state is TransactionLoaded) {
      // List được rebuild với data mới
      return ListView.builder(
        itemCount: state.transactions.length,
        itemBuilder: (context, index) {
          final transaction = state.transactions[index];
          // Hiển thị transaction "Mua cà phê - 25.000đ"
          return TransactionListItem(transaction: transaction);
        },
      );
    }
  },
)
```

---

### 🔄 Complete Flow Summary

```
User Input
   ↓
Form Validation
   ↓
Create TransactionEntity
   ↓
Dispatch AddTransaction Event
   ↓
TransactionBloc
   ↓ emit TransactionActionInProgress
   ↓ call AddTransactionUseCase
AddTransactionUseCase
   ↓ call repository.addTransaction()
TransactionRepositoryImpl
   ↓ convert Entity → Model
   ↓ call localDataSource.addTransaction()
DashboardLocalDataSourceImpl
   ↓ _transactionBox.put(id, model)
Hive Database
   ↓ saved successfully
Return Right(null)
   ↓
TransactionRepositoryImpl
   ↓ return Right(null)
AddTransactionUseCase
   ↓ return Right(null)
TransactionBloc
   ↓ emit TransactionActionSuccess
   ↓ dispatch LoadTransactions
   ↓ emit TransactionLoaded (with new data)
UI Updates
   ↓ Show snackbar
   ↓ Pop to ListPage
   ↓ Rebuild list with new transaction
Done ✅
```

---

## 8. Sơ Đồ Quan Hệ

### 🏗 Class Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────┐       ┌──────────────────────┐        │
│  │ TransactionListPage  │─uses─▶│  TransactionBloc     │        │
│  └──────────────────────┘       └────────┬─────────────┘        │
│                                           │                      │
│  ┌──────────────────────┐                │                      │
│  │AddEditTransactionPage│─uses──────────▶│                      │
│  └──────────────────────┘                │                      │
│                                           │ handles              │
│                                           ▼                      │
│  ┌────────────────────────────────────────────────────┐         │
│  │           TransactionEvent (Abstract)              │         │
│  ├────────────────────────────────────────────────────┤         │
│  │ - LoadTransactions                                 │         │
│  │ - ChangeTransactionFilter                          │         │
│  │ - AddTransaction(transaction)                      │         │
│  │ - UpdateTransaction(transaction)                   │         │
│  │ - DeleteTransaction(id)                            │         │
│  │ - RefreshTransactions                              │         │
│  └────────────────────────────────────────────────────┘         │
│                                                                  │
│  ┌────────────────────────────────────────────────────┐         │
│  │           TransactionState (Abstract)              │         │
│  ├────────────────────────────────────────────────────┤         │
│  │ - TransactionInitial                               │         │
│  │ - TransactionLoading                               │         │
│  │ - TransactionLoaded(transactions, categories)      │         │
│  │ - TransactionActionInProgress                      │         │
│  │ - TransactionActionSuccess(message)                │         │
│  │ - TransactionError(message)                        │         │
│  └────────────────────────────────────────────────────┘         │
│                                                                  │
└────────────────────────┬─────────────────────────────────────────┘
                         │ uses
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                         DOMAIN LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────┐            │
│  │              TransactionBloc                    │            │
│  │  ┌───────────────────────────────────────────┐  │            │
│  │  │ - getAllTransactionsUseCase               │  │            │
│  │  │ - getAllCategoriesUseCase                 │  │            │
│  │  │ - addTransactionUseCase                   │──┼───uses────┐│
│  │  │ - updateTransactionUseCase                │  │           ││
│  │  │ - deleteTransactionUseCase                │  │           ││
│  │  └───────────────────────────────────────────┘  │           ││
│  └─────────────────────────────────────────────────┘           ││
│                                                                 ││
│  ┌────────────────────────────────────────────────────────┐    ││
│  │                     UseCases                           │    ││
│  ├────────────────────────────────────────────────────────┤    ││
│  │                                                        │◀───┘│
│  │  GetAllTransactionsUseCase                            │     │
│  │    ↳ call(NoParams)                                   │     │
│  │    ↳ return Either<Failure, List<TransactionEntity>>  │     │
│  │                                                        │     │
│  │  AddTransactionUseCase                                │     │
│  │    ↳ call(AddTransactionParams)                       │     │
│  │    ↳ return Either<Failure, void>                     │     │
│  │                                                        │     │
│  │  UpdateTransactionUseCase                             │     │
│  │    ↳ call(UpdateTransactionParams)                    │     │
│  │    ↳ return Either<Failure, void>                     │     │
│  │                                                        │     │
│  │  DeleteTransactionUseCase                             │     │
│  │    ↳ call(DeleteTransactionParams)                    │     │
│  │    ↳ return Either<Failure, void>                     │     │
│  │                                                        │     │
│  │  GetAllCategoriesUseCase                              │     │
│  │    ↳ call(NoParams)                                   │     │
│  │    ↳ return Either<Failure, List<CategoryEntity>>     │     │
│  └───────────────────────┬────────────────────────────────┘     │
│                          │ uses                                 │
│                          ▼                                      │
│  ┌────────────────────────────────────────────────────────┐    │
│  │      TransactionRepository (Interface)                 │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │  getAllTransactions()                                  │    │
│  │  addTransaction(entity)                                │    │
│  │  updateTransaction(entity)                             │    │
│  │  deleteTransaction(id)                                 │    │
│  │  getAllCategories()                                    │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌──────────────────┐   ┌──────────────────┐                   │
│  │TransactionEntity │   │  CategoryEntity  │                   │
│  └──────────────────┘   └──────────────────┘                   │
│                                                                  │
└────────────────────────┬─────────────────────────────────────────┘
                         │ implemented by
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                          DATA LAYER                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐     │
│  │       TransactionRepositoryImpl                        │     │
│  │         (implements TransactionRepository)             │     │
│  ├────────────────────────────────────────────────────────┤     │
│  │  final DashboardLocalDataSource localDataSource       │     │
│  │                                                        │     │
│  │  getAllTransactions() {                               │     │
│  │    1. Call localDataSource.getAllTransactions()       │     │
│  │    2. Convert List<Model> → List<Entity>             │     │
│  │    3. Sort by date descending                         │     │
│  │    4. Return Right(entities)                          │     │
│  │  }                                                     │     │
│  │                                                        │     │
│  │  addTransaction(entity) {                             │     │
│  │    1. Convert Entity → Model                          │     │
│  │    2. Call localDataSource.addTransaction(model)      │     │
│  │    3. Return Right(null)                              │     │
│  │  }                                                     │     │
│  └───────────────────────┬────────────────────────────────┘     │
│                          │ uses                                 │
│                          ▼                                      │
│  ┌────────────────────────────────────────────────────────┐    │
│  │     DashboardLocalDataSource (Reused)                  │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │  Box<TransactionModel> _transactionBox                 │    │
│  │  Box<CategoryModel> _categoryBox                       │    │
│  │                                                        │    │
│  │  getAllTransactions() → List<TransactionModel>         │    │
│  │  addTransaction(model) → void                          │    │
│  │  updateTransaction(model) → void                       │    │
│  │  deleteTransaction(id) → void                          │    │
│  │  getAllCategories() → List<CategoryModel>              │    │
│  └───────────────────────┬────────────────────────────────┘    │
│                          │ uses                                 │
│                          ▼                                      │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                  Hive Database                         │    │
│  │  Box<TransactionModel> transactions                    │    │
│  │  Box<CategoryModel> categories                         │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 🔄 Sequence Diagram: Add Transaction Flow

```
User     AddEditPage   TransactionBloc   UseCase      Repository    DataSource    Hive
 │            │               │              │             │             │          │
 │─Fill form─▶│               │              │             │             │          │
 │─Tap Save──▶│               │              │             │             │          │
 │            │──AddTransaction event──────▶│              │             │          │
 │            │               │──TransactionActionInProgress────────────▶│          │
 │            │               │              │             │             │          │
 │            │               │──call()─────▶│             │             │          │
 │            │               │              │──addTransaction(entity)──▶│          │
 │            │               │              │             │             │          │
 │            │               │              │             │ Convert    │          │
 │            │               │              │             │ Entity→Model          │
 │            │               │              │             │             │          │
 │            │               │              │             │──addTransaction(model)─▶│
 │            │               │              │             │             │──put()──▶│
 │            │               │              │             │             │◀─saved──│
 │            │               │              │             │◀────────────│          │
 │            │               │              │◀────Right(null)──────────│          │
 │            │               │◀─Right(null)─│             │             │          │
 │            │               │              │             │             │          │
 │            │               │──TransactionActionSuccess────────────────▶│          │
 │            │◀──Success─────│              │             │             │          │
 │◀─Snackbar──│               │              │             │             │          │
 │◀─Pop page──│               │              │             │             │          │
 │            │               │              │             │             │          │
 │            │               │──LoadTransactions event───▶│             │          │
 │            │               │──TransactionLoading─────────────────────▶│          │
 │            │               │              │             │             │          │
 │            │               │──call()─────▶│             │             │          │
 │            │               │              │──getAllTransactions()───▶│          │
 │            │               │              │             │──getAllTransactions()─▶│
 │            │               │              │             │             │──query()─▶│
 │            │               │              │             │             │◀─models─│
 │            │               │              │             │◀────models──│          │
 │            │               │              │             │             │          │
 │            │               │              │             │ Convert     │          │
 │            │               │              │             │ Models→Entities        │
 │            │               │              │             │ Sort by date           │
 │            │               │              │             │             │          │
 │            │               │              │◀─Right(entities)─────────│          │
 │            │               │◀─Right(entities)─           │             │          │
 │            │               │              │             │             │          │
 │            │               │──TransactionLoaded(new data)─────────────▶│          │
List Page  │◀──UI rebuilt───│              │             │             │          │
 │◀─Show new transaction────────────────────│             │             │          │
```

---

## 📚 Tổng Kết

### ✅ Key Takeaways

#### 1. **Clean Separation**

- UI chỉ biết về Bloc và Entities
- Bloc chỉ biết về UseCases
- UseCases chỉ biết về Repository Interface
- Repository Implementation biết về DataSource

#### 2. **CRUD Pattern Consistency**

Mỗi operation (Create/Read/Update/Delete) đều follow cùng một pattern:

```
Event → Bloc → UseCase → Repository → DataSource → Hive
Hive → DataSource → Repository → UseCase → Bloc → State → UI
```

#### 3. **Error Handling với Either**

```dart
result.fold(
  (failure) => handleError(),
  (success) => handleSuccess(),
);
```

#### 4. **State Management Strategy**

- Loading state trước khi call async
- Action in progress cho CRUD operations
- Success/Error states với messages
- Restore previous state nếu error

#### 5. **Reusability**

- DataSource được share giữa Dashboard và Transaction
- Models/Entities được reuse
- UseCases có thể được gọi từ nhiều nơi

---

### 🔧 Best Practices

#### 1. **Validation Layers**

```
UI Validation (Form validators)
    ↓
Business Validation (UseCase)
    ↓
Data Validation (Repository/DataSource)
```

#### 2. **Loading States**

```dart
// Show loading before async operation
emit(TransactionActionInProgress());

// Call async operation
await useCase();

// Show result
emit(TransactionActionSuccess());
```

#### 3. **Error Recovery**

```dart
// Save previous state
final previousState = state;

// Try operation
final result = await operation();

// Restore on error
if (result.isLeft()) {
  emit(previousState);
}
```

#### 4. **Reload After Mutation**

```dart
// After add/update/delete
emit(TransactionActionSuccess(message: 'Success'));

// Reload to get fresh data
add(LoadTransactions());
```

---

### 🐛 Common Issues & Solutions

#### Issue 1: UI không update sau khi add/delete

**Solution**: Dispatch `LoadTransactions` event sau action success

#### Issue 2: Category không hiển thị đúng

**Solution**: Load categories cùng lúc với transactions trong `LoadTransactions`

#### Issue 3: Format số tiền bị lỗi

**Solution**: Dùng `CurrencyInputFormatter` và parse đúng cách

#### Issue 4: State bị mất khi error

**Solution**: Save previous state trước khi emit loading/action states

---

### 📖 Tài Liệu Liên Quan

- [Dashboard Feature Guide](./DASHBOARD_FEATURE_TECHNICAL_GUIDE.md)
- [Category Feature Guide](./CATEGORY_FEATURE_GUIDE.md)
- [Statistics Feature Guide](./STATISTICS_FEATURE_GUIDE.md)

---

**Tài liệu được tạo cho**: MONI - Save & Grow  
**Feature**: Transaction Management (CRUD)  
**Version**: 1.0.0  
**Ngày cập nhật**: October 31, 2025  
**Tác giả**: Thân Thân
