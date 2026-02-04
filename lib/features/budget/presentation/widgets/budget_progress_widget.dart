import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../dashboard/domain/entities/category_entity.dart';
import '../../domain/entities/budget_status.dart';

/// Widget hiển thị progress bar cho budget
class BudgetProgressWidget extends StatelessWidget {
  final BudgetStatus status;
  final CategoryEntity category;

  const BudgetProgressWidget({
    super.key,
    required this.status,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

    final percentage = status.percentage.clamp(0.0, 150.0); // Limit display to 150%
    final progressValue = (percentage / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Icon + Category Name
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    status.alertLevel.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(status.alertLevel.colorValue),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Percentage Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(status.alertLevel.colorValue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(status.alertLevel.colorValue),
                  width: 1,
                ),
              ),
              child: Text(
                '${status.percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Color(status.alertLevel.colorValue),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 12,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(status.alertLevel.colorValue),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Amount Details
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đã chi',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currencyFormat.format(status.usedAmount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Ngân sách',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currencyFormat.format(status.budgetAmount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Remaining or Over Budget
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: status.isOverBudget
                ? Colors.red[50]
                : Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                status.isOverBudget ? Icons.warning : Icons.check_circle,
                size: 16,
                color: status.isOverBudget ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status.isOverBudget
                      ? 'Vượt: ${currencyFormat.format(status.remainingAmount.abs())}'
                      : 'Còn lại: ${currencyFormat.format(status.remainingAmount)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: status.isOverBudget ? Colors.red[700] : Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
