import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../dashboard/domain/entities/category_entity.dart';
import '../../domain/entities/budget_status.dart';

/// Dialog cảnh báo khi budget có vấn đề
class BudgetAlertDialog extends StatelessWidget {
  final BudgetStatus status;
  final CategoryEntity category;

  const BudgetAlertDialog({
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

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getAlertIcon(),
            color: Color(status.alertLevel.colorValue),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getAlertTitle(),
              style: TextStyle(
                color: Color(status.alertLevel.colorValue),
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Info
          Row(
            children: [
              Icon(category.icon, color: category.color, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Budget Details
          _buildDetailRow(
            'Ngân sách',
            currencyFormat.format(status.budgetAmount),
            Icons.account_balance_wallet,
          ),

          const SizedBox(height: 12),

          _buildDetailRow(
            'Đã sử dụng',
            currencyFormat.format(status.usedAmount),
            Icons.shopping_cart,
            valueColor: Color(status.alertLevel.colorValue),
          ),

          const SizedBox(height: 12),

          _buildDetailRow(
            status.isOverBudget ? 'Vượt' : 'Còn lại',
            currencyFormat.format(status.remainingAmount.abs()),
            status.isOverBudget ? Icons.trending_up : Icons.trending_down,
            valueColor: status.isOverBudget ? Colors.red : Colors.green,
          ),

          const SizedBox(height: 16),

          // Progress Bar
          LinearProgressIndicator(
            value: (status.percentage / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(status.alertLevel.colorValue),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              '${status.percentage.toStringAsFixed(1)}% đã sử dụng',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(status.alertLevel.colorValue),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Recommendation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getRecommendation(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  IconData _getAlertIcon() {
    switch (status.alertLevel) {
      case BudgetAlertLevel.normal:
        return Icons.check_circle;
      case BudgetAlertLevel.warning:
        return Icons.warning;
      case BudgetAlertLevel.exceeded:
        return Icons.error;
      case BudgetAlertLevel.critical:
        return Icons.dangerous;
    }
  }

  String _getAlertTitle() {
    switch (status.alertLevel) {
      case BudgetAlertLevel.normal:
        return 'Ngân sách ổn định';
      case BudgetAlertLevel.warning:
        return 'Cảnh báo ngân sách';
      case BudgetAlertLevel.exceeded:
        return 'Vượt ngân sách';
      case BudgetAlertLevel.critical:
        return 'Vượt nghiêm trọng!';
    }
  }

  String _getRecommendation() {
    switch (status.alertLevel) {
      case BudgetAlertLevel.normal:
        return 'Bạn đang quản lý chi tiêu tốt. Hãy tiếp tục duy trì!';
      case BudgetAlertLevel.warning:
        return 'Hãy cân nhắc giảm chi tiêu để không vượt ngân sách.';
      case BudgetAlertLevel.exceeded:
        return 'Bạn đã vượt ngân sách. Hãy xem xét điều chỉnh chi tiêu hoặc tăng ngân sách.';
      case BudgetAlertLevel.critical:
        return 'Chi tiêu vượt quá 120% ngân sách! Cần hành động ngay để kiểm soát tài chính.';
    }
  }
}
