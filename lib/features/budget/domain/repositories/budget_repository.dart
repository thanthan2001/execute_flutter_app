import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/budget_entity.dart';
import '../entities/budget_status.dart';

/// Repository interface cho Budget Management
abstract class BudgetRepository {
  /// Tạo hoặc cập nhật ngân sách
  /// - Nếu đã tồn tại budget cho category trong period này → update
  /// - Nếu chưa → create mới
  Future<Either<Failure, void>> setBudget(BudgetEntity budget);

  /// Lấy tất cả budgets
  Future<Either<Failure, List<BudgetEntity>>> getAllBudgets();

  /// Lấy budgets đang active (trong khoảng thời gian hiện tại)
  Future<Either<Failure, List<BudgetEntity>>> getActiveBudgets();

  /// Lấy budget theo category ID và thời gian cụ thể
  /// - Trả về budget đang active cho category đó trong khoảng thời gian chứa [date]
  Future<Either<Failure, BudgetEntity?>> getBudgetByCategory(
    String categoryId,
    DateTime date,
  );

  /// Xóa budget theo ID
  Future<Either<Failure, void>> deleteBudget(String budgetId);

  /// Lấy trạng thái của budget (so sánh với chi tiêu thực tế)
  /// - Tính toán usedAmount từ transactions
  /// - Tính toán percentage và alert level
  Future<Either<Failure, BudgetStatus>> getBudgetStatus(
    String budgetId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Lấy tất cả budget statuses đang active
  Future<Either<Failure, List<BudgetStatus>>> getAllBudgetStatuses();
}
