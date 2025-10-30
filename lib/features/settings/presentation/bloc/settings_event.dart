import 'package:equatable/equatable.dart';

/// Base event cho SettingsBloc
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Event để xóa toàn bộ dữ liệu giao dịch
class ClearAllTransactionsEvent extends SettingsEvent {
  const ClearAllTransactionsEvent();
}
