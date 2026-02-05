import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/spending_limit_entity.dart';
import '../repositories/spending_limit_repository.dart';

/// UseCase để lấy tất cả spending limits
class GetAllSpendingLimitsUseCase
    implements UseCase<List<SpendingLimitEntity>, NoParams> {
  final SpendingLimitRepository repository;

  GetAllSpendingLimitsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SpendingLimitEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getAllLimits();
  }
}
