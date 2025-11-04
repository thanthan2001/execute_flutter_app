import 'package:hive/hive.dart';
import '../models/transaction_model.dart';
import 'transaction_local_data_source.dart';

/// Implementation của TransactionLocalDataSource sử dụng Hive
class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  static const String transactionBoxName = 'transactions';

  Box<TransactionModel>? _transactionBox;

  /// Khởi tạo và mở box
  Future<void> init() async {
    _transactionBox = await Hive.openBox<TransactionModel>(transactionBoxName);
  }

  Box<TransactionModel> get _transactions {
    if (_transactionBox == null || !_transactionBox!.isOpen) {
      throw Exception('Transaction box is not initialized');
    }
    return _transactionBox!;
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    return _transactions.values.toList();
  }

  @override
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allTransactions = _transactions.values.toList();
    return allTransactions.where((transaction) {
      // So sánh chính xác: >= startDate AND <= endDate
      return !transaction.date.isBefore(startDate) &&
          !transaction.date.isAfter(endDate);
    }).toList();
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactions.put(transaction.id, transaction);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactions.put(transaction.id, transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _transactions.delete(id);
  }

  @override
  Future<void> clearAllTransactions() async {
    await _transactions.clear();
  }
}
