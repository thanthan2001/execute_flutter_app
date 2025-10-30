import 'package:hive/hive.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

/// Local Data Source sử dụng Hive để lưu trữ dữ liệu
abstract class DashboardLocalDataSource {
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

  /// Lấy tất cả danh mục
  Future<List<CategoryModel>> getAllCategories();

  /// Thêm danh mục
  Future<void> addCategory(CategoryModel category);

  /// Cập nhật danh mục
  Future<void> updateCategory(CategoryModel category);

  /// Xóa danh mục
  Future<void> deleteCategory(String id);

  /// Xóa tất cả giao dịch (migration/testing)
  Future<void> clearAllTransactions();

  /// Xóa tất cả danh mục (migration/testing)
  Future<void> clearAllCategories();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  static const String transactionBoxName = 'transactions';
  static const String categoryBoxName = 'categories';

  Box<TransactionModel>? _transactionBox;
  Box<CategoryModel>? _categoryBox;

  /// Khởi tạo và mở các box
  Future<void> init() async {
    _transactionBox = await Hive.openBox<TransactionModel>(transactionBoxName);
    _categoryBox = await Hive.openBox<CategoryModel>(categoryBoxName);
  }

  Box<TransactionModel> get _transactions {
    if (_transactionBox == null || !_transactionBox!.isOpen) {
      throw Exception('Transaction box is not initialized');
    }
    return _transactionBox!;
  }

  Box<CategoryModel> get _categories {
    if (_categoryBox == null || !_categoryBox!.isOpen) {
      throw Exception('Category box is not initialized');
    }
    return _categoryBox!;
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
      return transaction.date
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)));
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
  Future<void> clearAllTransactions() async {
    await _transactions.clear();
  }

  @override
  Future<void> clearAllCategories() async {
    await _categories.clear();
  }
}
