import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// UseCase để cập nhật giao dịch
class UpdateTransactionUseCase
    implements UseCase<void, UpdateTransactionParams> {
  final TransactionRepository repository;

  UpdateTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateTransactionParams params) async {
    return await repository.updateTransaction(params.transaction);
  }
}

/// Parameters cho UpdateTransactionUseCase
class UpdateTransactionParams extends Equatable {
  final TransactionEntity transaction;

  const UpdateTransactionParams({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}
