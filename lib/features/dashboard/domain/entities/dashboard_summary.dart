import 'package:equatable/equatable.dart';

/// Entity tổng hợp thống kê cho Dashboard
class DashboardSummary extends Equatable {
  final double totalIncome; // Tổng thu
  final double totalExpense; // Tổng chi
  final double balance; // Số dư (thu - chi)
  final Map<String, double> expenseByCategory; // Chi tiêu theo nhóm
  final Map<String, double> incomeByCategory; // Thu nhập theo nhóm
  final List<MonthlyData> monthlyData; // Dữ liệu theo tháng

  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.monthlyData,
  });

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        balance,
        expenseByCategory,
        incomeByCategory,
        monthlyData,
      ];
}

/// Dữ liệu thu chi theo tháng
class MonthlyData extends Equatable {
  final int month; // Tháng (1-12)
  final int year; // Năm
  final double income; // Tổng thu trong tháng
  final double expense; // Tổng chi trong tháng

  const MonthlyData({
    required this.month,
    required this.year,
    required this.income,
    required this.expense,
  });

  @override
  List<Object?> get props => [month, year, income, expense];
}
