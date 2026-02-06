import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_spending_limit_status_usecase.dart';
import '../../domain/usecases/delete_spending_limit_usecase.dart';
import '../../domain/usecases/get_all_spending_limits_usecase.dart';
import '../../domain/usecases/get_spending_limit_usecase.dart';
import '../../domain/usecases/set_spending_limit_usecase.dart';
import 'spending_limit_event.dart';
import 'spending_limit_state.dart';

/// BLoC quản lý state cho SpendingLimit feature
class SpendingLimitBloc extends Bloc<SpendingLimitEvent, SpendingLimitState> {
  final GetSpendingLimitUseCase getSpendingLimitUseCase;
  final GetAllSpendingLimitsUseCase getAllSpendingLimitsUseCase;
  final SetSpendingLimitUseCase setSpendingLimitUseCase;
  final DeleteSpendingLimitUseCase deleteSpendingLimitUseCase;
  final CheckSpendingLimitStatusUseCase checkSpendingLimitStatusUseCase;

  SpendingLimitBloc({
    required this.getSpendingLimitUseCase,
    required this.getAllSpendingLimitsUseCase,
    required this.setSpendingLimitUseCase,
    required this.deleteSpendingLimitUseCase,
    required this.checkSpendingLimitStatusUseCase,
  }) : super(SpendingLimitInitial()) {
    on<LoadSpendingLimit>(_onLoadSpendingLimit);
    on<LoadAllSpendingLimits>(_onLoadAllSpendingLimits);
    on<SetSpendingLimit>(_onSetSpendingLimit);
    on<DeleteSpendingLimit>(_onDeleteSpendingLimit);
    on<LoadSpendingLimitStatus>(_onLoadSpendingLimitStatus);
    on<ToggleSpendingLimitActive>(_onToggleSpendingLimitActive);
    on<RefreshSpendingLimits>(_onRefreshSpendingLimits);
  }

  /// Handler: Load spending limit theo period
  Future<void> _onLoadSpendingLimit(
    LoadSpendingLimit event,
    Emitter<SpendingLimitState> emit,
  ) async {
    emit(SpendingLimitLoading());

    // Load limit
    final limitResult = await getSpendingLimitUseCase(
      GetSpendingLimitParams(period: event.period),
    );

    await limitResult.fold(
      (failure) async {
        emit(SpendingLimitError(
          message: failure is CacheFailure
              ? failure.message ?? 'Không thể tải giới hạn chi tiêu'
              : 'Có lỗi xảy ra',
        ));
      },
      (limit) async {
        // Load status nếu có limit
        if (limit != null && limit.isActive) {
          final statusResult = await checkSpendingLimitStatusUseCase(
            CheckSpendingLimitStatusParams(period: event.period),
          );

          statusResult.fold(
            (failure) => emit(SpendingLimitLoaded(limit: limit, status: null)),
            (status) => emit(SpendingLimitLoaded(limit: limit, status: status)),
          );
        } else {
          emit(SpendingLimitLoaded(limit: limit, status: null));
        }
      },
    );
  }

  /// Handler: Load tất cả spending limits
  Future<void> _onLoadAllSpendingLimits(
    LoadAllSpendingLimits event,
    Emitter<SpendingLimitState> emit,
  ) async {
    emit(SpendingLimitLoading());

    final result = await getAllSpendingLimitsUseCase(NoParams());

    result.fold(
      (failure) => emit(SpendingLimitError(
        message: failure is CacheFailure
            ? failure.message ?? 'Không thể tải danh sách giới hạn chi tiêu'
            : 'Có lỗi xảy ra',
      )),
      (limits) => emit(AllSpendingLimitsLoaded(limits: limits)),
    );
  }

  /// Handler: Set spending limit
  Future<void> _onSetSpendingLimit(
    SetSpendingLimit event,
    Emitter<SpendingLimitState> emit,
  ) async {
    final previousState = state;
    emit(SpendingLimitActionInProgress());

    final result = await setSpendingLimitUseCase(
      SetSpendingLimitParams(limit: event.limit),
    );

    result.fold(
      (failure) {
        emit(SpendingLimitError(
          message: failure is CacheFailure
              ? failure.message ?? 'Không thể lưu giới hạn chi tiêu'
              : 'Có lỗi xảy ra',
        ));
        // Restore previous state
        if (previousState is SpendingLimitLoaded) {
          emit(previousState);
        }
      },
      (_) {
        emit(const SpendingLimitActionSuccess(
          message: 'Lưu giới hạn chi tiêu thành công',
        ));
        // Reload limit
        add(LoadSpendingLimit(period: event.limit.period));
      },
    );
  }

  /// Handler: Delete spending limit
  Future<void> _onDeleteSpendingLimit(
    DeleteSpendingLimit event,
    Emitter<SpendingLimitState> emit,
  ) async {
    final previousState = state;
    emit(SpendingLimitActionInProgress());

    final result = await deleteSpendingLimitUseCase(
      DeleteSpendingLimitParams(period: event.period),
    );

    result.fold(
      (failure) {
        emit(SpendingLimitError(
          message: failure is CacheFailure
              ? failure.message ?? 'Không thể xóa giới hạn chi tiêu'
              : 'Có lỗi xảy ra',
        ));
        // Restore previous state
        if (previousState is SpendingLimitLoaded) {
          emit(previousState);
        }
      },
      (_) {
        emit(const SpendingLimitActionSuccess(
          message: 'Xóa giới hạn chi tiêu thành công',
        ));
        // Reload để clear
        add(LoadSpendingLimit(period: event.period));
      },
    );
  }

  /// Handler: Load spending limit status
  Future<void> _onLoadSpendingLimitStatus(
    LoadSpendingLimitStatus event,
    Emitter<SpendingLimitState> emit,
  ) async {
    emit(SpendingLimitLoading());

    final result = await checkSpendingLimitStatusUseCase(
      CheckSpendingLimitStatusParams(period: event.period),
    );

    result.fold(
      (failure) => emit(SpendingLimitError(
        message: failure is CacheFailure
            ? failure.message ?? 'Không thể kiểm tra trạng thái chi tiêu'
            : 'Có lỗi xảy ra',
      )),
      (status) => emit(SpendingLimitStatusLoaded(status: status)),
    );
  }

  /// Handler: Toggle active/inactive
  Future<void> _onToggleSpendingLimitActive(
    ToggleSpendingLimitActive event,
    Emitter<SpendingLimitState> emit,
  ) async {
    // Lấy limit hiện tại
    final limitResult = await getSpendingLimitUseCase(
      GetSpendingLimitParams(period: event.period),
    );

    await limitResult.fold(
      (failure) async {
        emit(const SpendingLimitError(
          message: 'Không thể cập nhật trạng thái',
        ));
      },
      (limit) async {
        if (limit == null) {
          emit(const SpendingLimitError(
            message: 'Không tìm thấy giới hạn chi tiêu',
          ));
          return;
        }

        // Cập nhật isActive
        final updatedLimit = limit.copyWith(isActive: event.isActive);

        // Set lại limit
        add(SetSpendingLimit(limit: updatedLimit));
      },
    );
  }

  /// Handler: Refresh spending limits
  Future<void> _onRefreshSpendingLimits(
    RefreshSpendingLimits event,
    Emitter<SpendingLimitState> emit,
  ) async {
    add(const LoadAllSpendingLimits());
  }
}
