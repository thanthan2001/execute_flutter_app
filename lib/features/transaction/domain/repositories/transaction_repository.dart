import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../../../dashboard/domain/entities/category_entity.dart';

/// Repository interface cho Transaction CRUD operations
abstract class TransactionRepository {
  /// Lấy tất cả giao dịch
  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions();

  /// Lấy giao dịch theo loại (thu/chi)
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByType(
    TransactionType type,
  );

  /// Lấy một giao dịch theo ID
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id);

  /// Thêm giao dịch mới
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction);

  /// Cập nhật giao dịch
  Future<Either<Failure, void>> updateTransaction(
      TransactionEntity transaction);

  /// Xóa giao dịch
  Future<Either<Failure, void>> deleteTransaction(String id);

  /// Lấy tất cả categories để chọn
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories();
}
