import 'package:equatable/equatable.dart';
import '../../domain/entities/spending_limit_entity.dart';
import '../../domain/entities/spending_limit_status.dart';

/// Base state cho SpendingLimit feature
abstract class SpendingLimitState extends Equatable {
  const SpendingLimitState();

  @override
  List<Object?> get props => [];
}

/// State ban đầu
class SpendingLimitInitial extends SpendingLimitState {}

/// State đang load dữ liệu
class SpendingLimitLoading extends SpendingLimitState {}

/// State load spending limit thành công
class SpendingLimitLoaded extends SpendingLimitState {
  final SpendingLimitEntity? limit; // nullable nếu không có limit
  final SpendingLimitStatus? status; // nullable nếu không có status

  const SpendingLimitLoaded({
    this.limit,
    this.status,
  });

  @override
  List<Object?> get props => [limit, status];

  SpendingLimitLoaded copyWith({
    SpendingLimitEntity? limit,
    SpendingLimitStatus? status,
  }) {
    return SpendingLimitLoaded(
      limit: limit ?? this.limit,
      status: status ?? this.status,
    );
  }
}

/// State load tất cả spending limits thành công
class AllSpendingLimitsLoaded extends SpendingLimitState {
  final List<SpendingLimitEntity> limits;

  const AllSpendingLimitsLoaded({required this.limits});

  @override
  List<Object?> get props => [limits];
}

/// State đang thực hiện action (set/delete/toggle)
class SpendingLimitActionInProgress extends SpendingLimitState {}

/// State action thành công
class SpendingLimitActionSuccess extends SpendingLimitState {
  final String message;

  const SpendingLimitActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State có lỗi
class SpendingLimitError extends SpendingLimitState {
  final String message;

  const SpendingLimitError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State load status thành công
class SpendingLimitStatusLoaded extends SpendingLimitState {
  final SpendingLimitStatus? status;

  const SpendingLimitStatusLoaded({required this.status});

  @override
  List<Object?> get props => [status];
}
