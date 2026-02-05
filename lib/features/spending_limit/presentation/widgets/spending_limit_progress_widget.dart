import 'package:flutter/material.dart';
import '../../../../global/widgets/widgets.dart';
import '../../domain/entities/spending_limit_status.dart';
import 'package:intl/intl.dart';

/// Widget hiển thị progress của spending limit
class SpendingLimitProgressWidget extends StatelessWidget {
  final SpendingLimitStatus status;

  const SpendingLimitProgressWidget({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    final progressValue = (status.percentage / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header với status message
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                status.alertLevel.message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(status.alertLevel.colorValue),
                ),
              ),
            ),
            Text(
              '${status.percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                color: Color(status.alertLevel.colorValue),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Progress bar
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

        // Chi tiết số tiền
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodySmall('Đã chi', color: Colors.grey),
                const SizedBox(height: 4),
                AppText.body(
                  '${formatter.format(status.usedAmount)} đ',

                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText.bodySmall('Giới hạn', color: Colors.grey),
                const SizedBox(height: 4),
                AppText.body(
                  '${formatter.format(status.limitAmount)} đ',

                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Remaining amount
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: status.isOverLimit
                ? Colors.red[50]
                : Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.bodySmall(
                status.isOverLimit ? 'Vượt mức' : 'Còn lại',
                color: status.isOverLimit ? Colors.red : Colors.green,
              ),
              AppText.body(
                '${formatter.format(status.remainingAmount.abs())} đ',
                color: status.isOverLimit ? Colors.red : Colors.green,

              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Period info
        AppText.bodySmall(
          'Từ ${DateFormat('dd/MM/yyyy').format(status.periodStart)} '
          'đến ${DateFormat('dd/MM/yyyy').format(status.periodEnd)}',
          color: Colors.grey,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
