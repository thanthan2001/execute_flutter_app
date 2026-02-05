import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/spending_limit_entity.dart';
import '../repositories/spending_limit_repository.dart';

/// UseCase để xóa spending limit
class DeleteSpendingLimitUseCase
    implements UseCase<void, DeleteSpendingLimitParams> {
  final SpendingLimitRepository repository;

  DeleteSpendingLimitUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
    DeleteSpendingLimitParams params,
  ) async {
    return await repository.deleteLimit(params.period);
  }
}

class DeleteSpendingLimitParams {
  final SpendingLimitPeriod period;

  DeleteSpendingLimitParams({required this.period});
}
