import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/filter_options.dart';
import '../entities/statistics_summary.dart';

/// Repository interface cho Statistics
abstract class StatisticsRepository {
  /// Lấy thống kê dựa trên FilterOptions
  /// Trả về Either<Failure, StatisticsSummary>
  Future<Either<Failure, StatisticsSummary>> getStatistics({
    required FilterOptions filter,
  });
}
