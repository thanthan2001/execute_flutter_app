import 'package:hive/hive.dart';
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

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  static const String categoryBoxName = 'categories';

  Box<CategoryModel>? _categoryBox;

  /// Khởi tạo và mở box
  Future<void> init() async {
    _categoryBox = await Hive.openBox<CategoryModel>(categoryBoxName);
  }

  Box<CategoryModel> get _categories {
    if (_categoryBox == null || !_categoryBox!.isOpen) {
      throw Exception('Category box is not initialized');
    }
    return _categoryBox!;
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    return _categories.values.toList();
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await _categories.put(category.id, category);
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await _categories.put(category.id, category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _categories.delete(id);
  }

  @override
  Future<void> clearAllCategories() async {
    await _categories.clear();
  }
}
