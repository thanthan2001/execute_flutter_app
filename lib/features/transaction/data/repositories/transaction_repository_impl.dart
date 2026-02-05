import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../datasources/transaction_local_data_source.dart';
import '../models/transaction_model.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/repositories/category_management_repository.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

/// Implementation của TransactionRepository
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  final CategoryManagementRepository categoryRepository;

  TransactionRepositoryImpl({
    required this.localDataSource,
    required this.categoryRepository,
  });

  @override
  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions() async {
    try {
      final models = await localDataSource.getAllTransactions();
      final entities = models.map((model) => model.toEntity()).toList();
      // Sắp xếp theo ngày mới nhất
      entities.sort((a, b) => b.date.compareTo(a.date));
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByType(
    TransactionType type,
  ) async {
    try {
      final models = await localDataSource.getAllTransactions();
      final filtered = models.where((model) {
        return model.type ==
            (type == TransactionType.income ? 'income' : 'expense');
      }).toList();
      final entities = filtered.map((model) => model.toEntity()).toList();
      // Sắp xếp theo ngày mới nhất
      entities.sort((a, b) => b.date.compareTo(a.date));
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransactionById(
      String id) async {
    try {
      final models = await localDataSource.getAllTransactions();
      final model = models.firstWhere((m) => m.id == id);
      return Right(model.toEntity());
    } catch (e) {
      return const Left(CacheFailure(message: 'Transaction not found'));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
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
  Future<Either<Failure, void>> clearAllTransactions() async {
    try {
      await localDataSource.clearAllTransactions();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories() async {
    return await categoryRepository.getAllCategories();
  }
}
