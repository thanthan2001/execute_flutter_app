import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget hiển thị Pie Chart theo nhóm chi tiêu
class ExpensePieChart extends StatelessWidget {
  final Map<String, double> expenseByCategory;
  final Map<String, String> categoryNames; // categoryId -> categoryName
  final Map<String, Color> categoryColors; // categoryId -> color

  const ExpensePieChart({
    super.key,
    required this.expenseByCategory,
    required this.categoryNames,
    required this.categoryColors,
  });

  @override
  Widget build(BuildContext context) {
    if (expenseByCategory.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có dữ liệu chi tiêu',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    // Tính tổng để tính %
    final total = expenseByCategory.values.fold(0.0, (sum, val) => sum + val);

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: expenseByCategory.entries.map((entry) {
          final categoryId = entry.key;
          final value = entry.value;
          final percentage = (value / total * 100).toStringAsFixed(1);
          final color = categoryColors[categoryId] ?? Colors.grey;

          return PieChartSectionData(
            value: value,
            title: '$percentage%',
            color: color,
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}
