import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/spending_limit_entity.dart';
import '../repositories/spending_limit_repository.dart';

/// UseCase để lấy active spending limit theo period
class GetSpendingLimitUseCase
    implements UseCase<SpendingLimitEntity?, GetSpendingLimitParams> {
  final SpendingLimitRepository repository;

  GetSpendingLimitUseCase(this.repository);

  @override
  Future<Either<Failure, SpendingLimitEntity?>> call(
    GetSpendingLimitParams params,
  ) async {
    return await repository.getActiveLimit(params.period);
  }
}

class GetSpendingLimitParams {
  final SpendingLimitPeriod period;

  GetSpendingLimitParams({required this.period});
}
