import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget hiển thị Pie Chart theo nhóm (có thể dùng cho cả chi tiêu và thu nhập)
class CategoryPieChart extends StatelessWidget {
  final Map<String, double> dataByCategory;
  final Map<String, String> categoryNames; // categoryId -> categoryName
  final Map<String, Color> categoryColors; // categoryId -> color
  final String emptyMessage;

  const CategoryPieChart({
    super.key,
    required this.dataByCategory,
    required this.categoryNames,
    required this.categoryColors,
    this.emptyMessage = 'Chưa có dữ liệu',
  });

  @override
  Widget build(BuildContext context) {
    if (dataByCategory.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    // Tính tổng để tính %
    final total = dataByCategory.values.fold(0.0, (sum, val) => sum + val);

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: dataByCategory.entries.map((entry) {
          final categoryId = entry.key;
          final value = entry.value;
          final percentage = (value / total * 100).toStringAsFixed(1);
          final color = categoryColors[categoryId] ?? Colors.grey;

          return PieChartSectionData(
            value: value,
            title: '$percentage%',
            color: color,
            radius: 55,
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
