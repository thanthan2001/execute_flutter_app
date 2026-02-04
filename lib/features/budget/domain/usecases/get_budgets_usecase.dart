import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

/// UseCase để lấy tất cả budgets
class GetBudgetsUseCase implements UseCase<List<BudgetEntity>, NoParams> {
  final BudgetRepository repository;

  GetBudgetsUseCase(this.repository);

  @override
  Future<Either<Failure, List<BudgetEntity>>> call(NoParams params) async {
    return await repository.getAllBudgets();
  }
}

/// UseCase để lấy các budgets đang active
class GetActiveBudgetsUseCase
    implements UseCase<List<BudgetEntity>, NoParams> {
  final BudgetRepository repository;

  GetActiveBudgetsUseCase(this.repository);

  @override
  Future<Either<Failure, List<BudgetEntity>>> call(NoParams params) async {
    return await repository.getActiveBudgets();
  }
}

/// UseCase để lấy budget theo category
class GetBudgetByCategoryUseCase
    implements UseCase<BudgetEntity?, GetBudgetByCategoryParams> {
  final BudgetRepository repository;

  GetBudgetByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, BudgetEntity?>> call(
    GetBudgetByCategoryParams params,
  ) async {
    if (params.categoryId.isEmpty) {
      return const Left(CacheFailure(message: 'Category ID không hợp lệ'));
    }

    return await repository.getBudgetByCategory(
      params.categoryId,
      params.date,
    );
  }
}

class GetBudgetByCategoryParams {
  final String categoryId;
  final DateTime date;

  GetBudgetByCategoryParams({
    required this.categoryId,
    required this.date,
  });
}
