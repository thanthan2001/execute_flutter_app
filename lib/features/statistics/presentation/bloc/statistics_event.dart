import 'package:equatable/equatable.dart';
import '../../domain/entities/filter_options.dart';

/// Base class cho tất cả Statistics Events
abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Load thống kê với filter hiện tại
class LoadStatistics extends StatisticsEvent {
  const LoadStatistics();
}

/// Event: Thay đổi chế độ filter (Day/Month/Year/Range)
class ChangeDateMode extends StatisticsEvent {
  final DateMode mode;

  const ChangeDateMode({required this.mode});

  @override
  List<Object?> get props => [mode];
}

/// Event: Cập nhật filter options (chưa apply)
class UpdateFilterOptions extends StatisticsEvent {
  final FilterOptions options;

  const UpdateFilterOptions({required this.options});

  @override
  List<Object?> get props => [options];
}

/// Event: Áp dụng filter và reload data
class ApplyFilter extends StatisticsEvent {
  final FilterOptions options;

  const ApplyFilter({required this.options});

  @override
  List<Object?> get props => [options];
}

/// Event: Reset filter về mặc định (tháng hiện tại)
class ResetFilter extends StatisticsEvent {
  const ResetFilter();
}

/// Event: Refresh thống kê (pull-to-refresh)
class RefreshStatistics extends StatisticsEvent {
  const RefreshStatistics();
}
