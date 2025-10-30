import 'package:equatable/equatable.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import 'transaction_state.dart';

/// Abstract event cho Transaction
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Event load tất cả transactions
class LoadTransactions extends TransactionEvent {
  const LoadTransactions();
}

/// Event thay đổi filter
class ChangeTransactionFilter extends TransactionEvent {
  final TransactionFilter filter;

  const ChangeTransactionFilter({required this.filter});

  @override
  List<Object?> get props => [filter];
}

/// Event thêm transaction mới
class AddTransaction extends TransactionEvent {
  final TransactionEntity transaction;

  const AddTransaction({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

/// Event cập nhật transaction
class UpdateTransaction extends TransactionEvent {
  final TransactionEntity transaction;

  const UpdateTransaction({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

/// Event xóa transaction
class DeleteTransaction extends TransactionEvent {
  final String id;

  const DeleteTransaction({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event refresh danh sách transactions
class RefreshTransactions extends TransactionEvent {
  const RefreshTransactions();
}
