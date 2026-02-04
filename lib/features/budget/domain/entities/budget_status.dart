import 'package:equatable/equatable.dart';

/// Entity chứa thông tin trạng thái ngân sách
class BudgetStatus extends Equatable {
  final String budgetId;
  final String categoryId;
  final double budgetAmount; // Số tiền ngân sách đã đặt
  final double usedAmount; // Số tiền đã sử dụng
  final double percentage; // Phần trăm đã sử dụng (0-100+)
  final BudgetAlertLevel alertLevel; // Mức độ cảnh báo

  const BudgetStatus({
    required this.budgetId,
    required this.categoryId,
    required this.budgetAmount,
    required this.usedAmount,
    required this.percentage,
    required this.alertLevel,
  });

  /// Số tiền còn lại
  double get remainingAmount => budgetAmount - usedAmount;

  /// Có vượt ngân sách không
  bool get isOverBudget => usedAmount > budgetAmount;

  @override
  List<Object?> get props => [
        budgetId,
        categoryId,
        budgetAmount,
        usedAmount,
        percentage,
        alertLevel,
      ];
}

/// Enum cho mức độ cảnh báo ngân sách
enum BudgetAlertLevel {
  normal, // < 80%
  warning, // >= 80% và < 100%
  exceeded, // >= 100% và < 120%
  critical, // >= 120%
}

/// Extension để xác định alert level từ percentage
extension BudgetAlertLevelExtension on BudgetAlertLevel {
  /// Lấy alert level từ percentage
  static BudgetAlertLevel fromPercentage(double percentage) {
    if (percentage < 80) {
      return BudgetAlertLevel.normal;
    } else if (percentage < 100) {
      return BudgetAlertLevel.warning;
    } else if (percentage < 120) {
      return BudgetAlertLevel.exceeded;
    } else {
      return BudgetAlertLevel.critical;
    }
  }

  /// Lấy màu sắc theo alert level
  int get colorValue {
    switch (this) {
      case BudgetAlertLevel.normal:
        return 0xFF4CAF50; // Green
      case BudgetAlertLevel.warning:
        return 0xFFFF9800; // Orange
      case BudgetAlertLevel.exceeded:
        return 0xFFFF5722; // Deep Orange
      case BudgetAlertLevel.critical:
        return 0xFFF44336; // Red
    }
  }

  /// Lấy message theo alert level
  String get message {
    switch (this) {
      case BudgetAlertLevel.normal:
        return 'Ngân sách ổn định';
      case BudgetAlertLevel.warning:
        return '⚠️ Sắp đạt giới hạn ngân sách';
      case BudgetAlertLevel.exceeded:
        return '🚨 Đã vượt ngân sách';
      case BudgetAlertLevel.critical:
        return '🔴 Vượt ngân sách nghiêm trọng';
    }
  }
}
