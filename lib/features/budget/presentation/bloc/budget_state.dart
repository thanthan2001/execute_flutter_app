import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/budget_status.dart';

/// Base state cho Budget feature
abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

/// State ban đầu
class BudgetInitial extends BudgetState {}

/// State đang load dữ liệu
class BudgetLoading extends BudgetState {}

/// State load thành công với danh sách budgets
class BudgetLoaded extends BudgetState {
  final List<BudgetEntity> budgets;

  const BudgetLoaded({required this.budgets});

  @override
  List<Object?> get props => [budgets];

  /// Copy với thay đổi
  BudgetLoaded copyWith({List<BudgetEntity>? budgets}) {
    return BudgetLoaded(
      budgets: budgets ?? this.budgets,
    );
  }
}

/// State đang thực hiện action (set/delete)
class BudgetActionInProgress extends BudgetState {}

/// State action thành công
class BudgetActionSuccess extends BudgetState {
  final String message;

  const BudgetActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State có lỗi
class BudgetError extends BudgetState {
  final String message;

  const BudgetError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State load budget statuses thành công
class BudgetStatusesLoaded extends BudgetState {
  final List<BudgetStatus> statuses;

  const BudgetStatusesLoaded({required this.statuses});

  @override
  List<Object?> get props => [statuses];

  /// Copy với thay đổi
  BudgetStatusesLoaded copyWith({List<BudgetStatus>? statuses}) {
    return BudgetStatusesLoaded(
      statuses: statuses ?? this.statuses,
    );
  }
}
