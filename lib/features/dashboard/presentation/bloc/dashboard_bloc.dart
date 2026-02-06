import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// Bloc quản lý state của Dashboard
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummaryUseCase getDashboardSummaryUseCase;
  bool _isTotalBalanceActive = false;

  DashboardBloc({
    required this.getDashboardSummaryUseCase,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<ChangeDateFilter>(_onChangeDateFilter);
    on<ToggleTotalBalance>(_onToggleTotalBalance);
  }

  /// Xử lý event LoadDashboard
  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    // Tính toán start và end date dựa trên filter
    final dateRange = _getDateRange(
      event.filter,
      customStartDate: event.customStartDate,
      customEndDate: event.customEndDate,
    );

    // Gọi usecase
    final result = await getDashboardSummaryUseCase(
      GetDashboardParams(
        startDate: dateRange['start'],
        endDate: dateRange['end'],
      ),
    );

    // Emit state tương ứng
    result.fold(
      (failure) => emit(DashboardError(
        message: failure is CacheFailure
            ? 'Lỗi tải dữ liệu từ bộ nhớ'
            : 'Đã xảy ra lỗi',
      )),
      (summary) => emit(DashboardLoaded(
        summary: summary,
        currentFilter: event.filter,
        isTotalBalanceActive: _isTotalBalanceActive,
      )),
    );
  }

  /// Xử lý event RefreshDashboard
  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // Lấy filter hiện tại nếu có
    DateFilter currentFilter = DateFilter.thisMonth;
    if (state is DashboardLoaded) {
      currentFilter = (state as DashboardLoaded).currentFilter;
    }

    // Load lại với filter hiện tại
    add(LoadDashboard(filter: currentFilter));
  }

  /// Xử lý event ChangeDateFilter
  Future<void> _onChangeDateFilter(
    ChangeDateFilter event,
    Emitter<DashboardState> emit,
  ) async {
    // Load lại với filter mới
    add(LoadDashboard(
      filter: event.filter,
      customStartDate: event.customStartDate,
      customEndDate: event.customEndDate,
    ));
  }

  void _onToggleTotalBalance(
    ToggleTotalBalance event,
    Emitter<DashboardState> emit,
  ) {
    _isTotalBalanceActive = event.isActive;
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(DashboardLoaded(
        summary: currentState.summary,
        currentFilter: currentState.currentFilter,
        isTotalBalanceActive: _isTotalBalanceActive,
      ));
    }
  }

  /// Helper: Tính toán khoảng thời gian dựa trên filter
  Map<String, DateTime?> _getDateRange(
    DateFilter filter, {
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    switch (filter) {
      case DateFilter.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case DateFilter.thisWeek:
        // Bắt đầu tuần từ thứ 2
        final weekday = now.weekday;
        startDate = now.subtract(Duration(days: weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = startDate
            .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;

      case DateFilter.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;

      case DateFilter.thisYear:
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31, 23, 59, 59);
        break;

      case DateFilter.custom:
        startDate = customStartDate;
        endDate = customEndDate;
        break;
    }

    return {
      'start': startDate,
      'end': endDate,
    };
  }
}
