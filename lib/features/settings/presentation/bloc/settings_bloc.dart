import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/clear_all_transactions_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// Bloc quản lý state cho Settings screen
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final ClearAllTransactionsUseCase clearAllTransactionsUseCase;

  SettingsBloc({
    required this.clearAllTransactionsUseCase,
  }) : super(const SettingsInitial()) {
    on<ClearAllTransactionsEvent>(_onClearAllTransactions);
  }

  /// Xử lý event xóa toàn bộ giao dịch
  Future<void> _onClearAllTransactions(
    ClearAllTransactionsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const ClearingTransactions());

    final result = await clearAllTransactionsUseCase(NoParams());

    result.fold(
      (failure) => emit(ClearTransactionsError(_getErrorMessage(failure))),
      (_) => emit(const TransactionsCleared()),
    );
  }

  /// Helper để lấy error message từ Failure
  String _getErrorMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message ?? 'Lỗi từ server';
    } else if (failure is CacheFailure) {
      return failure.message ?? 'Lỗi cache';
    } else {
      return 'Đã xảy ra lỗi không xác định';
    }
  }
}
