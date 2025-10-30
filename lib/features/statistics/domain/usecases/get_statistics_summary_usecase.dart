import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/filter_options.dart';
import '../entities/statistics_summary.dart';
import '../repositories/statistics_repository.dart';

/// UseCase để lấy thống kê dựa trên FilterOptions
class GetStatisticsSummaryUseCase
    implements UseCase<StatisticsSummary, FilterOptions> {
  final StatisticsRepository repository;

  GetStatisticsSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, StatisticsSummary>> call(FilterOptions params) async {
    return await repository.getStatistics(filter: params);
  }
}
