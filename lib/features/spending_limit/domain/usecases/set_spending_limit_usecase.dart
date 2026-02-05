import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/spending_limit_entity.dart';
import '../repositories/spending_limit_repository.dart';

/// UseCase để set spending limit
class SetSpendingLimitUseCase
    implements UseCase<void, SetSpendingLimitParams> {
  final SpendingLimitRepository repository;

  SetSpendingLimitUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SetSpendingLimitParams params) async {
    // Validation
    if (params.amount <= 0) {
      return const Left(
        CacheFailure(message: 'Số tiền giới hạn phải lớn hơn 0'),
      );
    }

    return await repository.setLimit(params.limit);
  }
}

class SetSpendingLimitParams {
  final SpendingLimitEntity limit;

  SetSpendingLimitParams({required this.limit});

  double get amount => limit.amount;
}
