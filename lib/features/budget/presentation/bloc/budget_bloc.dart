import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_budget_status_usecase.dart';
import '../../domain/usecases/delete_budget_usecase.dart';
import '../../domain/usecases/get_budgets_usecase.dart';
import '../../domain/usecases/set_budget_usecase.dart';
import 'budget_event.dart';
import 'budget_state.dart';

/// BLoC quản lý state cho Budget feature
class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetBudgetsUseCase getBudgetsUseCase;
  final GetActiveBudgetsUseCase getActiveBudgetsUseCase;
  final SetBudgetUseCase setBudgetUseCase;
  final DeleteBudgetUseCase deleteBudgetUseCase;
  final GetAllBudgetStatusesUseCase getAllBudgetStatusesUseCase;

  BudgetBloc({
    required this.getBudgetsUseCase,
    required this.getActiveBudgetsUseCase,
    required this.setBudgetUseCase,
    required this.deleteBudgetUseCase,
    required this.getAllBudgetStatusesUseCase,
  }) : super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<LoadActiveBudgets>(_onLoadActiveBudgets);
    on<SetBudget>(_onSetBudget);
    on<DeleteBudget>(_onDeleteBudget);
    on<RefreshBudgets>(_onRefreshBudgets);
    on<LoadBudgetStatuses>(_onLoadBudgetStatuses);
  }

  /// Handler: Load tất cả budgets
  Future<void> _onLoadBudgets(
    LoadBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());

    final result = await getBudgetsUseCase(NoParams());

    result.fold(
      (failure) => emit(BudgetError(
        message: failure is CacheFailure
            ? failure.message ?? 'Không thể tải danh sách ngân sách'
            : 'Có lỗi xảy ra',
      )),
      (budgets) => emit(BudgetLoaded(budgets: budgets)),
    );
  }

  /// Handler: Load active budgets
  Future<void> _onLoadActiveBudgets(
    LoadActiveBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());

    final result = await getActiveBudgetsUseCase(NoParams());

    result.fold(
      (failure) => emit(BudgetError(
        message: failure is CacheFailure
            ? failure.message ?? 'Không thể tải ngân sách đang hoạt động'
            : 'Có lỗi xảy ra',
      )),
      (budgets) => emit(BudgetLoaded(budgets: budgets)),
    );
  }

  /// Handler: Set budget (create hoặc update)
  Future<void> _onSetBudget(
    SetBudget event,
    Emitter<BudgetState> emit,
  ) async {
    // Lưu state hiện tại để restore nếu có lỗi
    final previousState = state;
    emit(BudgetActionInProgress());

    final result = await setBudgetUseCase(
      SetBudgetParams(budget: event.budget),
    );

    result.fold(
      (failure) {
        emit(BudgetError(
          message: failure is CacheFailure
              ? failure.message ?? 'Không thể lưu ngân sách'
              : 'Có lỗi xảy ra',
        ));
        // Restore previous state sau khi emit error
        if (previousState is BudgetLoaded) {
          emit(previousState);
        }
      },
      (_) {
        emit(const BudgetActionSuccess(message: 'Lưu ngân sách thành công'));
        // Reload budgets
        add(const LoadBudgets());
      },
    );
  }

  /// Handler: Delete budget
  Future<void> _onDeleteBudget(
    DeleteBudget event,
    Emitter<BudgetState> emit,
  ) async {
    final previousState = state;
    emit(BudgetActionInProgress());

    final result = await deleteBudgetUseCase(
      DeleteBudgetParams(budgetId: event.budgetId),
    );

    result.fold(
      (failure) {
        emit(BudgetError(
          message: failure is CacheFailure
              ? failure.message ?? 'Không thể xóa ngân sách'
              : 'Có lỗi xảy ra',
        ));
        // Restore previous state
        if (previousState is BudgetLoaded) {
          emit(previousState);
        }
      },
      (_) {
        emit(const BudgetActionSuccess(message: 'Xóa ngân sách thành công'));
        // Reload budgets
        add(const LoadBudgets());
      },
    );
  }

  /// Handler: Refresh budgets
  Future<void> _onRefreshBudgets(
    RefreshBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    // Trigger LoadBudgets
    add(const LoadBudgets());
  }

  /// Handler: Load budget statuses
  Future<void> _onLoadBudgetStatuses(
    LoadBudgetStatuses event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());

    final result = await getAllBudgetStatusesUseCase(NoParams());

    result.fold(
      (failure) => emit(BudgetError(
        message: failure is CacheFailure
            ? failure.message ?? 'Không thể tải trạng thái ngân sách'
            : 'Có lỗi xảy ra',
      )),
      (statuses) => emit(BudgetStatusesLoaded(statuses: statuses)),
    );
  }
}
