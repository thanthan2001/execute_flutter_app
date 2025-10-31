# 🏷️ Category Feature - Hướng Dẫn Kỹ Thuật Chi Tiết

## 📑 Mục Lục

1. [Tổng Quan](#1-tổng-quan)
2. [Cấu Trúc Thư Mục](#2-cấu-trúc-thư-mục)
3. [Luồng Xử Lý CRUD](#3-luồng-xử-lý-crud)
4. [Presentation Layer](#4-presentation-layer)
5. [Domain Layer](#5-domain-layer)
6. [Data Layer](#6-data-layer)
7. [Ví Dụ Chi Tiết: Thêm Category Mới](#7-ví-dụ-chi-tiết-thêm-category-mới)
8. [Sơ Đồ Quan Hệ](#8-sơ-đồ-quan-hệ)

---

## 1. Tổng Quan

### 🎯 Mục Tiêu

Category feature cung cấp đầy đủ các chức năng **CRUD** (Create, Read, Update, Delete) để quản lý các nhóm chi tiêu và thu nhập, bao gồm chọn icon từ Font Awesome và màu sắc đại diện.

### ✨ Chức Năng Chính

#### 1. **Create - Thêm Nhóm Mới**

- Form nhập thông tin: tên nhóm, loại (thu/chi/cả hai), icon (Font Awesome), màu sắc
- Validation dữ liệu đầu vào
- Preview trực quan của nhóm trước khi lưu
- Icon picker dialog với danh sách Font Awesome icons
- Color picker dialog với bảng màu đa dạng

#### 2. **Read - Xem Danh Sách Nhóm**

- Hiển thị tất cả nhóm theo loại (Thu/Chi/Cả hai)
- Hiển thị đầy đủ thông tin: icon, tên nhóm, màu sắc, loại
- Group by loại để dễ quản lý
- Tìm kiếm nhóm theo tên

#### 3. **Update - Cập Nhật Nhóm**

- Edit form với dữ liệu pre-fill
- Validate và cập nhật
- Refresh danh sách sau khi cập nhật
- Preview thay đổi trước khi lưu

#### 4. **Delete - Xóa Nhóm**

- Confirm dialog trước khi xóa
- Kiểm tra nhóm có đang được sử dụng không (có giao dịch liên kết)
- Không cho xóa nhóm đang được sử dụng
- Xóa khỏi database (Hive)

---

## 2. Cấu Trúc Thư Mục

```
lib/features/category/
├── data/
│   └── repositories/
│       └── category_management_repository_impl.dart    # Implementation của repository
│
├── domain/
│   ├── repositories/
│   │   └── category_management_repository.dart         # Interface của repository
│   └── usecases/
│       ├── add_category_usecase.dart                   # UseCase thêm category
│       ├── update_category_usecase.dart                # UseCase cập nhật category
│       ├── delete_category_usecase.dart                # UseCase xóa category
│       └── get_all_categories_usecase.dart             # UseCase lấy danh sách categories
│
└── presentation/
    ├── bloc/
    │   ├── category_bloc.dart                          # Bloc xử lý logic
    │   ├── category_event.dart                         # Các event
    │   └── category_state.dart                         # Các state
    ├── pages/
    │   ├── category_list_page.dart                     # Màn hình danh sách
    │   └── add_edit_category_page.dart                 # Màn hình thêm/sửa
    └── widgets/
        ├── icon_picker_dialog.dart                     # Dialog chọn icon (FA)
        └── color_picker_dialog.dart                    # Dialog chọn màu
```

### 📂 Vai Trò Của Từng Layer

#### **Presentation Layer** (`presentation/`)

- **Mục đích**: Hiển thị UI và tương tác với người dùng
- **Chức năng**:
  - Quản lý state của feature bằng BLoC pattern
  - Render UI components (pages, widgets)
  - Xử lý user input và trigger events
  - Hiển thị loading, error, success states

#### **Domain Layer** (`domain/`)

- **Mục đích**: Chứa business logic core, không phụ thuộc vào framework
- **Chức năng**:
  - Định nghĩa entity (CategoryEntity)
  - Định nghĩa repository interface (contract)
  - Chứa các UseCase (business rules)
  - Hoàn toàn độc lập, có thể test dễ dàng

#### **Data Layer** (`data/`)

- **Mục đích**: Xử lý nguồn dữ liệu (local storage - Hive)
- **Chức năng**:
  - Implement repository interface từ domain
  - Tương tác với data source (Hive boxes)
  - Chuyển đổi giữa Model và Entity
  - Xử lý cache, error từ data source

---

## 3. Luồng Xử Lý CRUD

### 📊 Tổng Quan Luồng

```
┌─────────────────┐
│   UI (Widget)   │
│  User Actions   │
└────────┬────────┘
         │ Dispatch Event
         ▼
┌─────────────────┐
│   CategoryBloc  │
│  Event Handler  │
└────────┬────────┘
         │ Call UseCase
         ▼
┌─────────────────┐
│    UseCase      │
│ Business Logic  │
└────────┬────────┘
         │ Execute
         ▼
┌─────────────────┐
│   Repository    │
│   Interface     │
└────────┬────────┘
         │ Implement
         ▼
┌─────────────────┐
│ Repository Impl │
│  Data Mapping   │
└────────┬────────┘
         │ CRUD Operations
         ▼
┌─────────────────┐
│  Data Source    │
│   (Hive DB)     │
└─────────────────┘
```

### 🔄 Chi Tiết Flow Cho Từng Operation

#### **CREATE - Thêm Category Mới**

```
1. UI (add_edit_category_page.dart)
   ↓ User nhấn "Lưu"

2. Dispatch Event: AddCategory(category)
   ↓

3. CategoryBloc._onAddCategory()
   ↓ emit(CategoryActionInProgress)
   ↓ call addCategoryUseCase

4. AddCategoryUseCase.call(params)
   ↓ validate params
   ↓ call repository

5. CategoryManagementRepositoryImpl.addCategory()
   ↓ convert Entity → Model
   ↓ call localDataSource

6. DashboardLocalDataSource.addCategory()
   ↓ save to Hive box
   ↓ return success/failure

7. Back to Bloc
   ↓ emit(CategoryActionSuccess)
   ↓ trigger LoadCategories

8. UI updates
   ↓ show success message
   ↓ navigate back
```

#### **READ - Lấy Danh Sách**

```
1. UI (category_list_page.dart)
   ↓ initState or RefreshIndicator

2. Dispatch Event: LoadCategories()
   ↓

3. CategoryBloc._onLoadCategories()
   ↓ emit(CategoryLoading)
   ↓ call getAllCategoriesUseCase

4. GetAllCategoriesUseCase.call(NoParams)
   ↓ call repository

5. CategoryManagementRepositoryImpl.getAllCategories()
   ↓ call localDataSource
   ↓ convert List<Model> → List<Entity>

6. DashboardLocalDataSource.getAllCategories()
   ↓ fetch from Hive box
   ↓ return List<CategoryModel>

7. Back to Bloc
   ↓ emit(CategoryLoaded(categories))

8. UI rebuilds
   ↓ display list with ListView.builder
```

#### **UPDATE - Cập Nhật Category**

```
1. UI → Edit existing category
   ↓ pre-fill form với data hiện tại
   ↓ user chỉnh sửa
   ↓ nhấn "Cập nhật"

2. Dispatch Event: UpdateCategory(category)
   ↓

3. CategoryBloc._onUpdateCategory()
   ↓ emit(CategoryActionInProgress)
   ↓ call updateCategoryUseCase

4. UpdateCategoryUseCase.call(params)
   ↓ validate params
   ↓ call repository

5. CategoryManagementRepositoryImpl.updateCategory()
   ↓ convert Entity → Model
   ↓ call localDataSource.addCategory()
   ↓ (Hive overwrites nếu key giống nhau)

6. Back to Bloc
   ↓ emit(CategoryActionSuccess)
   ↓ trigger LoadCategories

7. UI updates
   ↓ show success message
   ↓ navigate back với cập nhật
```

#### **DELETE - Xóa Category**

```
1. UI → Swipe to delete hoặc Delete button
   ↓ show confirm dialog
   ↓ user confirm

2. Dispatch Event: DeleteCategory(id)
   ↓

3. CategoryBloc._onDeleteCategory()
   ↓ emit(CategoryActionInProgress)
   ↓ call deleteCategoryUseCase

4. DeleteCategoryUseCase.call(params)
   ↓ call repository

5. CategoryManagementRepositoryImpl.deleteCategory()
   ↓ fetch category từ Hive
   ↓ call model.delete() (Hive method)

6. Check if category in use
   ↓ isCategoryInUse(id)
   ↓ if YES → return failure

7. Back to Bloc
   ↓ if failure → emit(CategoryError)
   ↓ if success → emit(CategoryActionSuccess)
   ↓ trigger LoadCategories

8. UI updates
   ↓ show message
   ↓ refresh list
```

---

## 4. Presentation Layer

### 🎨 CategoryBloc

**File**: `lib/features/category/presentation/bloc/category_bloc.dart`

#### Dependencies

```dart
final GetAllCategoriesUseCase getAllCategoriesUseCase;
final AddCategoryUseCase addCategoryUseCase;
final UpdateCategoryUseCase updateCategoryUseCase;
final DeleteCategoryUseCase deleteCategoryUseCase;
```

#### Event Handlers

| Event Handler          | Mô Tả                  | States Emit                                                                             |
| ---------------------- | ---------------------- | --------------------------------------------------------------------------------------- |
| `_onLoadCategories`    | Load tất cả categories | `CategoryLoading` → `CategoryLoaded` hoặc `CategoryError`                               |
| `_onAddCategory`       | Thêm category mới      | `CategoryActionInProgress` → `CategoryActionSuccess` → `LoadCategories`                 |
| `_onUpdateCategory`    | Cập nhật category      | `CategoryActionInProgress` → `CategoryActionSuccess` → `LoadCategories`                 |
| `_onDeleteCategory`    | Xóa category           | `CategoryActionInProgress` → `CategoryActionSuccess`/`CategoryError` → `LoadCategories` |
| `_onRefreshCategories` | Refresh danh sách      | Trigger `LoadCategories`                                                                |

#### Đặc Điểm Quan Trọng

1. **State Preservation**: Khi có lỗi, Bloc restore lại `previousState` để UI không bị mất dữ liệu
2. **Auto Reload**: Sau mỗi action (add/update/delete), tự động trigger `LoadCategories` để refresh UI
3. **Error Handling**: Kiểm tra lỗi đặc biệt (ví dụ: xóa category đang được sử dụng)

### 📤 CategoryEvent

**File**: `lib/features/category/presentation/bloc/category_event.dart`

```dart
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

/// Load tất cả categories
class LoadCategories extends CategoryEvent {
  const LoadCategories();
}

/// Thêm category mới
class AddCategory extends CategoryEvent {
  final CategoryEntity category;

  const AddCategory({required this.category});

  @override
  List<Object?> get props => [category];
}

/// Cập nhật category
class UpdateCategory extends CategoryEvent {
  final CategoryEntity category;

  const UpdateCategory({required this.category});

  @override
  List<Object?> get props => [category];
}

/// Xóa category
class DeleteCategory extends CategoryEvent {
  final String id;

  const DeleteCategory({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Refresh danh sách
class RefreshCategories extends CategoryEvent {
  const RefreshCategories();
}
```

#### Tại Sao Dùng Equatable?

- So sánh event dựa trên `props` thay vì reference
- Giúp Bloc phát hiện event trùng lặp
- Tối ưu performance

### 📥 CategoryState

**File**: `lib/features/category/presentation/bloc/category_state.dart`

```dart
abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

/// State ban đầu
class CategoryInitial extends CategoryState {}

/// Đang load dữ liệu
class CategoryLoading extends CategoryState {}

/// Load thành công với danh sách
class CategoryLoaded extends CategoryState {
  final List<CategoryEntity> categories;

  const CategoryLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

/// Đang thực hiện action (add/update/delete)
class CategoryActionInProgress extends CategoryState {}

/// Action thành công
class CategoryActionSuccess extends CategoryState {
  final String message;

  const CategoryActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Có lỗi
class CategoryError extends CategoryState {
  final String message;

  const CategoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
```

#### State Transition Diagram

```
CategoryInitial
    │
    ├─→ CategoryLoading ──→ CategoryLoaded (success)
    │                   └──→ CategoryError (failure)
    │
    └─→ CategoryActionInProgress ──→ CategoryActionSuccess ──→ CategoryLoading
                                 └──→ CategoryError ──→ CategoryLoaded (restore)
```

### 🖼️ UI Components

#### **CategoryListPage** - Danh Sách Nhóm

**Chức năng**:

- Hiển thị danh sách categories
- Pull-to-refresh
- Navigate đến Add/Edit page
- Delete với confirmation

**Key Features**:

```dart
BlocBuilder<CategoryBloc, CategoryState>(
  builder: (context, state) {
    if (state is CategoryLoading) {
      return CircularProgressIndicator();
    }
    if (state is CategoryLoaded) {
      return ListView.builder(...);
    }
    if (state is CategoryError) {
      return ErrorWidget();
    }
  },
)
```

#### **AddEditCategoryPage** - Form Thêm/Sửa

**Chức năng**:

- Form validation
- Icon picker (Font Awesome)
- Color picker
- Type selector (Income/Expense/Both)
- Preview card
- Save/Update action

**Key Features**:

```dart
// Form validation
if (_formKey.currentState!.validate()) {
  final category = CategoryEntity(
    id: isEditing ? widget.category!.id : DateTime.now().toString(),
    name: _nameController.text.trim(),
    icon: _selectedIcon!,
    color: _selectedColor,
    type: _selectedType,
  );

  context.read<CategoryBloc>().add(
    isEditing
      ? UpdateCategory(category: category)
      : AddCategory(category: category)
  );
}
```

#### **IconPickerDialog** - Chọn Icon

**Chức năng**:

- Hiển thị grid của Font Awesome icons
- Search/filter icons
- Preview icon với màu đã chọn
- Return selected icon

**Implementation**:

```dart
final selectedIcon = await showDialog<IconData>(
  context: context,
  builder: (context) => IconPickerDialog(
    currentColor: _selectedColor,
  ),
);

if (selectedIcon != null) {
  setState(() {
    _selectedIcon = selectedIcon;
  });
}
```

#### **ColorPickerDialog** - Chọn Màu

**Chức năng**:

- Hiển thị bảng màu predefined
- Preview màu với icon đã chọn
- Return selected color

---

## 5. Domain Layer

### 🏛️ CategoryEntity

**File**: `lib/features/dashboard/domain/entities/category_entity.dart`

```dart
class CategoryEntity extends Equatable {
  final String id;                          // Unique ID
  final String name;                        // Tên nhóm (VD: "Ăn uống", "Lương")
  final IconData icon;                      // Icon (Font Awesome)
  final Color color;                        // Màu đại diện
  final TransactionCategoryType type;       // Loại: income/expense/both

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, icon, color, type];
}

enum TransactionCategoryType {
  income,   // Thu nhập
  expense,  // Chi tiêu
  both,     // Cả hai
}
```

#### Tại Sao Là Entity?

- **Pure Dart Object**: Không phụ thuộc vào Flutter hay bất kỳ framework nào
- **Immutable**: Tất cả fields là `final`
- **Equatable**: So sánh dựa trên giá trị, không phải reference
- **Business Logic Layer**: Đại diện cho business object trong app

### 🔌 Repository Interface

**File**: `lib/features/category/domain/repositories/category_management_repository.dart`

```dart
abstract class CategoryManagementRepository {
  /// Lấy tất cả categories
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories();

  /// Lấy categories theo type (income/expense/both)
  Future<Either<Failure, List<CategoryEntity>>> getCategoriesByType(
    TransactionCategoryType type,
  );

  /// Lấy một category theo ID
  Future<Either<Failure, CategoryEntity>> getCategoryById(String id);

  /// Thêm category mới
  Future<Either<Failure, void>> addCategory(CategoryEntity category);

  /// Cập nhật category
  Future<Either<Failure, void>> updateCategory(CategoryEntity category);

  /// Xóa category
  Future<Either<Failure, void>> deleteCategory(String id);

  /// Kiểm tra xem category có đang được sử dụng không
  Future<Either<Failure, bool>> isCategoryInUse(String id);
}
```

#### Tại Sao Dùng `Either<Failure, T>`?

- **Functional Programming**: Xử lý kết quả thành công hoặc thất bại một cách rõ ràng
- **Type-Safe Error Handling**: Không cần try-catch, compile-time safety
- **Left = Failure, Right = Success**

### 🎯 UseCases

#### **GetAllCategoriesUseCase**

```dart
class GetAllCategoriesUseCase
    implements UseCase<List<CategoryEntity>, NoParams> {
  final CategoryManagementRepository repository;

  GetAllCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) async {
    return await repository.getAllCategories();
  }
}
```

**Mục đích**: Lấy tất cả categories từ repository

**Params**: `NoParams` (không cần tham số)

**Returns**: `Either<Failure, List<CategoryEntity>>`

---

#### **AddCategoryUseCase**

```dart
class AddCategoryUseCase implements UseCase<void, AddCategoryParams> {
  final CategoryManagementRepository repository;

  AddCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddCategoryParams params) async {
    return await repository.addCategory(params.category);
  }
}

class AddCategoryParams extends Equatable {
  final CategoryEntity category;

  const AddCategoryParams({required this.category});

  @override
  List<Object?> get props => [category];
}
```

**Mục đích**: Thêm category mới

**Params**: `AddCategoryParams` chứa `CategoryEntity`

**Returns**: `Either<Failure, void>`

**Business Rules**:

- Validate tên category không trống
- Validate icon đã được chọn
- ID phải unique (timestamp hoặc UUID)

---

#### **UpdateCategoryUseCase**

```dart
class UpdateCategoryUseCase implements UseCase<void, UpdateCategoryParams> {
  final CategoryManagementRepository repository;

  UpdateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateCategoryParams params) async {
    return await repository.updateCategory(params.category);
  }
}

class UpdateCategoryParams extends Equatable {
  final CategoryEntity category;

  const UpdateCategoryParams({required this.category});

  @override
  List<Object?> get props => [category];
}
```

**Mục đích**: Cập nhật category hiện có

**Params**: `UpdateCategoryParams` chứa `CategoryEntity` với ID đã tồn tại

**Returns**: `Either<Failure, void>`

---

#### **DeleteCategoryUseCase**

```dart
class DeleteCategoryUseCase implements UseCase<void, DeleteCategoryParams> {
  final CategoryManagementRepository repository;

  DeleteCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCategoryParams params) async {
    // Kiểm tra xem category có đang được sử dụng không
    final inUseResult = await repository.isCategoryInUse(params.id);

    return inUseResult.fold(
      (failure) => Left(failure),
      (isInUse) {
        if (isInUse) {
          return Left(CacheFailure(
            message: 'Category đang được sử dụng, không thể xóa'
          ));
        }
        return repository.deleteCategory(params.id);
      },
    );
  }
}

class DeleteCategoryParams extends Equatable {
  final String id;

  const DeleteCategoryParams({required this.id});

  @override
  List<Object?> get props => [id];
}
```

**Mục đích**: Xóa category

**Params**: `DeleteCategoryParams` chứa ID của category

**Returns**: `Either<Failure, void>`

**Business Rules**:

- Kiểm tra category có đang được sử dụng trong transactions không
- Nếu có → return Failure
- Nếu không → proceed delete

---

### 🎯 Tại Sao Cần UseCase?

1. **Single Responsibility**: Mỗi UseCase thực hiện một nhiệm vụ duy nhất
2. **Testable**: Dễ dàng test business logic độc lập
3. **Reusable**: Có thể tái sử dụng ở nhiều nơi (Bloc, Service, etc.)
4. **Business Logic Centralization**: Tập trung business rules ở một chỗ
5. **Clean Architecture Compliance**: Tuân thủ nguyên tắc Dependency Inversion

---

## 6. Data Layer

### 💾 Repository Implementation

**File**: `lib/features/category/data/repositories/category_management_repository_impl.dart`

```dart
class CategoryManagementRepositoryImpl implements CategoryManagementRepository {
  final DashboardLocalDataSource localDataSource;

  CategoryManagementRepositoryImpl({required this.localDataSource});

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

  @override
  Future<Either<Failure, void>> addCategory(CategoryEntity category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await localDataSource.addCategory(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(CategoryEntity category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await localDataSource.addCategory(model); // Hive overwrites if key exists
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      final models = await localDataSource.getAllCategories();
      final model = models.firstWhere((m) => m.id == id);
      await model.delete(); // Hive HiveObject method
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isCategoryInUse(String id) async {
    try {
      final transactions = await localDataSource.getAllTransactions();
      final isInUse = transactions.any((t) => t.categoryId == id);
      return Right(isInUse);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
```

#### Vai Trò

1. **Implement Interface**: Thực thi các method từ `CategoryManagementRepository`
2. **Data Mapping**: Chuyển đổi giữa `Model` (Hive) và `Entity` (Domain)
3. **Error Handling**: Wrap try-catch và return `Either<Failure, T>`
4. **Data Source Access**: Gọi `DashboardLocalDataSource` để thao tác với Hive

### 🗄️ Data Source (Hive)

**File**: `lib/features/dashboard/data/datasources/dashboard_local_data_source.dart`

```dart
abstract class DashboardLocalDataSource {
  Future<List<CategoryModel>> getAllCategories();
  Future<void> addCategory(CategoryModel category);
  Future<List<TransactionModel>> getAllTransactions();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final Box<CategoryModel> categoryBox;
  final Box<TransactionModel> transactionBox;

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    return categoryBox.values.toList();
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await categoryBox.put(category.id, category);
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    return transactionBox.values.toList();
  }
}
```

#### Hive Operations

- **Read**: `categoryBox.values.toList()`
- **Create/Update**: `categoryBox.put(key, value)` (put = upsert)
- **Delete**: `model.delete()` (HiveObject method)
- **Query**: Dart collection methods (`.where()`, `.any()`, etc.)

### 🔄 Model ↔ Entity Conversion

```dart
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int iconCodePoint;

  @HiveField(3)
  final int colorValue;

  @HiveField(4)
  final String type; // "income", "expense", "both"

  // Convert to Entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      icon: IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
      color: Color(colorValue),
      type: _stringToType(type),
    );
  }

  // Create from Entity
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      iconCodePoint: entity.icon.codePoint,
      colorValue: entity.color.value,
      type: _typeToString(entity.type),
    );
  }
}
```

#### Tại Sao Cần Model?

- **Hive Serialization**: Hive chỉ lưu primitive types, cần serialize `IconData`, `Color`, `Enum`
- **Separation of Concerns**: Domain layer không biết về Hive
- **Flexibility**: Có thể thay đổi storage mechanism mà không ảnh hưởng domain

---

## 7. Ví Dụ Chi Tiết: Thêm Category Mới

### 📝 Scenario: User Muốn Thêm Nhóm "Ăn Uống"

#### **Bước 1: User Navigate Đến Add Category Page**

```dart
// category_list_page.dart
FloatingActionButton(
  onPressed: () async {
    final result = await context.push('/category/add');
    if (result == true) {
      // Refresh list
      context.read<CategoryBloc>().add(const RefreshCategories());
    }
  },
  child: Icon(Icons.add),
)
```

**State**: `CategoryLoaded` (đang hiển thị list)

---

#### **Bước 2: User Fill Form**

```dart
// add_edit_category_page.dart

// User nhập tên
_nameController.text = "Ăn uống";

// User chọn icon
setState(() {
  _selectedIcon = Icons.restaurant; // Font Awesome icon
});

// User chọn màu
setState(() {
  _selectedColor = Colors.orange;
});

// User chọn loại
setState(() {
  _selectedType = TransactionCategoryType.expense;
});
```

**UI Update**: Preview card hiển thị icon màu cam với text "Ăn uống"

---

#### **Bước 3: User Nhấn "Lưu"**

```dart
void _handleSave() {
  if (_formKey.currentState!.validate()) {
    if (_selectedIcon == null) {
      // Show error: "Vui lòng chọn icon"
      return;
    }

    final category = CategoryEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      icon: _selectedIcon!,
      color: _selectedColor,
      type: _selectedType,
    );

    // Dispatch event
    context.read<CategoryBloc>().add(
      AddCategory(category: category)
    );
  }
}
```

**Event Dispatched**: `AddCategory(category)`

---

#### **Bước 4: Bloc Xử Lý Event**

```dart
// category_bloc.dart

Future<void> _onAddCategory(
  AddCategory event,
  Emitter<CategoryState> emit,
) async {
  // 1. Lưu state cũ để restore nếu có lỗi
  final previousState = state;

  // 2. Emit loading state
  emit(CategoryActionInProgress());

  // 3. Call UseCase
  final result = await addCategoryUseCase(
    AddCategoryParams(category: event.category),
  );

  // 4. Handle result
  result.fold(
    // Left = Failure
    (failure) {
      emit(const CategoryError(message: 'Không thể thêm nhóm'));
      // Restore previous state
      if (previousState is CategoryLoaded) {
        emit(previousState);
      }
    },
    // Right = Success
    (_) {
      emit(const CategoryActionSuccess(message: 'Thêm nhóm thành công'));
      // Reload categories
      add(const LoadCategories());
    },
  );
}
```

**State Transitions**:

1. `CategoryLoaded` (initial)
2. `CategoryActionInProgress` (loading)
3. `CategoryActionSuccess` (success)
4. `CategoryLoading` (reload)
5. `CategoryLoaded` (new list with added category)

---

#### **Bước 5: UseCase Execute**

```dart
// add_category_usecase.dart

@override
Future<Either<Failure, void>> call(AddCategoryParams params) async {
  // Business logic validation có thể thêm ở đây

  // Call repository
  return await repository.addCategory(params.category);
}
```

**Flow**: UseCase → Repository Interface

---

#### **Bước 6: Repository Implementation**

```dart
// category_management_repository_impl.dart

@override
Future<Either<Failure, void>> addCategory(CategoryEntity category) async {
  try {
    // 1. Convert Entity → Model
    final model = CategoryModel.fromEntity(category);

    // 2. Save to data source
    await localDataSource.addCategory(model);

    // 3. Return success
    return const Right(null);
  } catch (e) {
    // 4. Return failure if error
    return Left(CacheFailure(message: e.toString()));
  }
}
```

**Data Mapping**:

```dart
CategoryEntity(
  id: "1704067200000",
  name: "Ăn uống",
  icon: IconData(0xe56c, fontFamily: 'MaterialIcons'),
  color: Color(0xFFFF9800),
  type: TransactionCategoryType.expense,
)

↓ Convert ↓

CategoryModel(
  id: "1704067200000",
  name: "Ăn uống",
  iconCodePoint: 0xe56c,
  colorValue: 0xFFFF9800,
  type: "expense",
)
```

---

#### **Bước 7: Data Source Lưu Vào Hive**

```dart
// dashboard_local_data_source.dart

@override
Future<void> addCategory(CategoryModel category) async {
  // Lưu vào Hive box với key = category.id
  await categoryBox.put(category.id, category);
}
```

**Hive Storage**:

```
categoryBox:
  ├─ "1704067200000" → CategoryModel(name: "Ăn uống", ...)
  ├─ "1704067201000" → CategoryModel(name: "Lương", ...)
  └─ ...
```

---

#### **Bước 8: Success → Reload Categories**

Sau khi lưu thành công, Bloc tự động dispatch `LoadCategories()` event:

```dart
// category_bloc.dart

Future<void> _onLoadCategories(
  LoadCategories event,
  Emitter<CategoryState> emit,
) async {
  emit(CategoryLoading());

  final result = await getAllCategoriesUseCase(NoParams());

  result.fold(
    (failure) => emit(const CategoryError(message: 'Không thể tải danh sách nhóm')),
    (categories) => emit(CategoryLoaded(categories: categories)),
  );
}
```

**Result**: Danh sách categories mới (bao gồm "Ăn uống") được load và emit

---

#### **Bước 9: UI Update**

```dart
// add_edit_category_page.dart

BlocConsumer<CategoryBloc, CategoryState>(
  listener: (context, state) {
    if (state is CategoryActionSuccess) {
      // Navigate back với result = true
      context.pop(true);

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    } else if (state is CategoryError) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  builder: (context, state) {
    final isLoading = state is CategoryActionInProgress;

    return ElevatedButton(
      onPressed: isLoading ? null : _handleSave,
      child: isLoading
        ? CircularProgressIndicator()
        : Text('Lưu'),
    );
  },
)
```

**User Experience**:

1. Button disabled + loading indicator (khi saving)
2. Success snackbar: "Thêm nhóm thành công"
3. Navigate back to list page
4. List refreshed với nhóm "Ăn uống" mới

---

#### **Bước 10: List Page Refresh**

```dart
// category_list_page.dart

BlocBuilder<CategoryBloc, CategoryState>(
  builder: (context, state) {
    if (state is CategoryLoaded) {
      return ListView.builder(
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: category.color,
              child: Icon(category.icon, color: Colors.white),
            ),
            title: Text(category.name),
            subtitle: Text(_getTypeText(category.type)),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _confirmDelete(category.id),
            ),
            onTap: () => _navigateToEdit(category),
          );
        },
      );
    }

    return Center(child: CircularProgressIndicator());
  },
)
```

**Final Result**: Danh sách hiển thị nhóm "Ăn uống" với icon 🍴 màu cam

---

## 8. Sơ Đồ Quan Hệ

### 🏗️ Architecture Layers

```
┌─────────────────────────────────────────────────────┐
│              PRESENTATION LAYER                     │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────┐  │
│  │   Widgets   │→ │  Bloc/State  │→ │   Events  │  │
│  │    Pages    │  │   Manager    │  │  Actions  │  │
│  └─────────────┘  └──────────────┘  └───────────┘  │
└────────────────────────┬────────────────────────────┘
                         │ Dispatch Events
                         ↓
┌─────────────────────────────────────────────────────┐
│                DOMAIN LAYER                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │
│  │   UseCases   │→ │  Repository  │  │ Entities │  │
│  │ (Bus. Logic) │  │  (Interface) │  │  (Pure)  │  │
│  └──────────────┘  └──────────────┘  └──────────┘  │
└────────────────────────┬────────────────────────────┘
                         │ Call Repository
                         ↓
┌─────────────────────────────────────────────────────┐
│                 DATA LAYER                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │
│  │  Repository  │→ │ Data Source  │→ │  Hive DB │  │
│  │     Impl     │  │  (Local DB)  │  │ (Storage)│  │
│  └──────────────┘  └──────────────┘  └──────────┘  │
└─────────────────────────────────────────────────────┘
```

### 🔄 Complete Data Flow

```
User Action (Tap "Lưu")
         │
         ↓
┌─────────────────────┐
│  UI (Widget)        │  _handleSave()
│  validates form     │
└──────────┬──────────┘
           │ create CategoryEntity
           ↓
┌─────────────────────┐
│  Dispatch Event     │  AddCategory(category)
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│  CategoryBloc       │  _onAddCategory()
│  - save state       │
│  - emit(Loading)    │
└──────────┬──────────┘
           │ call UseCase
           ↓
┌─────────────────────┐
│  AddCategoryUseCase │  call(params)
└──────────┬──────────┘
           │ call repository
           ↓
┌─────────────────────┐
│  Repository Impl    │  addCategory(entity)
│  - Entity → Model   │
└──────────┬──────────┘
           │ save to data source
           ↓
┌─────────────────────┐
│  Local Data Source  │  addCategory(model)
│  - categoryBox.put()│
└──────────┬──────────┘
           │ Hive storage
           ↓
┌─────────────────────┐
│  Hive Database      │  Persisted
└──────────┬──────────┘
           │ return success
           ↓
[Flow ngược lại qua các layers]
           ↓
┌─────────────────────┐
│  Bloc               │  emit(Success)
│                     │  → dispatch LoadCategories
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│  UI Updates         │  - Show snackbar
│                     │  - Navigate back
│                     │  - Refresh list
└─────────────────────┘
```

### 📦 Dependency Injection

```dart
// app_binding.dart hoặc main.dart

// Data Layer
Get.lazyPut(() => DashboardLocalDataSourceImpl(
  categoryBox: Hive.box<CategoryModel>('categories'),
  transactionBox: Hive.box<TransactionModel>('transactions'),
));

// Repository
Get.lazyPut<CategoryManagementRepository>(
  () => CategoryManagementRepositoryImpl(
    localDataSource: Get.find<DashboardLocalDataSource>(),
  ),
);

// UseCases
Get.lazyPut(() => GetAllCategoriesUseCase(Get.find()));
Get.lazyPut(() => AddCategoryUseCase(Get.find()));
Get.lazyPut(() => UpdateCategoryUseCase(Get.find()));
Get.lazyPut(() => DeleteCategoryUseCase(Get.find()));

// Bloc
Get.lazyPut(() => CategoryBloc(
  getAllCategoriesUseCase: Get.find(),
  addCategoryUseCase: Get.find(),
  updateCategoryUseCase: Get.find(),
  deleteCategoryUseCase: Get.find(),
));
```

---

## 🎯 Tổng Kết

### ✅ Clean Architecture Benefits

1. **Separation of Concerns**: Mỗi layer có trách nhiệm riêng biệt
2. **Testability**: Có thể test từng layer độc lập
3. **Scalability**: Dễ dàng thêm features mới mà không ảnh hưởng code cũ
4. **Maintainability**: Code rõ ràng, dễ maintain và debug
5. **Flexibility**: Có thể thay đổi implementation (VD: Hive → SQLite) mà không ảnh hưởng business logic

### 📚 Key Principles

- **Dependency Rule**: Dependencies luôn point inward (UI → Domain ← Data)
- **Entities**: Business objects, framework-independent
- **UseCases**: Orchestrate flow of data, contain business rules
- **Interface Adapters**: Convert data between external and internal formats
- **Frameworks**: External tools (Flutter, Hive) ở layer ngoài cùng

### 🚀 Best Practices

1. **Always use Repository pattern**: Abstraction over data sources
2. **UseCase per action**: Mỗi UseCase = 1 business operation
3. **Immutable Entities**: Sử dụng `final` fields và `Equatable`
4. **Error Handling with Either**: Type-safe error handling
5. **State Management with BLoC**: Predictable state transitions
6. **Dependency Injection**: Loose coupling giữa các components

---

## 📖 Tài Liệu Tham Khảo

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter BLoC Library](https://bloclibrary.dev/)
- [Dartz - Functional Programming in Dart](https://pub.dev/packages/dartz)
- [Hive - Fast, Lightweight Local Storage](https://docs.hivedb.dev/)

---

**📅 Last Updated**: October 31, 2025  
**👨‍💻 Author**: Development Team  
**📧 Contact**: [Your Contact Info]
