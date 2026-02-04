import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/budget_repository.dart';

/// UseCase để xóa budget
class DeleteBudgetUseCase implements UseCase<void, DeleteBudgetParams> {
  final BudgetRepository repository;

  DeleteBudgetUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteBudgetParams params) async {
    if (params.budgetId.isEmpty) {
      return const Left(CacheFailure(message: 'Budget ID không hợp lệ'));
    }

    return await repository.deleteBudget(params.budgetId);
  }
}

class DeleteBudgetParams {
  final String budgetId;

  DeleteBudgetParams({required this.budgetId});
}
