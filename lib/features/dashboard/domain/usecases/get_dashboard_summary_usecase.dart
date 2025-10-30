import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

/// UseCase để lấy dữ liệu Dashboard
class GetDashboardSummaryUseCase
    implements UseCase<DashboardSummary, GetDashboardParams> {
  final DashboardRepository repository;

  GetDashboardSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, DashboardSummary>> call(
      GetDashboardParams params) async {
    return await repository.getDashboardSummary(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

/// Parameters cho GetDashboardSummaryUseCase
class GetDashboardParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;

  const GetDashboardParams({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}
