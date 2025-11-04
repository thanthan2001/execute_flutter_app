import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Entity đại diện cho một nhóm chi tiêu
class CategoryEntity extends Equatable {
  final String id;
  final String name; // Tên nhóm
  final IconData icon; // Icon của nhóm
  final Color color; // Màu sắc đại diện
  final TransactionCategoryType type; // Loại: thu/chi

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, icon, color, type];
}

/// Enum cho loại nhóm
enum TransactionCategoryType {
  income, // Thu
  expense, // Chi
  both, // Cả hai
}
