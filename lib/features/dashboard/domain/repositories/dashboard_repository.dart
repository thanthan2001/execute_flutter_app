import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/dashboard_summary.dart';

/// Repository interface cho Dashboard
abstract class DashboardRepository {
  /// Lấy tổng quan Dashboard với filter thời gian
  Future<Either<Failure, DashboardSummary>> getDashboardSummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Xóa toàn bộ dữ liệu giao dịch
  Future<Either<Failure, void>> clearAllTransactions();
}
