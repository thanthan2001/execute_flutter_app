import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../../dashboard/data/datasources/dashboard_local_data_source.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../domain/entities/spending_limit_entity.dart';
import '../../domain/entities/spending_limit_status.dart';
import '../../domain/repositories/spending_limit_repository.dart';
import '../models/spending_limit_model.dart';

/// Implementation của SpendingLimitRepository
class SpendingLimitRepositoryImpl implements SpendingLimitRepository {
  final DashboardLocalDataSource localDataSource;
  static const String _spendingLimitBoxName = 'spending_limits';

  SpendingLimitRepositoryImpl({required this.localDataSource});

  /// Lấy Hive box cho spending limits
  Future<Box<SpendingLimitModel>> _getSpendingLimitBox() async {
    if (!Hive.isBoxOpen(_spendingLimitBoxName)) {
      return await Hive.openBox<SpendingLimitModel>(_spendingLimitBoxName);
    }
    return Hive.box<SpendingLimitModel>(_spendingLimitBoxName);
  }

  @override
  Future<Either<Failure, void>> setLimit(SpendingLimitEntity limit) async {
    try {
      final box = await _getSpendingLimitBox();
      final model = SpendingLimitModel.fromEntity(limit);

      // Lưu với key là period (để mỗi period chỉ có 1 limit)
      await box.put(limit.period.toValue(), model);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Không thể lưu giới hạn chi tiêu: $e'));
    }
  }

  @override
  Future<Either<Failure, SpendingLimitEntity?>> getActiveLimit(
    SpendingLimitPeriod period,
  ) async {
    try {
      final box = await _getSpendingLimitBox();
      final model = box.get(period.toValue());

      if (model == null) {
        return const Right(null);
      }

      final entity = model.toEntity();

      // Chỉ trả về nếu isActive = true
      if (!entity.isActive) {
        return const Right(null);
      }

      return Right(entity);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Không thể lấy giới hạn chi tiêu: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteLimit(
    SpendingLimitPeriod period,
  ) async {
    try {
      final box = await _getSpendingLimitBox();
      final key = period.toValue();

      if (!box.containsKey(key)) {
        return const Left(
          CacheFailure(message: 'Không tìm thấy giới hạn chi tiêu'),
        );
      }

      await box.delete(key);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Không thể xóa giới hạn chi tiêu: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<SpendingLimitEntity>>> getAllLimits() async {
    try {
      final box = await _getSpendingLimitBox();
      final limits = box.values.map((model) => model.toEntity()).toList();

      return Right(limits);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Không thể lấy danh sách giới hạn chi tiêu: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, SpendingLimitStatus?>> getSpendingLimitStatus(
    SpendingLimitPeriod period,
  ) async {
    try {
      // Lấy active limit
      final limitResult = await getActiveLimit(period);

      return limitResult.fold(
        (failure) => Left(failure),
        (limit) async {
          if (limit == null) {
            // Không có active limit → trả về null
            return const Right(null);
          }

          // Tính date range cho period hiện tại
          final dateRange = _calculateDateRangeForPeriod(period);

          // Lấy transactions trong khoảng thời gian
          final transactionsResult = await localDataSource.getTransactionsByDateRange(
            dateRange.startDate,
            dateRange.endDate,
          );

          // Chỉ tính expense transactions (không tính income và refunds)
          final expenseTransactions = transactionsResult
              .where((t) => t.type == TransactionType.expense.name)
              .toList();

          // Tính tổng chi tiêu
          final usedAmount = expenseTransactions.fold<double>(
            0.0,
            (sum, t) => sum + t.amount,
          );

          // Tính phần trăm
          final percentage = limit.amount > 0 ? (usedAmount / limit.amount) * 100 : 0.0;

          // Xác định alert level
          final alertLevel = SpendingLimitAlertLevelExtension.fromPercentage(percentage);

          final status = SpendingLimitStatus(
            limitId: limit.id,
            limitAmount: limit.amount,
            usedAmount: usedAmount,
            percentage: percentage,
            alertLevel: alertLevel,
            periodStart: dateRange.startDate,
            periodEnd: dateRange.endDate,
          );

          return Right(status);
        },
      );
    } catch (e) {
      return Left(
        CacheFailure(message: 'Không thể kiểm tra trạng thái giới hạn chi tiêu: $e'),
      );
    }
  }

  /// Helper: Tính toán date range cho period hiện tại
  ({DateTime startDate, DateTime endDate}) _calculateDateRangeForPeriod(
    SpendingLimitPeriod period,
  ) {
    final now = DateTime.now();

    switch (period) {
      case SpendingLimitPeriod.weekly:
        // Lấy tuần hiện tại (Thứ 2 - Chủ nhật)
        final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
        final startOfWeek = now.subtract(Duration(days: currentWeekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));

        return (
          startDate: DateTime(
            startOfWeek.year,
            startOfWeek.month,
            startOfWeek.day,
            0,
            0,
            0,
          ),
          endDate: DateTime(
            endOfWeek.year,
            endOfWeek.month,
            endOfWeek.day,
            23,
            59,
            59,
          ),
        );

      case SpendingLimitPeriod.monthly:
        // Lấy tháng hiện tại
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return (startDate: startOfMonth, endDate: endOfMonth);
    }
  }
}
