import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

/// UseCase để xóa giao dịch
class DeleteTransactionUseCase
    implements UseCase<void, DeleteTransactionParams> {
  final TransactionRepository repository;

  DeleteTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTransactionParams params) async {
    return await repository.deleteTransaction(params.id);
  }
}

/// Parameters cho DeleteTransactionUseCase
class DeleteTransactionParams extends Equatable {
  final String id;

  const DeleteTransactionParams({required this.id});

  @override
  List<Object?> get props => [id];
}
