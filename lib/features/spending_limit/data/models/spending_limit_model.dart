import 'package:hive/hive.dart';
import '../../domain/entities/spending_limit_entity.dart';

part 'spending_limit_model.g.dart';

/// Model cho SpendingLimit, dùng cho Hive
@HiveType(typeId: 4) // TypeId 0: Transaction, 1: Category, 2: Budget, 3: RecurringTransaction, 4: SpendingLimit
class SpendingLimitModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String period; // 'weekly', 'monthly'

  @HiveField(3)
  final int startDateMillis; // Lưu DateTime dưới dạng milliseconds

  @HiveField(4)
  final bool isActive;

  SpendingLimitModel({
    required this.id,
    required this.amount,
    required this.period,
    required this.startDateMillis,
    required this.isActive,
  });

  /// Convert từ Entity sang Model
  factory SpendingLimitModel.fromEntity(SpendingLimitEntity entity) {
    return SpendingLimitModel(
      id: entity.id,
      amount: entity.amount,
      period: entity.period.toValue(),
      startDateMillis: entity.startDate.millisecondsSinceEpoch,
      isActive: entity.isActive,
    );
  }

  /// Convert từ Model sang Entity
  SpendingLimitEntity toEntity() {
    return SpendingLimitEntity(
      id: id,
      amount: amount,
      period: SpendingLimitPeriodExtension.fromValue(period),
      startDate: DateTime.fromMillisecondsSinceEpoch(startDateMillis),
      isActive: isActive,
    );
  }

  /// Convert từ JSON
  factory SpendingLimitModel.fromJson(Map<String, dynamic> json) {
    return SpendingLimitModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      period: json['period'] as String,
      startDateMillis: json['startDateMillis'] as int,
      isActive: json['isActive'] as bool,
    );
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'period': period,
      'startDateMillis': startDateMillis,
      'isActive': isActive,
    };
  }
}
