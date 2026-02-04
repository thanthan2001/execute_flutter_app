import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

/// UseCase để tạo hoặc cập nhật budget
class SetBudgetUseCase implements UseCase<void, SetBudgetParams> {
  final BudgetRepository repository;

  SetBudgetUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SetBudgetParams params) async {
    // Validation
    if (params.budget.amount <= 0) {
      return const Left(CacheFailure(message: 'Số tiền ngân sách phải lớn hơn 0'));
    }

    if (params.budget.categoryId.isEmpty) {
      return const Left(CacheFailure(message: 'Phải chọn category'));
    }

    // Kiểm tra endDate nếu có
    if (params.budget.endDate != null) {
      if (params.budget.endDate!.isBefore(params.budget.startDate)) {
        return const Left(
          CacheFailure(message: 'Ngày kết thúc phải sau ngày bắt đầu'),
        );
      }
    }

    return await repository.setBudget(params.budget);
  }
}

class SetBudgetParams {
  final BudgetEntity budget;

  SetBudgetParams({required this.budget});
}
