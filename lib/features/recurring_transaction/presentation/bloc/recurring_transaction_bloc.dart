import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/services/recurring_transaction_service.dart';
import '../../domain/usecases/create_update_recurring_usecase.dart';
import '../../domain/usecases/get_recurring_usecases.dart';
import 'recurring_transaction_event.dart';
import 'recurring_transaction_state.dart';

/// BLoC quản lý state cho RecurringTransaction feature
class RecurringTransactionBloc
    extends Bloc<RecurringTransactionEvent, RecurringTransactionState> {
  final GetAllRecurringTransactionsUseCase getAllRecurringTransactionsUseCase;
  final GetActiveRecurringTransactionsUseCase
      getActiveRecurringTransactionsUseCase;
  final CreateRecurringTransactionUseCase createRecurringTransactionUseCase;
  final UpdateRecurringTransactionUseCase updateRecurringTransactionUseCase;
  final ActivateRecurringUseCase activateRecurringUseCase;
  final DeactivateRecurringUseCase deactivateRecurringUseCase;
  final DeleteRecurringUseCase deleteRecurringUseCase;
  final RecurringTransactionService recurringTransactionService;

  RecurringTransactionBloc({
    required this.getAllRecurringTransactionsUseCase,
    required this.getActiveRecurringTransactionsUseCase,
    required this.createRecurringTransactionUseCase,
    required this.updateRecurringTransactionUseCase,
    required this.activateRecurringUseCase,
    required this.deactivateRecurringUseCase,
    required this.deleteRecurringUseCase,
    required this.recurringTransactionService,
  }) : super(RecurringTransactionInitial()) {
    on<LoadRecurringTransactions>(_onLoadRecurringTransactions);
    on<LoadActiveRecurringTransactions>(_onLoadActiveRecurringTransactions);
    on<CreateRecurringTransaction>(_onCreateRecurringTransaction);
    on<UpdateRecurringTransaction>(_onUpdateRecurringTransaction);
    on<ActivateRecurring>(_onActivateRecurring);
    on<DeactivateRecurring>(_onDeactivateRecurring);
    on<DeleteRecurring>(_onDeleteRecurring);
    on<RefreshRecurringTransactions>(_onRefreshRecurringTransactions);
    on<ProcessPendingRecurring>(_onProcessPendingRecurring);
  }

  /// Handler: Load tất cả recurring transactions
  Future<void> _onLoadRecurringTransactions(
    LoadRecurringTransactions event,
    Emitter<RecurringTransactionState> emit,
  ) async {
    emit(RecurringTransactionLoading());

    final result = await getAllRecurringTransactionsUseCase(NoParams());

    result.fold(
      (failure) => emit(RecurringTransactionError(
        message: _getFailureMessage(failure),
      )),
      (recurrings) => emit(RecurringTransactionLoaded(recurrings: recurrings)),
    );
  }

  /// Handler: Load active recurring transactions
  Future<void> _onLoadActiveRecurringTransactions(
    LoadActiveRecurringTransactions event,
    Emitter<RecurringTransactionState> emit,
  ) async {
    emit(RecurringTransactionLoading());

    final result = await getActiveRecurringTransactionsUseCase(NoParams());

    result.fold(
      (failure) => emit(RecurringTransactionError(
        message: _getFailureMessage(failure),
      )),
      (recurrings) => emit(RecurringTransactionLoaded(recurrings: recurrings)),
    );
  }

  /// Handler: Create recurring transaction
  Future<void> _onCreateRecurringTransaction(
    CreateRecurringTransaction event,
    Emitter<RecurringTransactionState> emit,
  ) async {
    final previousState = state;
    emit(RecurringTransactionActionInProgress());

    final result = await createRecurringTransactionUseCase(
      CreateRecurringTransactionParams(recurring: event.recurring),
    );

    result.fold(
      (failure) {
        emit(RecurringTransactionError(
          message: _getFailureMessage(failure),
        ));
        if (previousState is RecurringTransactionLoaded) {
          emit(previousState);
        }
      },
      (_) {
        emit(const RecurringTransactionActionSuccess(
          message: 'Tạo giao dịch định kỳ thành công',
        ));
        add(const LoadRecurringTransactions());
      },
    );
  }

  /// Handler: Update recurring transaction
  Future<void> _onUpdateRecurringTransaction(
    UpdateRecurringTransaction event,
    Emitter<RecurringTransactionState> emit,
  ) async {
    final previousState = state;
    emit(RecurringTransactionActionInProgress());

    final result = await updateRecurringTransactionUseCase(
      UpdateRecurringTransactionParams(recurring: event.recurring),
    );

    result.fold(
      (failure) {
        emit(RecurringTransactionError(
          message: _getFailureMessage(failure),
        ));
        if (previousState is RecurringTransactionLoaded) {
          emit(previousState);
        }
      },
      (_) {
        emit(const RecurringTransactionActionSuccess(
          message: 'Cập nhật thành công',
        ));
        add(const LoadRecurringTransactions());
      },
    );
  }

  /// Handler: Activate recurring
  Future<void> _onActivateRecurring(
    ActivateRecurring event,
    Emitter<RecurringTransactionState> emit,
  ) async {
    final previousState = state;
    emit(RecurringTransactionActionInProgress());

    final result = await activateRecurringUseCase(
      ActivateRecurringParams(id: event.id),
    );

    result.fold(
      (failure) {
        emit(RecurringTransactionError(
          message: _getFailureMessage(failure),
        ));
        if (previousState is RecurringTransactionLoaded) {
          emit(previousState);
        }
      },
      (_) {
        emit(const RecurringTransactionActionSuccess(
          message: 'Đã kích hoạt lại',
        ));
        add(const LoadRecurringTransactions());
      },
    );
  }

  /// Handler: Deactivate recurring
  Future<void> _onDeactivateRecurring(
    DeactivateRecurring event,
    Emitter<RecurringTransactionState> emit,
  ) async {
    final previousState = state;
    emit(RecurringTransactionActionInProgress());

    final result = await deactivateRecurringUseCase(
      DeactivateRecurringParams(id: event.id),
    );

    result.fold(
      (failure) {
        emit(RecurringTransactionError(
          message: _getFailureMessage(failure),
        ));
        if (previousState is RecurringTransactionLoaded) {
          emit(previousState);
        }
      },
      (_) {
        emit(const RecurringTransactionActionSuccess(
          message: 'Đã tạm dừng',
        ));
        add(const LoadRecurringTransactions());
      },
    );
  }

  /// Handler: Delete recurring
  Future<void> _onDeleteRecurring(
    DeleteRecurring event,
    Emitter<RecurringTransactionState> emit,
  ) async {
    final previousState = state;
    emit(RecurringTransactionActionInProgress());

    final result = await deleteRecurringUseCase(
      DeleteRecurringParams(id: event.id),
    );

    result.fold(
      (failure) {
        emit(RecurringTransactionError(
          message: _getFailureMessage(failure),
        ));
        if (previousState is RecurringTransactionLoaded) {
          emit(previousState);
        }
      },
      (_) {
        emit(const RecurringTransactionActionSuccess(
          message: 'Xóa thành công',
        ));
        add(const LoadRecurringTransactions());
      },
    );
  }

  /// Handler: Refresh recurring transactions
  Future<void> _onRefreshRecurringTransactions(
    RefreshRecurringTransactions event,
    Emitter<RecurringTransactionState> emit,
  ) async {
    add(const LoadRecurringTransactions());
  }

  /// Handler: Process pending recurring transactions
  Future<void> _onProcessPendingRecurring(
    ProcessPendingRecurring event,
    Emitter<RecurringTransactionState> emit,
  ) async {
    final result = await recurringTransactionService.processRecurringTransactions();

    result.fold(
      (failure) {
        final message = failure is CacheFailure
            ? failure.message ?? 'Có lỗi xảy ra'
            : 'Có lỗi xảy ra';
        emit(RecurringTransactionError(message: message));
      },
      (generatedCount) {
        emit(RecurringTransactionProcessed(generatedCount: generatedCount));
        // Reload sau khi process
        add(const LoadRecurringTransactions());
      },
    );
  }

  /// Helper: Get failure message
  String _getFailureMessage(Failure failure) {
    if (failure is CacheFailure) {
      return failure.message ?? 'Có lỗi xảy ra';
    }
    return 'Có lỗi xảy ra';
  }
}
