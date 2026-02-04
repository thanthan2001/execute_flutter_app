import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../entities/recurring_transaction_entity.dart';
import '../repositories/recurring_transaction_repository.dart';
import 'package:uuid/uuid.dart';

/// UseCase để generate transactions từ recurring transactions đến hạn
class GeneratePendingTransactionsUseCase
    implements UseCase<List<TransactionEntity>, NoParams> {
  final RecurringTransactionRepository repository;

  GeneratePendingTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(
    NoParams params,
  ) async {
    // Lấy các recurring transactions cần generate
    final pendingResult = await repository.getPendingRecurring();

    return pendingResult.fold(
      (failure) => Left(failure),
      (pendingRecurrings) async {
        final generatedTransactions = <TransactionEntity>[];

        for (final recurring in pendingRecurrings) {
          // Tạo transaction từ recurring
          final transaction = _createTransactionFromRecurring(recurring);
          generatedTransactions.add(transaction);

          // Cập nhật nextDate của recurring
          final updatedRecurring = recurring.copyWith(
            nextDate: recurring.frequency.calculateNextDate(recurring.nextDate),
          );

          // Cập nhật recurring trong repository
          await repository.updateRecurring(updatedRecurring);
        }

        return Right(generatedTransactions);
      },
    );
  }

  /// Helper: Tạo TransactionEntity từ RecurringTransactionEntity
  TransactionEntity _createTransactionFromRecurring(
    RecurringTransactionEntity recurring,
  ) {
    return TransactionEntity(
      id: const Uuid().v4(),
      categoryId: recurring.categoryId,
      amount: recurring.amount,
      description: recurring.description,
      date: recurring.nextDate,
      type: recurring.amount > 0
          ? TransactionType.income
          : TransactionType.expense,
    );
  }
}
