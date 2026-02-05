import 'package:flutter/material.dart';
import '../../../../global/widgets/widgets.dart';
import '../bloc/dashboard_state.dart';

/// Widget hiển thị chip filter cho các khoảng thời gian
class DateFilterChips extends StatelessWidget {
  final DateFilter selectedFilter;
  final Function(DateFilter) onFilterChanged;

  const DateFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            context,
            'Hôm nay',
            DateFilter.today,
            Icons.today,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            'Tuần này',
            DateFilter.thisWeek,
            Icons.date_range,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            'Tháng này',
            DateFilter.thisMonth,
            Icons.calendar_month,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            'Năm nay',
            DateFilter.thisYear,
            Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    DateFilter filter,
    IconData icon,
  ) {
    final isSelected = selectedFilter == filter;
    final theme = Theme.of(context);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : theme.primaryColor,
          ),
          const SizedBox(width: 4),
          AppText.bodySmall(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onFilterChanged(filter);
        }
      },
      selectedColor: theme.primaryColor,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
    );
  }
}
