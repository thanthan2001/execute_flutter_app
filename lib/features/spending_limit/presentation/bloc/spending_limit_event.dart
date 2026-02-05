import 'package:equatable/equatable.dart';
import '../../domain/entities/spending_limit_entity.dart';

/// Base event cho SpendingLimit feature
abstract class SpendingLimitEvent extends Equatable {
  const SpendingLimitEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Load active spending limit theo period
class LoadSpendingLimit extends SpendingLimitEvent {
  final SpendingLimitPeriod period;

  const LoadSpendingLimit({required this.period});

  @override
  List<Object?> get props => [period];
}

/// Event: Load tất cả spending limits
class LoadAllSpendingLimits extends SpendingLimitEvent {
  const LoadAllSpendingLimits();
}

/// Event: Set spending limit (tạo mới hoặc cập nhật)
class SetSpendingLimit extends SpendingLimitEvent {
  final SpendingLimitEntity limit;

  const SetSpendingLimit({required this.limit});

  @override
  List<Object?> get props => [limit];
}

/// Event: Xóa spending limit
class DeleteSpendingLimit extends SpendingLimitEvent {
  final SpendingLimitPeriod period;

  const DeleteSpendingLimit({required this.period});

  @override
  List<Object?> get props => [period];
}

/// Event: Load spending limit status (với chi tiêu thực tế)
class LoadSpendingLimitStatus extends SpendingLimitEvent {
  final SpendingLimitPeriod period;

  const LoadSpendingLimitStatus({required this.period});

  @override
  List<Object?> get props => [period];
}

/// Event: Toggle active/inactive spending limit
class ToggleSpendingLimitActive extends SpendingLimitEvent {
  final SpendingLimitPeriod period;
  final bool isActive;

  const ToggleSpendingLimitActive({
    required this.period,
    required this.isActive,
  });

  @override
  List<Object?> get props => [period, isActive];
}

/// Event: Refresh spending limits
class RefreshSpendingLimits extends SpendingLimitEvent {
  const RefreshSpendingLimits();
}
