# 💰 Transaction Feature - Luồng Xử Lý Dữ Liệu

## 📋 Tổng Quan

Transaction feature quản lý toàn bộ giao dịch thu chi với đầy đủ chức năng CRUD theo kiến trúc Clean Architecture.

### 🎯 Chức Năng Chính

- **Quản lý giao dịch:** Thêm, sửa, xóa, xem danh sách giao dịch
- **Phân loại:** Giao dịch thu nhập (income) hoặc chi tiêu (expense)
- **Liên kết category:** Mỗi giao dịch thuộc về 1 category
- **Ghi chú:** Thêm mô tả cho từng giao dịch
- **Lọc và sắp xếp:** Theo ngày, loại, category

---

## 🏗️ Kiến Trúc Clean Architecture

### Cấu Trúc 3 Tầng

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)         │
│  - TransactionListPage              │
│  - AddEditTransactionPage           │
│  - TransactionBloc                  │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│        Domain Layer (Logic)         │
│  - TransactionEntity                │
│  - UseCases (business rules)        │
│  - TransactionRepository Interface  │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      Data Layer (Storage)           │
│  - TransactionModel (Hive typeId:0) │
│  - TransactionLocalDataSource       │
│  - Repository Implementation        │
└─────────────┬───────────────────────┘
              │
              ▼
        [Hive Database]
```

### Vai Trò Từng Tầng

**1. Presentation Layer:**

- Hiển thị danh sách giao dịch theo thời gian
- Form thêm/sửa giao dịch với validation
- Quản lý state với BLoC pattern
- Hiển thị loading, error, success states

**2. Domain Layer:**

- Định nghĩa TransactionEntity với các thuộc tính cốt lõi
- Chứa business rules trong UseCases
- Repository interface để Data Layer implement
- Không phụ thuộc vào framework hay database

**3. Data Layer:**

- TransactionModel với Hive annotations (@HiveType typeId: 0)
- TransactionLocalDataSource tương tác trực tiếp với Hive
- Repository convert Model ↔ Entity
- Bọc kết quả trong Either<Failure, Data>

---

## 🔄 Luồng Xử Lý Dữ Liệu

### 1. Load Danh Sách Transactions

```
User mở Transaction List Page
         ↓
UI dispatch LoadAllTransactionsEvent
         ↓
TransactionBloc nhận event
         ↓
BLoC emit TransactionLoadingState (hiển thị loading indicator)
         ↓
BLoC gọi GetAllTransactionsUseCase.call()
         ↓
UseCase gọi TransactionRepository.getAllTransactions()
         ↓
Repository gọi TransactionLocalDataSource.getAllTransactions()
         ↓
DataSource mở Hive box 'transactions'
         ↓
DataSource lấy tất cả TransactionModel từ box.values
         ↓
DataSource trả về List<TransactionModel>
         ↓
Repository chuyển đổi từng Model → Entity
         ↓
Repository sắp xếp theo ngày mới nhất (sort by date DESC)
         ↓
Repository trả Either<Failure, List<TransactionEntity>>
         ↓
UseCase trả kết quả về BLoC
         ↓
BLoC emit TransactionsLoadedState với danh sách
         ↓
UI rebuild:
  - Ẩn loading
  - Hiển thị danh sách transactions
  - Group by date (hôm nay, hôm qua, tuần này, v.v.)
  - Hiển thị tổng thu/chi cho mỗi ngày
```

**Xử lý lỗi:**

- Hive box không mở được → emit TransactionErrorState
- UI hiển thị error message với retry button

---

### 2. Thêm Transaction Mới

```
User nhấn nút "+" trên Transaction List Page
         ↓
Navigate to AddEditTransactionPage (mode: Add)
         ↓
UI hiển thị form với các trường:
  - Số tiền (amount) - TextField với input type number
  - Loại (income/expense) - Toggle button
  - Category - Dropdown list (load từ CategoryRepository)
  - Ngày - DatePicker (default: hôm nay)
  - Ghi chú (note) - TextField optional
         ↓
User nhập đầy đủ thông tin
         ↓
User nhấn "Lưu"
         ↓
UI validate form:
  - Amount > 0
  - Category đã chọn
  - Date không null
         ↓
Nếu validation pass:
  UI dispatch AddTransactionEvent với TransactionEntity
         ↓
TransactionBloc nhận event
         ↓
BLoC gọi AddTransactionUseCase.call(entity)
         ↓
