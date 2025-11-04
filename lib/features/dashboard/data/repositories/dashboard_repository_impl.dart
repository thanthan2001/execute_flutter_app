import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Implementation của DashboardRepository
/// Dashboard chỉ tổng hợp dữ liệu từ TransactionRepository
class DashboardRepositoryImpl implements DashboardRepository {
  final TransactionRepository transactionRepository;

  DashboardRepositoryImpl({required this.transactionRepository});

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactionsResult = await transactionRepository.getAllTransactions();

    return transactionsResult.fold(
      (failure) => Left(failure),
      (allTransactions) {
        try {
          final start = startDate ?? DateTime(2000);
          final end = endDate ?? DateTime.now();

          final transactions = allTransactions.where((transaction) {
            // So sánh chính xác: >= start AND <= end
            return !transaction.date.isBefore(start) &&
                !transaction.date.isAfter(end);
          }).toList();

          double totalIncome = 0;
          double totalExpense = 0;
          Map<String, double> expenseByCategory = {};
          Map<String, double> incomeByCategory = {};
          Map<String, MonthlyData> monthlyDataMap = {};

          for (var transaction in transactions) {
            if (transaction.type == TransactionType.income) {
              totalIncome += transaction.amount;
              incomeByCategory[transaction.categoryId] =
                  (incomeByCategory[transaction.categoryId] ?? 0) +
                      transaction.amount;
            } else {
              totalExpense += transaction.amount;
              expenseByCategory[transaction.categoryId] =
                  (expenseByCategory[transaction.categoryId] ?? 0) +
                      transaction.amount;
            }

            final monthKey =
                '${transaction.date.year}-${transaction.date.month}';
            if (!monthlyDataMap.containsKey(monthKey)) {
              monthlyDataMap[monthKey] = MonthlyData(
                month: transaction.date.month,
                year: transaction.date.year,
                income: 0,
                expense: 0,
              );
            }

            if (transaction.type == TransactionType.income) {
              monthlyDataMap[monthKey] = MonthlyData(
                month: transaction.date.month,
                year: transaction.date.year,
                income: monthlyDataMap[monthKey]!.income + transaction.amount,
                expense: monthlyDataMap[monthKey]!.expense,
              );
            } else {
              monthlyDataMap[monthKey] = MonthlyData(
                month: transaction.date.month,
                year: transaction.date.year,
                income: monthlyDataMap[monthKey]!.income,
                expense: monthlyDataMap[monthKey]!.expense + transaction.amount,
              );
            }
          }

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
      },
    );
  }
}
