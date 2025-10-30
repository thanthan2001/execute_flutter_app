import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_summary.dart';

/// Abstract state cho Dashboard
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// State ban đầu
class DashboardInitial extends DashboardState {}

/// State đang load dữ liệu
class DashboardLoading extends DashboardState {}

/// State load thành công
class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  final DateFilter currentFilter;

  const DashboardLoaded({
    required this.summary,
    required this.currentFilter,
  });

  @override
  List<Object?> get props => [summary, currentFilter];
}

/// State load thất bại
class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Enum cho các bộ lọc thời gian
enum DateFilter {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}
