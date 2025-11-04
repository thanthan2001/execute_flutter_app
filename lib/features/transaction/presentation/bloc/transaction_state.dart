import 'package:equatable/equatable.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';

/// Abstract state cho Transaction
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

/// State ban đầu
class TransactionInitial extends TransactionState {}

/// State đang load dữ liệu
class TransactionLoading extends TransactionState {}

/// State load thành công với danh sách transactions
class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  final List<CategoryEntity> categories;
  final TransactionFilter currentFilter;

  const TransactionLoaded({
    required this.transactions,
    required this.categories,
    this.currentFilter = TransactionFilter.all,
  });

  @override
  List<Object?> get props => [transactions, categories, currentFilter];

  /// Copy with để cập nhật state
  TransactionLoaded copyWith({
    List<TransactionEntity>? transactions,
    List<CategoryEntity>? categories,
    TransactionFilter? currentFilter,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

/// State khi đang thực hiện action (add/update/delete)
class TransactionActionInProgress extends TransactionState {}

/// State khi action thành công
class TransactionActionSuccess extends TransactionState {
  final String message;

  const TransactionActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State khi có lỗi
class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Enum cho filter transactions
enum TransactionFilter {
  all, // Tất cả
  income, // Chỉ thu
  expense, // Chỉ chi
}
