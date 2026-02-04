import 'package:hive/hive.dart';
import '../../../../features/dashboard/domain/entities/category_entity.dart';
import '../../domain/entities/recurring_transaction_entity.dart';

part 'recurring_transaction_model.g.dart';

/// Model cho Recurring Transaction, dùng cho Hive
@HiveType(typeId: 3) // TypeId 0: Transaction, 1: Category, 2: Budget, 3: RecurringTransaction
class RecurringTransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String frequency; // 'daily', 'weekly', 'monthly', 'yearly'

  @HiveField(5)
  final int nextDateMillis; // Lưu DateTime dưới dạng milliseconds

  @HiveField(6)
  final int? endDateMillis; // Nullable

  @HiveField(7)
  final bool isActive;

  @HiveField(8)
  final String? type; // Nullable để hỗ trợ dữ liệu cũ

  RecurringTransactionModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.frequency,
    required this.nextDateMillis,
    this.endDateMillis,
    required this.isActive,
    this.type,
  });

  /// Convert từ Entity sang Model
  factory RecurringTransactionModel.fromEntity(
    RecurringTransactionEntity entity,
  ) {
    return RecurringTransactionModel(
      id: entity.id,
      categoryId: entity.categoryId,
      amount: entity.amount,
      description: entity.description,
      frequency: entity.frequency.toValue(),
      nextDateMillis: entity.nextDate.millisecondsSinceEpoch,
      endDateMillis: entity.endDate?.millisecondsSinceEpoch,
      isActive: entity.isActive,
      type: entity.type == TransactionCategoryType.income ? 'income' : 'expense',
    );
  }

  /// Convert từ Model sang Entity
  RecurringTransactionEntity toEntity() {
    return RecurringTransactionEntity(
      id: id,
      categoryId: categoryId,
      amount: amount,
      description: description,
      frequency: RecurringFrequencyExtension.fromValue(frequency),
      nextDate: DateTime.fromMillisecondsSinceEpoch(nextDateMillis),
      endDate: endDateMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(endDateMillis!)
          : null,
      isActive: isActive,
      type: (type ?? 'expense') == 'income'
          ? TransactionCategoryType.income
          : TransactionCategoryType.expense,
    );
  }

  /// Convert từ JSON
  factory RecurringTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecurringTransactionModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      frequency: json['frequency'] as String,
      nextDateMillis: json['nextDateMillis'] as int,
      endDateMillis: json['endDateMillis'] as int?,
      isActive: json['isActive'] as bool,
      type: json['type'] as String? ?? 'expense',
    );
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'frequency': frequency,
      'nextDateMillis': nextDateMillis,
      'endDateMillis': endDateMillis,
      'isActive': isActive,
      'type': type,
    };
  }
}
