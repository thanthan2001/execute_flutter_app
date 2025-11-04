import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/get_all_categories_usecase.dart';
import '../../domain/usecases/get_all_transactions_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

/// Bloc quản lý state của Transaction
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetAllTransactionsUseCase getAllTransactionsUseCase;
  final GetAllCategoriesUseCase getAllCategoriesUseCase;
  final AddTransactionUseCase addTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;

  TransactionBloc({
    required this.getAllTransactionsUseCase,
    required this.getAllCategoriesUseCase,
    required this.addTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
  }) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<ChangeTransactionFilter>(_onChangeTransactionFilter);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<RefreshTransactions>(_onRefreshTransactions);
  }

  /// Xử lý event LoadTransactions
  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());

    // Load transactions và categories song song
    final transactionsResult = await getAllTransactionsUseCase(NoParams());
    final categoriesResult = await getAllCategoriesUseCase(NoParams());

    // Kiểm tra kết quả
    if (transactionsResult.isLeft() || categoriesResult.isLeft()) {
      emit(const TransactionError(message: 'Không thể tải dữ liệu'));
      return;
    }

    final transactions = transactionsResult.getOrElse(() => []);
    final categories = categoriesResult.getOrElse(() => []);

    emit(TransactionLoaded(
      transactions: transactions,
      categories: categories,
      currentFilter: TransactionFilter.all,
    ));
  }

  /// Xử lý event ChangeTransactionFilter
  Future<void> _onChangeTransactionFilter(
    ChangeTransactionFilter event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;

    // Load lại transactions với filter
    final transactionsResult = await getAllTransactionsUseCase(NoParams());

    if (transactionsResult.isLeft()) {
      emit(const TransactionError(message: 'Không thể tải dữ liệu'));
      return;
    }

    var transactions = transactionsResult.getOrElse(() => []);

    // Áp dụng filter
    if (event.filter == TransactionFilter.income) {
      transactions =
          transactions.where((t) => t.type == TransactionType.income).toList();
    } else if (event.filter == TransactionFilter.expense) {
      transactions =
          transactions.where((t) => t.type == TransactionType.expense).toList();
    }

    emit(currentState.copyWith(
      transactions: transactions,
      currentFilter: event.filter,
    ));
  }

  /// Xử lý event AddTransaction
  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    // Lưu state hiện tại để restore nếu có lỗi
    final previousState = state;

    emit(TransactionActionInProgress());

    final result = await addTransactionUseCase(
      AddTransactionParams(transaction: event.transaction),
    );

    result.fold(
      (failure) {
        emit(const TransactionError(message: 'Không thể thêm giao dịch'));
        // Restore previous state
        if (previousState is TransactionLoaded) {
          emit(previousState);
        }
      },
      (_) async {
        emit(const TransactionActionSuccess(
            message: 'Thêm giao dịch thành công'));
        // Reload transactions
        add(const LoadTransactions());
      },
    );
  }

  /// Xử lý event UpdateTransaction
  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    final previousState = state;

    emit(TransactionActionInProgress());

    final result = await updateTransactionUseCase(
      UpdateTransactionParams(transaction: event.transaction),
    );

    result.fold(
      (failure) {
        emit(const TransactionError(message: 'Không thể cập nhật giao dịch'));
        if (previousState is TransactionLoaded) {
          emit(previousState);
        }
      },
      (_) async {
        emit(const TransactionActionSuccess(
            message: 'Cập nhật giao dịch thành công'));
        add(const LoadTransactions());
      },
    );
  }

  /// Xử lý event DeleteTransaction
  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    final previousState = state;

    emit(TransactionActionInProgress());

    final result = await deleteTransactionUseCase(
      DeleteTransactionParams(id: event.id),
    );

    result.fold(
      (failure) {
        emit(const TransactionError(message: 'Không thể xóa giao dịch'));
        if (previousState is TransactionLoaded) {
          emit(previousState);
        }
      },
      (_) async {
        emit(const TransactionActionSuccess(
            message: 'Xóa giao dịch thành công'));
        add(const LoadTransactions());
      },
    );
  }

  /// Xử lý event RefreshTransactions
  Future<void> _onRefreshTransactions(
    RefreshTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    add(const LoadTransactions());
  }
}
