import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/spending_limit_entity.dart';
import '../entities/spending_limit_status.dart';

/// Repository interface cho Spending Limit Management
abstract class SpendingLimitRepository {
  /// Tạo hoặc cập nhật spending limit
  /// - Nếu đã tồn tại limit cho period này → update
  /// - Nếu chưa → create mới
  Future<Either<Failure, void>> setLimit(SpendingLimitEntity limit);

  /// Lấy active limit theo period
  /// - Trả về limit đang active cho period đó
  /// - Trả về null nếu không có hoặc isActive = false
  Future<Either<Failure, SpendingLimitEntity?>> getActiveLimit(
    SpendingLimitPeriod period,
  );

  /// Xóa limit theo period
  Future<Either<Failure, void>> deleteLimit(SpendingLimitPeriod period);

  /// Lấy tất cả limits (bao gồm cả inactive)
  Future<Either<Failure, List<SpendingLimitEntity>>> getAllLimits();

  /// Lấy trạng thái của spending limit (so sánh với chi tiêu thực tế)
  /// - Tính toán usedAmount từ transactions trong period hiện tại
  /// - Tính toán percentage và alert level
  /// - Trả về null nếu không có active limit
  Future<Either<Failure, SpendingLimitStatus?>> getSpendingLimitStatus(
    SpendingLimitPeriod period,
  );
}
