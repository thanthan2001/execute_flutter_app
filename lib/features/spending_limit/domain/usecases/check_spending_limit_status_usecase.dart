import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/spending_limit_status.dart';
import '../repositories/spending_limit_repository.dart';
import '../entities/spending_limit_entity.dart';

/// UseCase để kiểm tra trạng thái spending limit
class CheckSpendingLimitStatusUseCase
    implements UseCase<SpendingLimitStatus?, CheckSpendingLimitStatusParams> {
  final SpendingLimitRepository repository;

  CheckSpendingLimitStatusUseCase(this.repository);

  @override
  Future<Either<Failure, SpendingLimitStatus?>> call(
    CheckSpendingLimitStatusParams params,
  ) async {
    return await repository.getSpendingLimitStatus(params.period);
  }
}

class CheckSpendingLimitStatusParams {
  final SpendingLimitPeriod period;

  CheckSpendingLimitStatusParams({required this.period});
}
