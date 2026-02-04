import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/recurring_transaction_entity.dart';
import '../../domain/repositories/recurring_transaction_repository.dart';
import '../models/recurring_transaction_model.dart';

/// Implementation của RecurringTransactionRepository
class RecurringTransactionRepositoryImpl
    implements RecurringTransactionRepository {
  static const String _boxName = 'recurring_transactions';

  /// Lấy Hive box cho recurring transactions
  Future<Box<RecurringTransactionModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<RecurringTransactionModel>(_boxName);
    }
    return Hive.box<RecurringTransactionModel>(_boxName);
  }

  @override
  Future<Either<Failure, void>> createRecurring(
    RecurringTransactionEntity recurring,
  ) async {
    try {
      final box = await _getBox();
      final model = RecurringTransactionModel.fromEntity(recurring);

      await box.put(recurring.id, model);

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Không thể tạo giao dịch định kỳ: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateRecurring(
    RecurringTransactionEntity recurring,
  ) async {
    try {
      final box = await _getBox();

      if (!box.containsKey(recurring.id)) {
        return const Left(
          CacheFailure(message: 'Không tìm thấy giao dịch định kỳ'),
        );
      }

      final model = RecurringTransactionModel.fromEntity(recurring);
      await box.put(recurring.id, model);

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Không thể cập nhật giao dịch định kỳ: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<RecurringTransactionEntity>>>
      getAllRecurring() async {
    try {
      final box = await _getBox();
      final recurrings = box.values.map((model) => model.toEntity()).toList();

      // Sắp xếp theo nextDate
      recurrings.sort((a, b) => a.nextDate.compareTo(b.nextDate));

      return Right(recurrings);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Không thể lấy danh sách giao dịch định kỳ: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<RecurringTransactionEntity>>>
      getActiveRecurring() async {
    try {
      final box = await _getBox();
      final now = DateTime.now();

      final activeRecurrings = box.values
          .map((model) => model.toEntity())
          .where((recurring) {
            // Active nếu:
            // - isActive = true
            // - endDate == null HOẶC endDate >= now
            if (!recurring.isActive) return false;

            final isNotExpired = recurring.endDate == null ||
                recurring.endDate!.isAfter(now) ||
                recurring.endDate!.isAtSameMomentAs(now);

            return isNotExpired;
          })
          .toList();

      activeRecurrings.sort((a, b) => a.nextDate.compareTo(b.nextDate));

      return Right(activeRecurrings);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Không thể lấy giao dịch định kỳ đang hoạt động: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, RecurringTransactionEntity?>> getRecurringById(
    String id,
  ) async {
    try {
      final box = await _getBox();
      final model = box.get(id);

      if (model == null) {
        return const Right(null);
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(
        CacheFailure(message: 'Không thể lấy giao dịch định kỳ: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deactivateRecurring(String id) async {
    try {
      final box = await _getBox();
      final model = box.get(id);

      if (model == null) {
        return const Left(
          CacheFailure(message: 'Không tìm thấy giao dịch định kỳ'),
        );
      }

      final entity = model.toEntity();
      final updatedEntity = entity.copyWith(isActive: false);
      final updatedModel = RecurringTransactionModel.fromEntity(updatedEntity);

      await box.put(id, updatedModel);

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Không thể tạm dừng giao dịch định kỳ: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> activateRecurring(String id) async {
    try {
      final box = await _getBox();
      final model = box.get(id);

      if (model == null) {
        return const Left(
          CacheFailure(message: 'Không tìm thấy giao dịch định kỳ'),
        );
      }

      final entity = model.toEntity();
      final updatedEntity = entity.copyWith(isActive: true);
      final updatedModel = RecurringTransactionModel.fromEntity(updatedEntity);

      await box.put(id, updatedModel);

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Không thể kích hoạt lại giao dịch định kỳ: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecurring(String id) async {
    try {
      final box = await _getBox();

      if (!box.containsKey(id)) {
        return const Left(
          CacheFailure(message: 'Không tìm thấy giao dịch định kỳ'),
        );
      }

      await box.delete(id);

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Không thể xóa giao dịch định kỳ: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<RecurringTransactionEntity>>>
      getPendingRecurring() async {
    try {
      final box = await _getBox();

      final pendingRecurrings = box.values
          .map((model) => model.toEntity())
          .where((recurring) => recurring.shouldGenerateTransaction)
          .toList();

      return Right(pendingRecurrings);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Không thể lấy giao dịch định kỳ cần tạo: $e',
        ),
      );
    }
  }
}