UseCase gọi Repository.addTransaction(entity)
         ↓
Repository chuyển đổi Entity → TransactionModel
Repository generate ID nếu chưa có (UUID)
         ↓
Repository gọi DataSource.addTransaction(model)
         ↓
DataSource lưu vào Hive: box.put(model.id, model)
         ↓
Hive lưu thành công → trả void
         ↓
Repository trả Right(null)
         ↓
UseCase trả về BLoC
         ↓
BLoC emit TransactionAddedState
         ↓
UI:
  - Pop AddEditTransactionPage
  - Hiển thị SnackBar "Thêm giao dịch thành công"
  - Transaction List Page tự động refresh (listen TransactionAddedState)
  - Dispatch LoadAllTransactionsEvent để reload danh sách
```

**Validation Details:**

- Amount: Phải > 0, không được để trống
- Category: Bắt buộc phải chọn
- Type: Income hoặc Expense (toggle)
- Date: Không được để trống, có thể chọn quá khứ hoặc tương lai
- Note: Optional, max 500 ký tự

**Xử lý lỗi:**

- Validation fail → hiển thị error text dưới TextField
- Lưu Hive thất bại → emit TransactionErrorState
- UI hiển thị error dialog với option retry

---

### 3. Cập Nhật Transaction

```
User tap vào 1 transaction trong danh sách
         ↓
Navigate to AddEditTransactionPage (mode: Edit)
         ↓
UI dispatch GetTransactionByIdEvent (để lấy chi tiết)
         ↓
BLoC gọi GetTransactionByIdUseCase
         ↓
UseCase gọi Repository.getTransactionById(id)
         ↓
Repository gọi DataSource.getAllTransactions()
Repository filter để tìm transaction có id matching
         ↓
Repository convert Model → Entity
         ↓
Repository trả Either<Failure, TransactionEntity>
         ↓
BLoC emit TransactionDetailLoadedState
         ↓
UI pre-fill form với dữ liệu hiện tại:
  - Amount → TextField
  - Type → Toggle button
  - Category → Dropdown (selected)
  - Date → DatePicker
  - Note → TextField
         ↓
User chỉnh sửa thông tin
         ↓
User nhấn "Lưu"
         ↓
UI validate form (tương tự Add)
         ↓
UI dispatch UpdateTransactionEvent với TransactionEntity đã chỉnh sửa
         ↓
BLoC gọi UpdateTransactionUseCase.call(entity)
         ↓
UseCase gọi Repository.updateTransaction(entity)
         ↓
Repository convert Entity → Model (giữ nguyên ID)
         ↓
Repository gọi DataSource.updateTransaction(model)
         ↓
DataSource: box.put(model.id, model) - overwrite
         ↓
Hive cập nhật thành công
         ↓
Repository trả Right(null)
         ↓
BLoC emit TransactionUpdatedState
         ↓
UI:
  - Pop AddEditTransactionPage
  - Hiển thị SnackBar "Cập nhật thành công"
  - Refresh danh sách transactions
```

**Lưu ý:**

- Giữ nguyên ID của transaction
- Update = overwrite với cùng key trong Hive
- Các transaction liên quan (statistics) tự động cập nhật khi reload

---

### 4. Xóa Transaction

```
User long-press hoặc swipe transaction item
         ↓
UI hiển thị menu với option "Xóa"
         ↓
User chọn "Xóa"
         ↓
UI hiển thị ConfirmDialog:
  "Bạn có chắc muốn xóa giao dịch này?"
  - Hiển thị thông tin transaction (amount, category, date)
  - Buttons: "Hủy" và "Xóa"
         ↓
User nhấn "Xóa"
         ↓
UI dispatch DeleteTransactionEvent(id)
         ↓
BLoC gọi DeleteTransactionUseCase.call(id)
         ↓
UseCase gọi Repository.deleteTransaction(id)
         ↓
Repository gọi DataSource.deleteTransaction(id)
         ↓
DataSource: box.delete(id)
         ↓
Hive xóa thành công
         ↓
Repository trả Right(null)
         ↓
BLoC emit TransactionDeletedState
         ↓
UI:
  - Hiển thị SnackBar "Đã xóa giao dịch"
  - Transaction biến mất khỏi danh sách với animation
  - Refresh danh sách
