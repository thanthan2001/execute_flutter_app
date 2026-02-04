import 'package:equatable/equatable.dart';
import '../../domain/entities/recurring_transaction_entity.dart';

/// Base state cho RecurringTransaction feature
abstract class RecurringTransactionState extends Equatable {
  const RecurringTransactionState();

  @override
  List<Object?> get props => [];
}

/// State ban đầu
class RecurringTransactionInitial extends RecurringTransactionState {}

/// State đang load dữ liệu
class RecurringTransactionLoading extends RecurringTransactionState {}

/// State load thành công với danh sách
class RecurringTransactionLoaded extends RecurringTransactionState {
  final List<RecurringTransactionEntity> recurrings;

  const RecurringTransactionLoaded({required this.recurrings});

  @override
  List<Object?> get props => [recurrings];

  RecurringTransactionLoaded copyWith({
    List<RecurringTransactionEntity>? recurrings,
  }) {
    return RecurringTransactionLoaded(
      recurrings: recurrings ?? this.recurrings,
    );
  }
}

/// State đang thực hiện action
class RecurringTransactionActionInProgress extends RecurringTransactionState {}

/// State action thành công
class RecurringTransactionActionSuccess extends RecurringTransactionState {
  final String message;

  const RecurringTransactionActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State có lỗi
class RecurringTransactionError extends RecurringTransactionState {
  final String message;

  const RecurringTransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State sau khi process pending thành công
class RecurringTransactionProcessed extends RecurringTransactionState {
  final int generatedCount; // Số lượng transaction đã được generate

  const RecurringTransactionProcessed({required this.generatedCount});

  @override
  List<Object?> get props => [generatedCount];
}
