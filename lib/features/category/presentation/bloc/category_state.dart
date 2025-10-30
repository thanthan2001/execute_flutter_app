import 'package:equatable/equatable.dart';
import '../../../dashboard/domain/entities/category_entity.dart';

/// Abstract state cho Category Management
abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

/// State ban đầu
class CategoryInitial extends CategoryState {}

/// State đang load dữ liệu
class CategoryLoading extends CategoryState {}

/// State load thành công với danh sách categories
class CategoryLoaded extends CategoryState {
  final List<CategoryEntity> categories;

  const CategoryLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];

  CategoryLoaded copyWith({List<CategoryEntity>? categories}) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
    );
  }
}

/// State khi đang thực hiện action (add/update/delete)
class CategoryActionInProgress extends CategoryState {}

/// State khi action thành công
class CategoryActionSuccess extends CategoryState {
  final String message;

  const CategoryActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State khi có lỗi
class CategoryError extends CategoryState {
  final String message;

  const CategoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
