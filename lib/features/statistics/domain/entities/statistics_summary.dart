import 'package:equatable/equatable.dart';

/// Entity chứa thống kê tổng quan
class StatisticsSummary extends Equatable {
  final double totalIncome; // Tổng thu
  final double totalExpense; // Tổng chi
  final double balance; // Số dư (thu - chi)
  final List<CategoryStatistics> incomeByCategory; // Thống kê thu theo category
  final List<CategoryStatistics>
      expenseByCategory; // Thống kê chi theo category

  const StatisticsSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.incomeByCategory,
    required this.expenseByCategory,
  });

  /// Factory tạo summary rỗng
  factory StatisticsSummary.empty() {
    return const StatisticsSummary(
      totalIncome: 0,
      totalExpense: 0,
      balance: 0,
      incomeByCategory: [],
      expenseByCategory: [],
    );
  }

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        balance,
        incomeByCategory,
        expenseByCategory,
      ];
}

/// Entity chứa thống kê theo từng category
class CategoryStatistics extends Equatable {
  final String categoryId; // ID của category
  final String categoryName; // Tên category
  final int categoryIconCodePoint; // Icon codePoint
  final String categoryIconFontFamily; // Icon fontFamily
  final String? categoryIconFontPackage; // Icon fontPackage
  final int categoryColorValue; // Màu sắc (Color.value)
  final double amount; // Tổng số tiền của category này
  final double percentage; // Phần trăm so với tổng (0-100)
  final int transactionCount; // Số lượng giao dịch

  const CategoryStatistics({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIconCodePoint,
    required this.categoryIconFontFamily,
    this.categoryIconFontPackage,
    required this.categoryColorValue,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        categoryIconCodePoint,
        categoryIconFontFamily,
        categoryIconFontPackage,
        categoryColorValue,
        amount,
        percentage,
        transactionCount,
      ];
}
