import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';

/// Repository interface cho Category Management
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
