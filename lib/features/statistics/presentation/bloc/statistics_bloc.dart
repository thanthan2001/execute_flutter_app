import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/usecases/get_statistics_summary_usecase.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

/// Bloc quản lý state của Statistics
class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetStatisticsSummaryUseCase getStatisticsSummaryUseCase;

  // Filter tạm để user chỉnh sửa trong modal (chưa apply)
  FilterOptions _pendingFilter = FilterOptions.defaultFilter();

  StatisticsBloc({
    required this.getStatisticsSummaryUseCase,
  }) : super(const StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
    on<ChangeDateMode>(_onChangeDateMode);
    on<UpdateFilterOptions>(_onUpdateFilterOptions);
    on<ApplyFilter>(_onApplyFilter);
    on<ResetFilter>(_onResetFilter);
    on<RefreshStatistics>(_onRefreshStatistics);
  }

  /// Helper: Convert Failure to error message
  String _getErrorMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message ?? 'Server error';
    } else if (failure is CacheFailure) {
      return failure.message ?? 'Cache error';
    }
    return 'Unknown error';
  }

  /// Xử lý event LoadStatistics
  /// Load thống kê với filter mặc định (tháng hiện tại)
  Future<void> _onLoadStatistics(
    LoadStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    final defaultFilter = FilterOptions.defaultFilter();
    _pendingFilter = defaultFilter;

    final result = await getStatisticsSummaryUseCase(defaultFilter);

    result.fold(
      (failure) => emit(StatisticsError(message: _getErrorMessage(failure))),
      (summary) => emit(StatisticsLoaded(
        activeFilter: defaultFilter,
        summary: summary,
      )),
    );
  }

  /// Xử lý event ChangeDateMode
  /// Cập nhật chế độ filter (Day/Month/Year/Range)
  void _onChangeDateMode(
    ChangeDateMode event,
    Emitter<StatisticsState> emit,
  ) {
    final now = DateTime.now();

    // Tạo filter mới dựa trên mode
    switch (event.mode) {
      case DateMode.day:
        _pendingFilter = FilterOptions(
          dateMode: DateMode.day,
          singleDate: DateTime(now.year, now.month, now.day),
          type: _pendingFilter.type,
          categoryId: _pendingFilter.categoryId,
        );
        break;

      case DateMode.month:
        _pendingFilter = FilterOptions(
          dateMode: DateMode.month,
          month: now.month,
          year: now.year,
          type: _pendingFilter.type,
          categoryId: _pendingFilter.categoryId,
        );
        break;

      case DateMode.year:
        _pendingFilter = FilterOptions(
          dateMode: DateMode.year,
          year: now.year,
          type: _pendingFilter.type,
          categoryId: _pendingFilter.categoryId,
        );
        break;

      case DateMode.range:
        final startDate = DateTime(now.year, now.month, 1);
        final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        _pendingFilter = FilterOptions(
          dateMode: DateMode.range,
          startDate: startDate,
          endDate: endDate,
          type: _pendingFilter.type,
          categoryId: _pendingFilter.categoryId,
        );
        break;
    }

    // Không emit state mới, chỉ update internal state
    // UI sẽ cập nhật khi user bấm Apply
  }

  /// Xử lý event UpdateFilterOptions
  /// Cập nhật filter options (user đang chỉnh sửa)
  void _onUpdateFilterOptions(
    UpdateFilterOptions event,
    Emitter<StatisticsState> emit,
  ) {
    _pendingFilter = event.options;
    // Không emit state, chỉ lưu tạm
  }

  /// Xử lý event ApplyFilter
  /// Áp dụng filter và reload data
  Future<void> _onApplyFilter(
    ApplyFilter event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    final result = await getStatisticsSummaryUseCase(event.options);

    result.fold(
      (failure) => emit(StatisticsError(message: _getErrorMessage(failure))),
      (summary) {
        _pendingFilter = event.options; // Sync pending filter
        emit(StatisticsLoaded(
          activeFilter: event.options,
          summary: summary,
        ));
      },
    );
  }

  /// Xử lý event ResetFilter
  /// Reset về filter mặc định (tháng hiện tại)
  Future<void> _onResetFilter(
    ResetFilter event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    final defaultFilter = FilterOptions.defaultFilter();
    _pendingFilter = defaultFilter;

    final result = await getStatisticsSummaryUseCase(defaultFilter);

    result.fold(
      (failure) => emit(StatisticsError(message: _getErrorMessage(failure))),
      (summary) => emit(StatisticsLoaded(
        activeFilter: defaultFilter,
        summary: summary,
      )),
    );
  }

  /// Xử lý event RefreshStatistics
  /// Refresh với filter hiện tại
  Future<void> _onRefreshStatistics(
    RefreshStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    if (state is! StatisticsLoaded) return;

    final currentFilter = (state as StatisticsLoaded).activeFilter;

    final result = await getStatisticsSummaryUseCase(currentFilter);

    result.fold(
      (failure) => emit(StatisticsError(message: _getErrorMessage(failure))),
      (summary) => emit(StatisticsLoaded(
        activeFilter: currentFilter,
        summary: summary,
      )),
    );
  }

  /// Getter để UI có thể đọc pending filter
  FilterOptions get pendingFilter => _pendingFilter;
}
