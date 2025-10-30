import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../dashboard/data/datasources/dashboard_local_data_source.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart' as tx;
import '../../domain/entities/filter_options.dart';
import '../../domain/entities/statistics_summary.dart';
import '../../domain/repositories/statistics_repository.dart';

/// Implementation của StatisticsRepository
/// Sử dụng DashboardLocalDataSource để lấy transactions và categories
class StatisticsRepositoryImpl implements StatisticsRepository {
  final DashboardLocalDataSource localDataSource;

  StatisticsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, StatisticsSummary>> getStatistics({
    required FilterOptions filter,
  }) async {
    try {
      // 1. Normalize date range dựa trên dateMode
      final dateRange = filter.getNormalizedDateRange();
      final startDate = dateRange.start;
      final endDate = dateRange.end;

      // 2. Lấy tất cả transactions trong khoảng thời gian
      final transactionModels =
          await localDataSource.getTransactionsByDateRange(startDate, endDate);
      final transactions =
          transactionModels.map((model) => model.toEntity()).toList();

      // 3. Lấy tất cả categories để map thông tin
      final categoryModels = await localDataSource.getAllCategories();
      final categories =
          categoryModels.map((model) => model.toEntity()).toList();
      final categoryMap = {for (var cat in categories) cat.id: cat};

      // 4. Filter theo type (all/income/expense)
      List<tx.TransactionEntity> filteredTransactions = transactions;
      if (filter.type == TransactionType.income) {
        filteredTransactions = transactions
            .where((t) => t.type == tx.TransactionType.income)
            .toList();
      } else if (filter.type == TransactionType.expense) {
        filteredTransactions = transactions
            .where((t) => t.type == tx.TransactionType.expense)
            .toList();
      }

      // 5. Filter theo category nếu có
      if (filter.categoryId != null) {
        filteredTransactions = filteredTransactions
            .where((t) => t.categoryId == filter.categoryId)
            .toList();
      }

      // 6. Tính tổng thu và tổng chi
      double totalIncome = 0;
      double totalExpense = 0;

      for (var transaction in filteredTransactions) {
        if (transaction.type == tx.TransactionType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.type == tx.TransactionType.expense) {
          totalExpense += transaction.amount;
        }
      }

      // 7. Thống kê theo category
      // Group transactions by category
      Map<String, List<tx.TransactionEntity>> incomeByCategory = {};
      Map<String, List<tx.TransactionEntity>> expenseByCategory = {};

      for (var transaction in filteredTransactions) {
        final categoryId = transaction.categoryId;
        if (transaction.type == tx.TransactionType.income) {
          incomeByCategory.putIfAbsent(categoryId, () => []);
          incomeByCategory[categoryId]!.add(transaction);
        } else if (transaction.type == tx.TransactionType.expense) {
          expenseByCategory.putIfAbsent(categoryId, () => []);
          expenseByCategory[categoryId]!.add(transaction);
        }
      }

      // 8. Tạo CategoryStatistics cho thu nhập
      final incomeStats = <CategoryStatistics>[];
      for (var entry in incomeByCategory.entries) {
        final categoryId = entry.key;
        final categoryTransactions = entry.value;
        final category = categoryMap[categoryId];

        if (category == null) continue;

        final amount = categoryTransactions.fold<double>(
          0,
          (sum, t) => sum + t.amount,
        );
        final percentage = totalIncome > 0 ? (amount / totalIncome) * 100 : 0.0;

        incomeStats.add(CategoryStatistics(
          categoryId: categoryId,
          categoryName: category.name,
          categoryIconCodePoint: category.icon.codePoint,
          categoryIconFontFamily: category.icon.fontFamily ?? 'MaterialIcons',
          categoryIconFontPackage: category.icon.fontPackage,
          categoryColorValue: category.color.value,
          amount: amount,
          percentage: percentage,
          transactionCount: categoryTransactions.length,
        ));
      }

      // Sắp xếp theo amount giảm dần
      incomeStats.sort((a, b) => b.amount.compareTo(a.amount));

      // 9. Tạo CategoryStatistics cho chi tiêu
      final expenseStats = <CategoryStatistics>[];
      for (var entry in expenseByCategory.entries) {
        final categoryId = entry.key;
        final categoryTransactions = entry.value;
        final category = categoryMap[categoryId];

        if (category == null) continue;

        final amount = categoryTransactions.fold<double>(
          0,
          (sum, t) => sum + t.amount,
        );
        final percentage =
            totalExpense > 0 ? (amount / totalExpense) * 100 : 0.0;

        expenseStats.add(CategoryStatistics(
          categoryId: categoryId,
          categoryName: category.name,
          categoryIconCodePoint: category.icon.codePoint,
          categoryIconFontFamily: category.icon.fontFamily ?? 'MaterialIcons',
          categoryIconFontPackage: category.icon.fontPackage,
          categoryColorValue: category.color.value,
          amount: amount,
          percentage: percentage,
          transactionCount: categoryTransactions.length,
        ));
      }

      // Sắp xếp theo amount giảm dần
      expenseStats.sort((a, b) => b.amount.compareTo(a.amount));

      // 10. Tạo StatisticsSummary
      final summary = StatisticsSummary(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
        incomeByCategory: incomeStats,
        expenseByCategory: expenseStats,
      );

      return Right(summary);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
