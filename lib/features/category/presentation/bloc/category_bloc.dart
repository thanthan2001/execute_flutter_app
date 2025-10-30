import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/get_all_categories_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';
import 'category_event.dart';
import 'category_state.dart';

/// Bloc quản lý state của Category Management
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetAllCategoriesUseCase getAllCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  CategoryBloc({
    required this.getAllCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<RefreshCategories>(_onRefreshCategories);
  }

  /// Xử lý event LoadCategories
  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await getAllCategoriesUseCase(NoParams());

    result.fold(
      (failure) =>
          emit(const CategoryError(message: 'Không thể tải danh sách nhóm')),
      (categories) => emit(CategoryLoaded(categories: categories)),
    );
  }

  /// Xử lý event AddCategory
  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    final previousState = state;
    emit(CategoryActionInProgress());

    final result = await addCategoryUseCase(
      AddCategoryParams(category: event.category),
    );

    result.fold(
      (failure) {
        emit(const CategoryError(message: 'Không thể thêm nhóm'));
        if (previousState is CategoryLoaded) {
          emit(previousState);
        }
      },
      (_) {
        emit(const CategoryActionSuccess(message: 'Thêm nhóm thành công'));
        add(const LoadCategories());
      },
    );
  }

  /// Xử lý event UpdateCategory
  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    final previousState = state;
    emit(CategoryActionInProgress());

    final result = await updateCategoryUseCase(
      UpdateCategoryParams(category: event.category),
    );

    result.fold(
      (failure) {
        emit(const CategoryError(message: 'Không thể cập nhật nhóm'));
        if (previousState is CategoryLoaded) {
          emit(previousState);
        }
      },
      (_) {
        emit(const CategoryActionSuccess(message: 'Cập nhật nhóm thành công'));
        add(const LoadCategories());
      },
    );
  }

  /// Xử lý event DeleteCategory
  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    final previousState = state;
    emit(CategoryActionInProgress());

    final result = await deleteCategoryUseCase(
      DeleteCategoryParams(id: event.id),
    );

    result.fold(
      (failure) {
        emit(CategoryError(
            message: failure.toString().contains('đang được sử dụng')
                ? 'Không thể xóa nhóm đang được sử dụng'
                : 'Không thể xóa nhóm'));
        if (previousState is CategoryLoaded) {
          emit(previousState);
        }
      },
      (_) {
        emit(const CategoryActionSuccess(message: 'Xóa nhóm thành công'));
        add(const LoadCategories());
      },
    );
  }

  /// Xử lý event RefreshCategories
  Future<void> _onRefreshCategories(
    RefreshCategories event,
    Emitter<CategoryState> emit,
  ) async {
    add(const LoadCategories());
  }
}
