import 'package:equatable/equatable.dart';

/// Entity đại diện cho một giao dịch thu/chi
class TransactionEntity extends Equatable {
  final String id;
  final double amount; // Số tiền
  final String description; // Mô tả
  final DateTime date; // Ngày giao dịch
  final String categoryId; // ID nhóm chi tiêu
  final TransactionType type; // Loại: thu/chi
  final String? note; // Ghi chú thêm (optional)

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.type,
    this.note,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        description,
        date,
        categoryId,
        type,
        note,
      ];
}

/// Enum cho loại giao dịch
enum TransactionType {
  income, // Thu
  expense, // Chi
}
