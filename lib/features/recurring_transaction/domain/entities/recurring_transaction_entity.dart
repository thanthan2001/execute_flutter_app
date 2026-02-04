import 'package:equatable/equatable.dart';
import '../../../category/domain/entities/category_entity.dart';

/// Entity đại diện cho giao dịch định kỳ (lặp lại)
class RecurringTransactionEntity extends Equatable {
  final String id;
  final String categoryId;
  final double amount;
  final String description;
  final RecurringFrequency frequency; // Tần suất: daily/weekly/monthly/yearly
  final DateTime nextDate; // Ngày giao dịch tiếp theo sẽ được tạo
  final DateTime? endDate; // Ngày kết thúc (nullable = không giới hạn)
  final bool isActive; // Có đang hoạt động không
  final TransactionCategoryType type; // Thu hay Chi

  const RecurringTransactionEntity({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.frequency,
    required this.nextDate,
    this.endDate,
    required this.isActive,
    required this.type,
  });

  @override
  List<Object?> get props => [
        id,
        categoryId,
        amount,
        description,
        frequency,
        nextDate,
        endDate,
        isActive,
        type,
      ];

  /// Copy với thay đổi một số field
  RecurringTransactionEntity copyWith({
    String? id,
    String? categoryId,
    double? amount,
    String? description,
    RecurringFrequency? frequency,
    DateTime? nextDate,
    DateTime? endDate,
    bool? isActive,
    TransactionCategoryType? type,
  }) {
    return RecurringTransactionEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      nextDate: nextDate ?? this.nextDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
    );
  }

  /// Check xem recurring transaction có đã hết hạn chưa
  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  /// Check xem có cần tạo transaction mới không
  bool get shouldGenerateTransaction {
    if (!isActive) return false;
    if (isExpired) return false;
    return DateTime.now().isAfter(nextDate) ||
        DateTime.now().isAtSameMomentAs(nextDate);
  }
}

/// Enum cho tần suất lặp lại
enum RecurringFrequency {
  daily, // Hàng ngày
  weekly, // Hàng tuần
  monthly, // Hàng tháng
  yearly, // Hàng năm
}

/// Extension để convert enum to String và ngược lại
extension RecurringFrequencyExtension on RecurringFrequency {
  String toValue() {
    switch (this) {
      case RecurringFrequency.daily:
        return 'daily';
      case RecurringFrequency.weekly:
        return 'weekly';
      case RecurringFrequency.monthly:
        return 'monthly';
      case RecurringFrequency.yearly:
        return 'yearly';
    }
  }

  static RecurringFrequency fromValue(String value) {
    switch (value) {
      case 'daily':
        return RecurringFrequency.daily;
      case 'weekly':
        return RecurringFrequency.weekly;
      case 'monthly':
        return RecurringFrequency.monthly;
      case 'yearly':
        return RecurringFrequency.yearly;
      default:
        return RecurringFrequency.monthly;
    }
  }

  /// Lấy label hiển thị
  String get displayName {
    switch (this) {
      case RecurringFrequency.daily:
        return 'Hàng ngày';
      case RecurringFrequency.weekly:
        return 'Hàng tuần';
      case RecurringFrequency.monthly:
        return 'Hàng tháng';
      case RecurringFrequency.yearly:
        return 'Hàng năm';
    }
  }

  /// Tính nextDate từ currentDate
  DateTime calculateNextDate(DateTime currentDate) {
    switch (this) {
      case RecurringFrequency.daily:
        return currentDate.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return currentDate.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        // Thêm 1 tháng, giữ nguyên ngày
        return DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
        );
      case RecurringFrequency.yearly:
        // Thêm 1 năm, giữ nguyên tháng và ngày
        return DateTime(
          currentDate.year + 1,
          currentDate.month,
          currentDate.day,
        );
    }
  }
}
