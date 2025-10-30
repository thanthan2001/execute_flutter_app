import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// UseCase để thêm giao dịch mới
class AddTransactionUseCase implements UseCase<void, AddTransactionParams> {
  final TransactionRepository repository;

  AddTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTransactionParams params) async {
    return await repository.addTransaction(params.transaction);
  }
}

/// Parameters cho AddTransactionUseCase
class AddTransactionParams extends Equatable {
  final TransactionEntity transaction;

  const AddTransactionParams({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}
