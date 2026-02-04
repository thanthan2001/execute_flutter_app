import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recurring_transaction_entity.dart';

/// Repository interface cho Recurring Transactions
abstract class RecurringTransactionRepository {
  /// Tạo recurring transaction mới
  Future<Either<Failure, void>> createRecurring(
    RecurringTransactionEntity recurring,
  );

  /// Cập nhật recurring transaction
  Future<Either<Failure, void>> updateRecurring(
    RecurringTransactionEntity recurring,
  );

  /// Lấy tất cả recurring transactions
  Future<Either<Failure, List<RecurringTransactionEntity>>>
      getAllRecurring();

  /// Lấy các recurring transactions đang active
  Future<Either<Failure, List<RecurringTransactionEntity>>>
      getActiveRecurring();

  /// Lấy recurring transaction theo ID
  Future<Either<Failure, RecurringTransactionEntity?>> getRecurringById(
    String id,
  );

  /// Deactivate recurring transaction (pause)
  Future<Either<Failure, void>> deactivateRecurring(String id);

  /// Activate recurring transaction (resume)
  Future<Either<Failure, void>> activateRecurring(String id);

  /// Xóa recurring transaction
  Future<Either<Failure, void>> deleteRecurring(String id);

  /// Lấy các recurring transactions cần generate (đến hạn)
  Future<Either<Failure, List<RecurringTransactionEntity>>>
      getPendingRecurring();
}