```

**Bảo vệ dữ liệu:**

- Confirm dialog trước khi xóa
- Không có undo (có thể thêm tính năng này sau)
- Xóa transaction không ảnh hưởng đến categories

---

### 5. Lọc Transactions Theo Loại

```
User chọn filter button trên TransactionListPage
         ↓
UI hiển thị bottom sheet với options:
  - Tất cả
  - Thu nhập
  - Chi tiêu
         ↓
User chọn "Thu nhập"
         ↓
UI dispatch FilterTransactionsByTypeEvent(TransactionType.income)
         ↓
BLoC gọi GetTransactionsByTypeUseCase.call(type)
         ↓
UseCase gọi Repository.getTransactionsByType(type)
         ↓
Repository gọi DataSource.getAllTransactions()
Repository filter transactions có type = 'income'
         ↓
Repository convert Models → Entities
Repository sort by date DESC
         ↓
Repository trả Either<Failure, List<TransactionEntity>>
         ↓
BLoC emit TransactionsLoadedState với danh sách đã lọc
         ↓
UI rebuild:
  - Hiển thị chỉ transactions thu nhập
  - Header hiển thị filter hiện tại
  - Tổng số tiền thu nhập
```

**Filter Options:**

- All: Hiển thị tất cả transactions
- Income: Chỉ transactions có type = income
- Expense: Chỉ transactions có type = expense

---

### 6. Load Categories Cho Dropdown

```
AddEditTransactionPage khởi tạo
         ↓
UI dispatch LoadCategoriesEvent
         ↓
BLoC gọi GetAllCategoriesUseCase
         ↓
UseCase gọi TransactionRepository.getAllCategories()
         ↓
Repository gọi CategoryManagementRepository.getAllCategories()
         ↓
Category Repository gọi CategoryLocalDataSource
         ↓
DataSource lấy tất cả categories từ Hive box 'categories'
         ↓
Trả về List<CategoryEntity>
         ↓
UI hiển thị dropdown với:
  - Icon của category
  - Tên category
  - Màu sắc
  - Group by type (Income categories / Expense categories)
```

**Lưu ý:**

- Transaction Repository inject CategoryManagementRepository
- Tuân thủ Clean Architecture: Feature không trực tiếp gọi DataSource của feature khác

---

## 📦 Data Flow Chi Tiết

### Domain Layer

**TransactionEntity:**

```
Thuộc tính:
- id: String (UUID)
- amount: double (số tiền)
- type: TransactionType (income/expense)
- categoryId: String (liên kết với category)
- date: DateTime (ngày giao dịch)
- note: String (ghi chú, optional)
```

**Repository Interface:**

- `getAllTransactions()` → Lấy tất cả
- `getTransactionsByType(type)` → Lọc theo income/expense
- `getTransactionById(id)` → Lấy 1 transaction
- `addTransaction(entity)` → Thêm mới
- `updateTransaction(entity)` → Cập nhật
- `deleteTransaction(id)` → Xóa
- `clearAllTransactions()` → Xóa tất cả (testing/reset)
- `getAllCategories()` → Lấy categories cho dropdown

**UseCases:**

- `GetAllTransactionsUseCase`: Lấy toàn bộ danh sách
- `GetTransactionsByTypeUseCase`: Lọc theo loại
- `AddTransactionUseCase`: Thêm với validation
- `UpdateTransactionUseCase`: Cập nhật
- `DeleteTransactionUseCase`: Xóa
- `GetAllCategoriesUseCase`: Lấy categories (cho dropdown)

---

### Data Layer

**TransactionModel:**

```
@HiveType(typeId: 0)
- Chứa @HiveField(0..6) cho từng thuộc tính
- Methods: toEntity(), fromEntity()
- Được generate bởi build_runner → transaction_model.g.dart
```

**TransactionLocalDataSource:**

**Interface (transaction_local_data_source.dart):**

- Định nghĩa contract
- Không phụ thuộc Hive

**Implementation (transaction_local_data_source_impl.dart):**

- `init()`: Mở Hive box 'transactions'
- `getAllTransactions()`: Lấy box.values.toList()
- `getTransactionsByDateRange(start, end)`: Filter transactions trong khoảng thời gian
- `addTransaction(model)`: box.put(model.id, model)
- `updateTransaction(model)`: box.put(model.id, model)
- `deleteTransaction(id)`: box.delete(id)
- `clearAllTransactions()`: box.clear()

**Logic Filter Date Range:**

```
Nhận startDate và endDate
Lấy tất cả transactions
Filter với điều kiện:
  - transaction.date >= startDate
  - transaction.date <= endDate
