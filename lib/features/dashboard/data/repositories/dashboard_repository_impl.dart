import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_data_source.dart';

/// Implementation của DashboardRepository
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;

  DashboardRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Lấy tất cả giao dịch trong khoảng thời gian
      final transactions = await localDataSource.getTransactionsByDateRange(
        startDate ?? DateTime(2000),
        endDate ?? DateTime.now(),
      );

      // Lấy tất cả categories (sẽ dùng sau khi cần mapping tên category)
      // final categories = await localDataSource.getAllCategories();

      // Tính toán thống kê
      double totalIncome = 0;
      double totalExpense = 0;
      Map<String, double> expenseByCategory = {};
      Map<String, double> incomeByCategory = {};
      Map<String, MonthlyData> monthlyDataMap = {};

      for (var transaction in transactions) {
        final entity = transaction.toEntity();

        // Tính tổng thu chi
        if (entity.type.toString().contains('income')) {
          totalIncome += entity.amount;
          incomeByCategory[entity.categoryId] =
              (incomeByCategory[entity.categoryId] ?? 0) + entity.amount;
        } else {
          totalExpense += entity.amount;
          expenseByCategory[entity.categoryId] =
              (expenseByCategory[entity.categoryId] ?? 0) + entity.amount;
        }

        // Tính theo tháng
        final monthKey = '${entity.date.year}-${entity.date.month}';
        if (!monthlyDataMap.containsKey(monthKey)) {
          monthlyDataMap[monthKey] = MonthlyData(
            month: entity.date.month,
            year: entity.date.year,
            income: 0,
            expense: 0,
          );
        }

        if (entity.type.toString().contains('income')) {
          monthlyDataMap[monthKey] = MonthlyData(
            month: entity.date.month,
            year: entity.date.year,
            income: monthlyDataMap[monthKey]!.income + entity.amount,
            expense: monthlyDataMap[monthKey]!.expense,
          );
        } else {
          monthlyDataMap[monthKey] = MonthlyData(
            month: entity.date.month,
            year: entity.date.year,
            income: monthlyDataMap[monthKey]!.income,
            expense: monthlyDataMap[monthKey]!.expense + entity.amount,
          );
        }
      }

      // Sắp xếp dữ liệu theo tháng
      final monthlyData = monthlyDataMap.values.toList()
        ..sort((a, b) {
          if (a.year != b.year) return a.year.compareTo(b.year);
          return a.month.compareTo(b.month);
        });

      final summary = DashboardSummary(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
        expenseByCategory: expenseByCategory,
        incomeByCategory: incomeByCategory,
        monthlyData: monthlyData,
      );

      return Right(summary);
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
}
