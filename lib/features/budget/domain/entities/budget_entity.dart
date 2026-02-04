import 'package:equatable/equatable.dart';

/// Entity đại diện cho ngân sách theo category
class BudgetEntity extends Equatable {
  final String id;
  final String categoryId;
  final double amount; // Số tiền ngân sách
  final BudgetPeriod period; // Chu kỳ: tháng/quý/năm
  final DateTime startDate; // Ngày bắt đầu
  final DateTime? endDate; // Ngày kết thúc (nullable cho recurring budgets)

  const BudgetEntity({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [id, categoryId, amount, period, startDate, endDate];

  /// Copy với thay đổi một số field
  BudgetEntity copyWith({
    String? id,
    String? categoryId,
    double? amount,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// Enum cho chu kỳ ngân sách
enum BudgetPeriod {
  monthly, // Hàng tháng
  quarterly, // Hàng quý
  yearly, // Hàng năm
}

/// Extension để convert enum to String và ngược lại
extension BudgetPeriodExtension on BudgetPeriod {
  String toValue() {
    switch (this) {
      case BudgetPeriod.monthly:
        return 'monthly';
      case BudgetPeriod.quarterly:
        return 'quarterly';
      case BudgetPeriod.yearly:
        return 'yearly';
    }
  }

  static BudgetPeriod fromValue(String value) {
    switch (value) {
      case 'monthly':
        return BudgetPeriod.monthly;
      case 'quarterly':
        return BudgetPeriod.quarterly;
      case 'yearly':
        return BudgetPeriod.yearly;
      default:
        return BudgetPeriod.monthly;
    }
  }

  /// Lấy label hiển thị
  String get displayName {
    switch (this) {
      case BudgetPeriod.monthly:
        return 'Hàng tháng';
      case BudgetPeriod.quarterly:
        return 'Hàng quý';
      case BudgetPeriod.yearly:
        return 'Hàng năm';
    }
  }
}