Trả về danh sách đã filter
```

**TransactionRepositoryImpl:**

- Inject 2 dependencies:
  1. TransactionLocalDataSource (để CRUD transactions)
  2. CategoryManagementRepository (để lấy categories)
- Mỗi method:
  1. Gọi DataSource lấy/lưu Models
  2. Convert Model ↔ Entity
  3. Bọc trong Either<Failure, Data>
  4. Catch exceptions → Left(CacheFailure)

---

### Presentation Layer

**TransactionBloc:**

**Events:**

- `LoadAllTransactionsEvent`: Load tất cả
- `FilterTransactionsByTypeEvent`: Lọc theo loại
- `AddTransactionEvent`: Thêm mới
- `UpdateTransactionEvent`: Cập nhật
- `DeleteTransactionEvent`: Xóa
- `GetTransactionByIdEvent`: Lấy chi tiết 1 transaction
- `LoadCategoriesEvent`: Load categories cho dropdown

**States:**

- `TransactionInitialState`: State ban đầu
- `TransactionLoadingState`: Đang load
- `TransactionsLoadedState`: Load thành công + List<TransactionEntity>
- `TransactionDetailLoadedState`: Chi tiết 1 transaction
- `TransactionAddedState`: Thêm thành công
- `TransactionUpdatedState`: Cập nhật thành công
- `TransactionDeletedState`: Xóa thành công
- `CategoriesLoadedState`: Categories đã load cho dropdown
- `TransactionErrorState`: Có lỗi + error message

**UI Pages:**

**1. TransactionListPage:**

- Hiển thị danh sách transactions
- Group by date (Hôm nay, Hôm qua, Tuần này, Tháng này, v.v.)
- Mỗi item hiển thị:
  - Icon category với màu sắc
  - Tên category
  - Note (nếu có)
  - Amount với màu (xanh = thu, đỏ = chi)
  - Thời gian (HH:mm)
- Swipe để xóa
- Tap để edit
- FAB button "+" để thêm mới
- Filter button (All/Income/Expense)

**2. AddEditTransactionPage:**

- Mode được xác định bởi có truyền transaction vào không
- Form fields:
  - Amount TextField (keyboard number)
  - Type toggle (Income/Expense) với animation
  - Category Dropdown với search
  - DatePicker (hiển thị calendar)
  - Note TextField (optional, multiline)
- Validation real-time
- Preview card hiển thị transaction trước khi lưu
- Buttons: "Hủy" và "Lưu"

---

## 🔗 Dependency Injection

### Đăng Ký (injection_container.dart)

**Data Layer:**

```
TransactionLocalDataSource:
  → TransactionLocalDataSourceImpl singleton
  → Init Hive box khi app start
```

**Domain Layer:**

```
TransactionRepository:
  → TransactionRepositoryImpl
  → Inject TransactionLocalDataSource + CategoryManagementRepository
  → Singleton

UseCases:
  → Inject TransactionRepository
  → Lazy singleton
```

**Presentation Layer:**

```
TransactionBloc:
  → Inject tất cả UseCases
  → Factory (new instance mỗi khi navigate to page)
```

---

## 🎯 Business Rules

### Validation Rules

**Amount:**

- Bắt buộc nhập
- Phải > 0
- Không giới hạn số chữ số (để linh hoạt)
- Format hiển thị: #,###.##

**Type:**

- Bắt buộc chọn (income hoặc expense)
- Default: expense (vì chi tiêu thường xuyên hơn)

**Category:**

- Bắt buộc chọn
- Dropdown chỉ hiển thị categories phù hợp với type:
  - Type = income → chỉ hiển thị income categories + both
  - Type = expense → chỉ hiển thị expense categories + both

**Date:**

- Bắt buộc chọn
- Default: hôm nay
- Cho phép chọn quá khứ (nhập giao dịch cũ)
- Cho phép chọn tương lai (giao dịch dự kiến)

**Note:**

- Optional
- Max 500 ký tự
- Multiline

---

## 🚀 Tính Năng Nâng Cao

### Sort và Group

**Sort:**

- Mặc định: Ngày mới nhất lên đầu
- Có thể sort theo: Amount (cao → thấp)

**Group By Date:**

```
Hôm nay (Today)
  - Các transactions trong ngày hôm nay
  - Hiển thị tổng thu, tổng chi

