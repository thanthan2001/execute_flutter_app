import 'package:equatable/equatable.dart';
import '../../domain/entities/recurring_transaction_entity.dart';

/// Base event cho RecurringTransaction feature
abstract class RecurringTransactionEvent extends Equatable {
  const RecurringTransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Load tất cả recurring transactions
class LoadRecurringTransactions extends RecurringTransactionEvent {
  const LoadRecurringTransactions();
}

/// Event: Load active recurring transactions
class LoadActiveRecurringTransactions extends RecurringTransactionEvent {
  const LoadActiveRecurringTransactions();
}

/// Event: Tạo recurring transaction mới
class CreateRecurringTransaction extends RecurringTransactionEvent {
  final RecurringTransactionEntity recurring;

  const CreateRecurringTransaction({required this.recurring});

  @override
  List<Object?> get props => [recurring];
}

/// Event: Cập nhật recurring transaction
class UpdateRecurringTransaction extends RecurringTransactionEvent {
  final RecurringTransactionEntity recurring;

  const UpdateRecurringTransaction({required this.recurring});

  @override
  List<Object?> get props => [recurring];
}

/// Event: Activate recurring transaction
class ActivateRecurring extends RecurringTransactionEvent {
  final String id;

  const ActivateRecurring({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event: Deactivate recurring transaction
class DeactivateRecurring extends RecurringTransactionEvent {
  final String id;

  const DeactivateRecurring({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event: Xóa recurring transaction
class DeleteRecurring extends RecurringTransactionEvent {
  final String id;

  const DeleteRecurring({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event: Refresh recurring transactions
class RefreshRecurringTransactions extends RecurringTransactionEvent {
  const RefreshRecurringTransactions();
}

/// Event: Process pending recurring transactions (generate new transactions)
class ProcessPendingRecurring extends RecurringTransactionEvent {
  const ProcessPendingRecurring();
}
