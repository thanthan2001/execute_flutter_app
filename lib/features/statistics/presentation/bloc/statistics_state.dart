import 'package:equatable/equatable.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/entities/statistics_summary.dart';

/// Base class cho tất cả Statistics States
abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

/// State: Khởi tạo ban đầu
class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

/// State: Đang load thống kê
class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

/// State: Đã load xong thống kê
class StatisticsLoaded extends StatisticsState {
  final FilterOptions activeFilter; // Filter hiện tại đang áp dụng
  final StatisticsSummary summary; // Dữ liệu thống kê

  const StatisticsLoaded({
    required this.activeFilter,
    required this.summary,
  });

  @override
  List<Object?> get props => [activeFilter, summary];

  /// Copy với giá trị mới
  StatisticsLoaded copyWith({
    FilterOptions? activeFilter,
    StatisticsSummary? summary,
  }) {
    return StatisticsLoaded(
      activeFilter: activeFilter ?? this.activeFilter,
      summary: summary ?? this.summary,
    );
  }
}

/// State: Lỗi khi load thống kê
class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError({required this.message});

  @override
  List<Object?> get props => [message];
}
