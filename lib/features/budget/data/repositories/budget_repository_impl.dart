import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../dashboard/data/datasources/dashboard_local_data_source.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/budget_status.dart';
import '../../domain/repositories/budget_repository.dart';
import '../models/budget_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Implementation của BudgetRepository
class BudgetRepositoryImpl implements BudgetRepository {
  final DashboardLocalDataSource localDataSource;
  static const String _budgetBoxName = 'budgets';

  BudgetRepositoryImpl({required this.localDataSource});

  /// Lấy Hive box cho budgets
  Future<Box<BudgetModel>> _getBudgetBox() async {
    if (!Hive.isBoxOpen(_budgetBoxName)) {
      return await Hive.openBox<BudgetModel>(_budgetBoxName);
    }
    return Hive.box<BudgetModel>(_budgetBoxName);
  }

  @override
  Future<Either<Failure, void>> setBudget(BudgetEntity budget) async {
    try {
      final box = await _getBudgetBox();
      final model = BudgetModel.fromEntity(budget);

      // Lưu với key là budget.id
      await box.put(budget.id, model);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Không thể lưu ngân sách: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BudgetEntity>>> getAllBudgets() async {
    try {
      final box = await _getBudgetBox();
      final budgets = box.values.map((model) => model.toEntity()).toList();

      // Sắp xếp theo startDate giảm dần
      budgets.sort((a, b) => b.startDate.compareTo(a.startDate));

      return Right(budgets);
    } catch (e) {
      return Left(CacheFailure(message: 'Không thể lấy danh sách ngân sách: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BudgetEntity>>> getActiveBudgets() async {
    try {
      final box = await _getBudgetBox();
      final now = DateTime.now();

      final activeBudgets = box.values
          .map((model) => model.toEntity())
          .where((budget) {
            // Budget active nếu:
            // - startDate <= now
            // - endDate == null HOẶC endDate >= now
            final isStarted = budget.startDate.isBefore(now) ||
                budget.startDate.isAtSameMomentAs(now);
            final isNotEnded = budget.endDate == null ||
                budget.endDate!.isAfter(now) ||
                budget.endDate!.isAtSameMomentAs(now);

            return isStarted && isNotEnded;
          })
          .toList();

      activeBudgets.sort((a, b) => b.startDate.compareTo(a.startDate));

      return Right(activeBudgets);
    } catch (e) {
      return Left(CacheFailure(message: 'Không thể lấy ngân sách active: $e'));
    }
  }

  @override
  Future<Either<Failure, BudgetEntity?>> getBudgetByCategory(
    String categoryId,
    DateTime date,
  ) async {
    try {
      final box = await _getBudgetBox();

      // Tìm budget cho category này trong khoảng thời gian chứa [date]
      final matchingBudgets = box.values
          .map((model) => model.toEntity())
          .where((budget) {
            if (budget.categoryId != categoryId) return false;

            // Kiểm tra date có nằm trong [startDate, endDate] không
            final isAfterStart = date.isAfter(budget.startDate) ||
                date.isAtSameMomentAs(budget.startDate);

            final isBeforeEnd = budget.endDate == null ||
                date.isBefore(budget.endDate!) ||
                date.isAtSameMomentAs(budget.endDate!);

            return isAfterStart && isBeforeEnd;
          })
          .toList();

      // Nếu có nhiều budget trùng, lấy cái mới nhất (startDate lớn nhất)
      if (matchingBudgets.isEmpty) {
        return const Right(null);
      }

      matchingBudgets.sort((a, b) => b.startDate.compareTo(a.startDate));
      return Right(matchingBudgets.first);
    } catch (e) {
      return Left(CacheFailure(message: 'Không thể lấy ngân sách theo category: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String budgetId) async {
    try {
      final box = await _getBudgetBox();

      if (!box.containsKey(budgetId)) {
        return const Left(CacheFailure(message: 'Không tìm thấy ngân sách'));
      }

      await box.delete(budgetId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Không thể xóa ngân sách: $e'));
    }
  }

  @override
  Future<Either<Failure, BudgetStatus>> getBudgetStatus(
    String budgetId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final box = await _getBudgetBox();

      // Lấy budget
      final budgetModel = box.get(budgetId);
      if (budgetModel == null) {
        return const Left(CacheFailure(message: 'Không tìm thấy ngân sách'));
      }

      final budget = budgetModel.toEntity();

      // Lấy transactions trong khoảng thời gian
      final transactionsResult = await localDataSource.getTransactionsByDateRange(
        startDate,
        endDate,
      );

      // Lọc transactions theo categoryId và type = expense
      final categoryTransactions = transactionsResult
          .where((t) =>
              t.categoryId == budget.categoryId &&
              t.type == 'expense') // Chỉ tính chi tiêu
          .toList();

      // Tính tổng chi tiêu
      final usedAmount = categoryTransactions.fold<double>(
        0.0,
        (sum, t) => sum + t.amount,
      );

      // Tính phần trăm
      final percentage = budget.amount > 0 ? (usedAmount / budget.amount) * 100 : 0.0;

      // Xác định alert level
      final alertLevel = BudgetAlertLevelExtension.fromPercentage(percentage);

      final status = BudgetStatus(
        budgetId: budgetId,
        categoryId: budget.categoryId,
        budgetAmount: budget.amount,
        usedAmount: usedAmount,
        percentage: percentage,
        alertLevel: alertLevel,
      );

      return Right(status);
    } catch (e) {
      return Left(CacheFailure(message: 'Không thể kiểm tra trạng thái ngân sách: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BudgetStatus>>> getAllBudgetStatuses() async {
    try {
      // Lấy tất cả active budgets
      final activeBudgetsResult = await getActiveBudgets();

      return activeBudgetsResult.fold(
        (failure) => Left(failure),
        (budgets) async {
          final statuses = <BudgetStatus>[];

          for (final budget in budgets) {
            // Tính toán date range dựa trên period
            final dateRange = _calculateDateRangeForBudget(budget);

            final statusResult = await getBudgetStatus(
              budget.id,
              dateRange.startDate,
              dateRange.endDate,
            );

            statusResult.fold(
              (failure) {
                // Bỏ qua lỗi của từng budget, tiếp tục với budget khác
              },
              (status) {
                statuses.add(status);
              },
            );
          }

          return Right(statuses);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Không thể lấy trạng thái ngân sách: $e'));
    }
  }

  /// Helper: Tính toán date range cho budget dựa trên period
  ({DateTime startDate, DateTime endDate}) _calculateDateRangeForBudget(
    BudgetEntity budget,
  ) {
    final now = DateTime.now();

    switch (budget.period) {
      case BudgetPeriod.monthly:
        // Lấy tháng hiện tại
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return (startDate: startOfMonth, endDate: endOfMonth);

      case BudgetPeriod.quarterly:
        // Lấy quý hiện tại (Q1: 1-3, Q2: 4-6, Q3: 7-9, Q4: 10-12)
        final quarter = ((now.month - 1) ~/ 3) + 1;
        final startMonth = (quarter - 1) * 3 + 1;
        final startOfQuarter = DateTime(now.year, startMonth, 1);
        final endOfQuarter = DateTime(now.year, startMonth + 3, 0, 23, 59, 59);
        return (startDate: startOfQuarter, endDate: endOfQuarter);

      case BudgetPeriod.yearly:
        // Lấy năm hiện tại
        final startOfYear = DateTime(now.year, 1, 1);
        final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
        return (startDate: startOfYear, endDate: endOfYear);
    }
  }
}
