import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/budget_status.dart';
import '../repositories/budget_repository.dart';

/// UseCase để kiểm tra trạng thái budget (so với chi tiêu thực tế)
class CheckBudgetStatusUseCase
    implements UseCase<BudgetStatus, CheckBudgetStatusParams> {
  final BudgetRepository repository;

  CheckBudgetStatusUseCase(this.repository);

  @override
  Future<Either<Failure, BudgetStatus>> call(
    CheckBudgetStatusParams params,
  ) async {
    if (params.budgetId.isEmpty) {
      return const Left(CacheFailure(message: 'Budget ID không hợp lệ'));
    }

    if (params.endDate.isBefore(params.startDate)) {
      return const Left(
        CacheFailure(message: 'Ngày kết thúc phải sau ngày bắt đầu'),
      );
    }

    return await repository.getBudgetStatus(
      params.budgetId,
      params.startDate,
      params.endDate,
    );
  }
}

class CheckBudgetStatusParams {
  final String budgetId;
  final DateTime startDate;
  final DateTime endDate;

  CheckBudgetStatusParams({
    required this.budgetId,
    required this.startDate,
    required this.endDate,
  });
}

/// UseCase để lấy tất cả budget statuses đang active
class GetAllBudgetStatusesUseCase
    implements UseCase<List<BudgetStatus>, NoParams> {
  final BudgetRepository repository;

  GetAllBudgetStatusesUseCase(this.repository);

  @override
  Future<Either<Failure, List<BudgetStatus>>> call(NoParams params) async {
    return await repository.getAllBudgetStatuses();
  }
}
