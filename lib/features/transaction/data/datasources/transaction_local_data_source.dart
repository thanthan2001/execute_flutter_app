import '../models/transaction_model.dart';

/// Local Data Source cho Transaction sử dụng Hive
abstract class TransactionLocalDataSource {
  /// Lấy tất cả giao dịch
  Future<List<TransactionModel>> getAllTransactions();

  /// Lấy giao dịch theo khoảng thời gian
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Thêm giao dịch
  Future<void> addTransaction(TransactionModel transaction);

  /// Cập nhật giao dịch
  Future<void> updateTransaction(TransactionModel transaction);

  /// Xóa giao dịch
  Future<void> deleteTransaction(String id);

  /// Xóa tất cả giao dịch (migration/testing)
  Future<void> clearAllTransactions();
}
