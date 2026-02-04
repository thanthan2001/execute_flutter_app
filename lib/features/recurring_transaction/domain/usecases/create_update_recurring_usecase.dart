import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/recurring_transaction_entity.dart';
import '../repositories/recurring_transaction_repository.dart';

/// UseCase để tạo recurring transaction
class CreateRecurringTransactionUseCase
    implements UseCase<void, CreateRecurringTransactionParams> {
  final RecurringTransactionRepository repository;

  CreateRecurringTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
    CreateRecurringTransactionParams params,
  ) async {
    // Validation
    if (params.recurring.amount <= 0) {
      return const Left(
        CacheFailure(message: 'Số tiền phải lớn hơn 0'),
      );
    }

    if (params.recurring.categoryId.isEmpty) {
      return const Left(CacheFailure(message: 'Phải chọn category'));
    }

    if (params.recurring.description.trim().isEmpty) {
      return const Left(CacheFailure(message: 'Phải nhập mô tả'));
    }

    // Kiểm tra endDate nếu có
    if (params.recurring.endDate != null) {
      if (params.recurring.endDate!.isBefore(params.recurring.nextDate)) {
        return const Left(
          CacheFailure(message: 'Ngày kết thúc phải sau ngày bắt đầu'),
        );
      }
    }

    return await repository.createRecurring(params.recurring);
  }
}

class CreateRecurringTransactionParams {
  final RecurringTransactionEntity recurring;

  CreateRecurringTransactionParams({required this.recurring});
}

/// UseCase để cập nhật recurring transaction
class UpdateRecurringTransactionUseCase
    implements UseCase<void, UpdateRecurringTransactionParams> {
  final RecurringTransactionRepository repository;

  UpdateRecurringTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
    UpdateRecurringTransactionParams params,
  ) async {
    // Validation giống create
    if (params.recurring.amount <= 0) {
      return const Left(
        CacheFailure(message: 'Số tiền phải lớn hơn 0'),
      );
    }

    if (params.recurring.categoryId.isEmpty) {
      return const Left(CacheFailure(message: 'Phải chọn category'));
    }

    if (params.recurring.description.trim().isEmpty) {
      return const Left(CacheFailure(message: 'Phải nhập mô tả'));
    }

    if (params.recurring.endDate != null) {
      if (params.recurring.endDate!.isBefore(params.recurring.nextDate)) {
        return const Left(
          CacheFailure(message: 'Ngày kết thúc phải sau ngày bắt đầu'),
        );
      }
    }

    return await repository.updateRecurring(params.recurring);
  }
}

class UpdateRecurringTransactionParams {
  final RecurringTransactionEntity recurring;

  UpdateRecurringTransactionParams({required this.recurring});
}
