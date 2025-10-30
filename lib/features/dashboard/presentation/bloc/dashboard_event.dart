import 'package:equatable/equatable.dart';
import 'dashboard_state.dart';

/// Abstract event cho Dashboard
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event load Dashboard với filter
class LoadDashboard extends DashboardEvent {
  final DateFilter filter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const LoadDashboard({
    this.filter = DateFilter.thisMonth,
    this.customStartDate,
    this.customEndDate,
  });

  @override
  List<Object?> get props => [filter, customStartDate, customEndDate];
}

/// Event refresh Dashboard
class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();
}

/// Event thay đổi filter
class ChangeDateFilter extends DashboardEvent {
  final DateFilter filter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const ChangeDateFilter({
    required this.filter,
    this.customStartDate,
    this.customEndDate,
  });

  @override
  List<Object?> get props => [filter, customStartDate, customEndDate];
}
