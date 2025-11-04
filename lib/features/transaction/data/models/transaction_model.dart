import 'package:hive/hive.dart';
import '../../domain/entities/transaction_entity.dart';

part 'transaction_model.g.dart';

/// Model cho Transaction, dùng cho Hive
@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String categoryId;

  @HiveField(5)
  final String type; // 'income' hoặc 'expense'

  @HiveField(6)
  final String? note;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.type,
    this.note,
  });

  /// Convert từ Entity sang Model
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      description: entity.description,
      date: entity.date,
      categoryId: entity.categoryId,
      type: entity.type == TransactionType.income ? 'income' : 'expense',
      note: entity.note,
    );
  }

  /// Convert từ Model sang Entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      amount: amount,
      description: description,
      date: date,
      categoryId: categoryId,
      type: type == 'income' ? TransactionType.income : TransactionType.expense,
      note: note,
    );
  }

  /// Convert từ JSON (nếu cần)
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      categoryId: json['categoryId'] as String,
      type: json['type'] as String,
      note: json['note'] as String?,
    );
  }

  /// Convert sang JSON (nếu cần)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'type': type,
      'note': note,
    };
  }
}
