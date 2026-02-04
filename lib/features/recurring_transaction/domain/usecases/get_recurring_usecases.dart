import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/recurring_transaction_entity.dart';
import '../repositories/recurring_transaction_repository.dart';

/// UseCase để lấy tất cả recurring transactions
class GetAllRecurringTransactionsUseCase
    implements UseCase<List<RecurringTransactionEntity>, NoParams> {
  final RecurringTransactionRepository repository;

  GetAllRecurringTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RecurringTransactionEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getAllRecurring();
  }
}

/// UseCase để lấy active recurring transactions
class GetActiveRecurringTransactionsUseCase
    implements UseCase<List<RecurringTransactionEntity>, NoParams> {
  final RecurringTransactionRepository repository;

  GetActiveRecurringTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RecurringTransactionEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getActiveRecurring();
  }
}

/// UseCase để activate recurring transaction
class ActivateRecurringUseCase
    implements UseCase<void, ActivateRecurringParams> {
  final RecurringTransactionRepository repository;

  ActivateRecurringUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ActivateRecurringParams params) async {
    if (params.id.isEmpty) {
      return const Left(CacheFailure(message: 'ID không hợp lệ'));
    }

    return await repository.activateRecurring(params.id);
  }
}

class ActivateRecurringParams {
  final String id;

  ActivateRecurringParams({required this.id});
}

/// UseCase để deactivate recurring transaction
class DeactivateRecurringUseCase
    implements UseCase<void, DeactivateRecurringParams> {
  final RecurringTransactionRepository repository;

  DeactivateRecurringUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeactivateRecurringParams params) async {
    if (params.id.isEmpty) {
      return const Left(CacheFailure(message: 'ID không hợp lệ'));
    }

    return await repository.deactivateRecurring(params.id);
  }
}

class DeactivateRecurringParams {
  final String id;

  DeactivateRecurringParams({required this.id});
}

/// UseCase để xóa recurring transaction
class DeleteRecurringUseCase implements UseCase<void, DeleteRecurringParams> {
  final RecurringTransactionRepository repository;

  DeleteRecurringUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteRecurringParams params) async {
    if (params.id.isEmpty) {
      return const Left(CacheFailure(message: 'ID không hợp lệ'));
    }

    return await repository.deleteRecurring(params.id);
  }
}

class DeleteRecurringParams {
  final String id;

  DeleteRecurringParams({required this.id});
}
