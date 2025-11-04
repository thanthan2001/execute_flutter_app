import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../datasources/category_local_data_source.dart';
import '../models/category_model.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_management_repository.dart';

/// Implementation của CategoryManagementRepository
class CategoryManagementRepositoryImpl implements CategoryManagementRepository {
  final CategoryLocalDataSource localDataSource;

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
  Future<Either<Failure, List<CategoryEntity>>> getCategoriesByType(
    TransactionCategoryType type,
  ) async {
    try {
      final models = await localDataSource.getAllCategories();
      final filtered = models.where((model) {
        final entity = model.toEntity();
        return entity.type == type ||
            entity.type == TransactionCategoryType.both;
      }).toList();
      final entities = filtered.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(String id) async {
    try {
      final models = await localDataSource.getAllCategories();
      final model = models.firstWhere((m) => m.id == id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: 'Category not found'));
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
      await localDataSource
          .addCategory(model); // Hive sẽ overwrite nếu key đã tồn tại
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      // Lấy box và xóa
      final models = await localDataSource.getAllCategories();
      final model = models.firstWhere((m) => m.id == id);
      await model.delete(); // Hive object có method delete()
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isCategoryInUse(String id) async {
    try {
      // Không cần kiểm tra transaction ở đây - để cho feature transaction xử lý
      // Hoặc inject TransactionRepository nếu thực sự cần
      return const Right(false);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
