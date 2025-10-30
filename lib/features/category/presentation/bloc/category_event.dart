import 'package:equatable/equatable.dart';
import '../../../dashboard/domain/entities/category_entity.dart';

/// Abstract event cho Category Management
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

/// Event load tất cả categories
class LoadCategories extends CategoryEvent {
  const LoadCategories();
}

/// Event thêm category mới
class AddCategory extends CategoryEvent {
  final CategoryEntity category;

  const AddCategory({required this.category});

  @override
  List<Object?> get props => [category];
}

/// Event cập nhật category
class UpdateCategory extends CategoryEvent {
  final CategoryEntity category;

  const UpdateCategory({required this.category});

  @override
  List<Object?> get props => [category];
}

/// Event xóa category
class DeleteCategory extends CategoryEvent {
  final String id;

  const DeleteCategory({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event refresh danh sách categories
class RefreshCategories extends CategoryEvent {
  const RefreshCategories();
}
