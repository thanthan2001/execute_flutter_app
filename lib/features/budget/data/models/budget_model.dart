import 'package:hive/hive.dart';
import '../../domain/entities/budget_entity.dart';

part 'budget_model.g.dart';

/// Model cho Budget, dùng cho Hive
@HiveType(typeId: 2) // TypeId 0: Transaction, 1: Category, 2: Budget
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String period; // 'monthly', 'quarterly', 'yearly'

  @HiveField(4)
  final int startDateMillis; // Lưu DateTime dưới dạng milliseconds

  @HiveField(5)
  final int? endDateMillis; // Nullable

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDateMillis,
    this.endDateMillis,
  });

  /// Convert từ Entity sang Model
  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      categoryId: entity.categoryId,
      amount: entity.amount,
      period: entity.period.toValue(),
      startDateMillis: entity.startDate.millisecondsSinceEpoch,
      endDateMillis: entity.endDate?.millisecondsSinceEpoch,
    );
  }

  /// Convert từ Model sang Entity
  BudgetEntity toEntity() {
    return BudgetEntity(
      id: id,
      categoryId: categoryId,
      amount: amount,
      period: BudgetPeriodExtension.fromValue(period),
      startDate: DateTime.fromMillisecondsSinceEpoch(startDateMillis),
      endDate: endDateMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(endDateMillis!)
          : null,
    );
  }

  /// Convert từ JSON
  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      amount: (json['amount'] as num).toDouble(),
      period: json['period'] as String,
      startDateMillis: json['startDateMillis'] as int,
      endDateMillis: json['endDateMillis'] as int?,
    );
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'period': period,
      'startDateMillis': startDateMillis,
      'endDateMillis': endDateMillis,
    };
  }
}
