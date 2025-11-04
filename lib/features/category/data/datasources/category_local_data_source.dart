import '../models/category_model.dart';

/// Local Data Source cho Category sử dụng Hive
abstract class CategoryLocalDataSource {
  /// Lấy tất cả danh mục
  Future<List<CategoryModel>> getAllCategories();

  /// Thêm danh mục
  Future<void> addCategory(CategoryModel category);

  /// Cập nhật danh mục
  Future<void> updateCategory(CategoryModel category);

  /// Xóa danh mục
  Future<void> deleteCategory(String id);

  /// Xóa tất cả danh mục (migration/testing)
  Future<void> clearAllCategories();
}
