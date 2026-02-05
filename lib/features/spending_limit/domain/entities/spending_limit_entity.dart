import 'package:equatable/equatable.dart';

/// Entity đại diện cho giới hạn chi tiêu
class SpendingLimitEntity extends Equatable {
  final String id;
  final double amount; // Số tiền giới hạn
  final SpendingLimitPeriod period; // Chu kỳ: tuần/tháng
  final DateTime startDate; // Ngày bắt đầu áp dụng
  final bool isActive; // Có đang bật/active không

  const SpendingLimitEntity({
    required this.id,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, amount, period, startDate, isActive];

  /// Copy với thay đổi một số field
  SpendingLimitEntity copyWith({
    String? id,
    double? amount,
    SpendingLimitPeriod? period,
    DateTime? startDate,
    bool? isActive,
  }) {
    return SpendingLimitEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Enum cho chu kỳ giới hạn chi tiêu
enum SpendingLimitPeriod {
  weekly, // Hàng tuần
  monthly, // Hàng tháng
}

/// Extension để convert enum sang/từ string
extension SpendingLimitPeriodExtension on SpendingLimitPeriod {
  String toValue() {
    switch (this) {
      case SpendingLimitPeriod.weekly:
        return 'weekly';
      case SpendingLimitPeriod.monthly:
        return 'monthly';
    }
  }

  static SpendingLimitPeriod fromValue(String value) {
    switch (value) {
      case 'weekly':
        return SpendingLimitPeriod.weekly;
      case 'monthly':
        return SpendingLimitPeriod.monthly;
      default:
        return SpendingLimitPeriod.monthly;
    }
  }

  /// Lấy label hiển thị
  String get label {
    switch (this) {
      case SpendingLimitPeriod.weekly:
        return 'Tuần';
      case SpendingLimitPeriod.monthly:
        return 'Tháng';
    }
  }
}
