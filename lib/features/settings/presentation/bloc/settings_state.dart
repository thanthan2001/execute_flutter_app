import 'package:equatable/equatable.dart';

/// Base state cho SettingsBloc
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// State khởi tạo
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// State đang xóa dữ liệu
class ClearingTransactions extends SettingsState {
  const ClearingTransactions();
}

/// State xóa thành công
class TransactionsCleared extends SettingsState {
  const TransactionsCleared();
}

/// State xóa thất bại
class ClearTransactionsError extends SettingsState {
  final String message;

  const ClearTransactionsError(this.message);

  @override
  List<Object?> get props => [message];
}
