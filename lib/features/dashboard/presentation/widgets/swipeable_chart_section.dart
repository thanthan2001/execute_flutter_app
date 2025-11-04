import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/configs/app_colors.dart';
import '../../../category/domain/entities/category_entity.dart';
import 'category_pie_chart.dart';

/// Widget hiển thị biểu đồ chi tiêu và thu nhập với khả năng vuốt ngang
class SwipeableChartSection extends StatefulWidget {
  final Map<String, double> expenseByCategory;
  final Map<String, double> incomeByCategory;
  final List<CategoryEntity> categories;

  const SwipeableChartSection({
    super.key,
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.categories,
  });

  @override
  State<SwipeableChartSection> createState() => _SwipeableChartSectionState();
}

class _SwipeableChartSectionState extends State<SwipeableChartSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Map<String, String> get _categoryNames {
    return {
      for (var cat in widget.categories) cat.id: cat.name,
    };
  }

  Map<String, Color> get _categoryColors {
    return {
      for (var cat in widget.categories) cat.id: cat.color,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với title động
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: _currentPage == 0 ? AppColors.red : AppColors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentPage == 0
                        ? 'Chi tiêu theo nhóm'
                        : 'Thu nhập theo nhóm',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${_currentPage + 1}/2',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // PageView với 2 biểu đồ
            SizedBox(
              height: 250,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Trang 1: Biểu đồ chi tiêu
                  CategoryPieChart(
                    dataByCategory: widget.expenseByCategory,
                    categoryNames: _categoryNames,
                    categoryColors: _categoryColors,
                    emptyMessage: 'Chưa có dữ liệu chi tiêu',
                  ),
                  // Trang 2: Biểu đồ thu nhập
                  CategoryPieChart(
                    dataByCategory: widget.incomeByCategory,
                    categoryNames: _categoryNames,
                    categoryColors: _categoryColors,
                    emptyMessage: 'Chưa có dữ liệu thu nhập',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Page indicator (chấm)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? theme.primaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Legend hiển thị dữ liệu của trang hiện tại
            _buildLegend(
              _currentPage == 0
                  ? widget.expenseByCategory
                  : widget.incomeByCategory,
            ),
          ],
        ),
      ),
    );
  }

  /// Build legend cho biểu đồ hiện tại
  Widget _buildLegend(Map<String, double> dataByCategory) {
    if (dataByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    // Tạo map categoryId -> category entity
    final categoryMap = {for (var cat in widget.categories) cat.id: cat};

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: dataByCategory.entries.map((entry) {
        final categoryId = entry.key;
        final amount = entry.value;
        final category = categoryMap[categoryId];

        final formattedAmount = NumberFormat.currency(
          locale: 'vi_VN',
          symbol: 'đ',
          decimalDigits: 0,
        ).format(amount);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: category?.color ?? Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${category?.name ?? categoryId}: $formattedAmount',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}