Hôm qua (Yesterday)
  - Transactions của ngày hôm qua

Tuần này (This Week)
  - Từ thứ 2 đầu tuần đến hôm nay

Tháng này (This Month)
  - Từ ngày 1 đến hôm nay

Tháng trước (Last Month)
  - Toàn bộ tháng trước

Cũ hơn (Older)
  - Tất cả transactions trước tháng trước
```

### Search

**Search by:**

- Note/Description
- Category name
- Amount (exact hoặc range)

**Không implement trong version hiện tại** - để cho phase sau

---

## 🔄 Tương Tác Với Features Khác

### Dashboard Feature

Dashboard đọc transactions qua TransactionRepository:

```
Dashboard không trực tiếp gọi TransactionLocalDataSource
Dashboard inject TransactionRepository
Dashboard gọi repository.getAllTransactions()
Dashboard tính toán statistics từ transactions
```

### Statistics Feature

Statistics đọc transactions để phân tích:

```
Statistics inject TransactionLocalDataSource trực tiếp
Statistics filter transactions theo date range
Statistics group theo category, theo tháng
Statistics tính toán charts data
```

### Category Feature

Transaction cần categories để hiển thị:

```
Transaction inject CategoryManagementRepository
Transaction gọi getAllCategories() để lấy dropdown data
Transaction không trực tiếp modify categories
```

---

## 🎨 UI/UX Flow

### Happy Path - Thêm Transaction

```
1. User mở app → Dashboard hiển thị
2. User tap "Giao dịch" tab → TransactionListPage
3. User tap FAB "+" → AddEditTransactionPage
4. User nhập số tiền: 50000
5. User chọn Type: Expense
6. User chọn Category: "Ăn uống" (icon utensils, màu cam)
7. Date tự động = hôm nay
8. User nhập Note: "Cơm trưa"
9. Preview card hiển thị:
   - 🍴 Ăn uống
   - -50,000 đ (màu đỏ)
   - Cơm trưa
   - Hôm nay 12:30
10. User tap "Lưu"
11. Loading indicator hiển thị
12. Success! SnackBar: "Thêm giao dịch thành công"
13. Back to TransactionListPage
14. Transaction mới xuất hiện ở top của "Hôm nay"
15. Danh sách tự động refresh
16. Dashboard tự động cập nhật (nếu đang mở)
```

### Error Handling

**Validation Error:**

```
User nhập amount = 0
→ TextField hiển thị error: "Số tiền phải lớn hơn 0"
→ Button "Lưu" disabled

User không chọn category
→ Dropdown hiển thị error: "Vui lòng chọn danh mục"
→ Button "Lưu" disabled
```

**Database Error:**

```
Hive box không mở được
→ Error dialog: "Không thể kết nối cơ sở dữ liệu"
→ Button "Thử lại"
→ User tap "Thử lại" → Retry init database
```

---

## 📊 Performance Considerations

**Lazy Loading:**

- Không implement trong version hiện tại
- Load tất cả transactions vào memory
- Hive đủ nhanh cho <10,000 transactions

**Pagination:**

- Để dành cho tương lai nếu data lớn
- Hiện tại: Load all, group in memory

**Caching:**

- BLoC giữ state trong memory
- Không cần reload khi back từ detail page
- Chỉ reload khi có thay đổi (add/update/delete)

---

## ✅ Checklist Implementation

- [x] TransactionEntity với đầy đủ properties
- [x] TransactionModel với Hive annotations
- [x] TransactionLocalDataSource interface
- [x] TransactionLocalDataSourceImpl với Hive
- [x] TransactionRepository interface
- [x] TransactionRepositoryImpl
- [x] Tất cả UseCases (Get, Add, Update, Delete)
- [x] TransactionBloc với Events và States
- [x] TransactionListPage UI
- [x] AddEditTransactionPage UI
- [x] Dependency injection setup
- [x] Filter by date range logic
- [x] Integration với CategoryManagementRepository
- [x] Error handling với Either pattern
- [x] Validation logic

---

## 🔮 Future Enhancements

**Version 2.0:**

- Recurring transactions (giao dịch định kỳ)
- Attachments (ảnh hóa đơn)
- Location tracking
- Templates (mẫu giao dịch nhanh)
- Bulk operations (xóa nhiều)

**Version 3.0:**

- Cloud sync
- Multi-currency support
- Budget tracking
- AI-powered categorization
- Export to Excel/PDF
