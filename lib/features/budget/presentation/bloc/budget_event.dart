import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_entity.dart';

/// Base event cho Budget feature
abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Load tất cả budgets
class LoadBudgets extends BudgetEvent {
  const LoadBudgets();
}

/// Event: Load active budgets
class LoadActiveBudgets extends BudgetEvent {
  const LoadActiveBudgets();
}

/// Event: Thêm hoặc cập nhật budget
class SetBudget extends BudgetEvent {
  final BudgetEntity budget;

  const SetBudget({required this.budget});

  @override
  List<Object?> get props => [budget];
}

/// Event: Xóa budget
class DeleteBudget extends BudgetEvent {
  final String budgetId;

  const DeleteBudget({required this.budgetId});

  @override
  List<Object?> get props => [budgetId];
}

/// Event: Refresh budgets (load lại)
class RefreshBudgets extends BudgetEvent {
  const RefreshBudgets();
}

/// Event: Load budget statuses (với chi tiêu thực tế)
class LoadBudgetStatuses extends BudgetEvent {
  const LoadBudgetStatuses();
}
