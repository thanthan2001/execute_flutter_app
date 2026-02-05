import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../global/widgets/widgets.dart';
import '../../domain/entities/spending_limit_entity.dart';
import '../../domain/entities/spending_limit_status.dart';
import '../bloc/spending_limit_bloc.dart';
import '../bloc/spending_limit_event.dart';
import '../bloc/spending_limit_state.dart';

/// Widget nhỏ hiển thị spending limit status trong dashboard
class SpendingLimitDashboardWidget extends StatelessWidget {
  final SpendingLimitPeriod period;

  const SpendingLimitDashboardWidget({
    super.key,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SpendingLimitBloc>()
        ..add(LoadSpendingLimit(period: period)),
      child: BlocBuilder<SpendingLimitBloc, SpendingLimitState>(
        builder: (context, state) {
          if (state is SpendingLimitLoading) {
            return const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          if (state is SpendingLimitLoaded) {
            final status = state.status;
            final limit = state.limit;

            // Không có limit hoặc không active
            if (limit == null || !limit.isActive || status == null) {
              return const SizedBox.shrink();
            }

            final formatter = NumberFormat('#,###', 'vi_VN');
            final progressValue = (status.percentage / 100).clamp(0.0, 1.0);

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          period == SpendingLimitPeriod.weekly
                              ? Icons.calendar_view_week
                              : Icons.calendar_month,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppText.body(
                            'Chi tiêu ${period.label.toLowerCase()}',
                          ),
                        ),
                        Text(
                          '${status.percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(status.alertLevel.colorValue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(status.alertLevel.colorValue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText.bodySmall(
                          '${formatter.format(status.usedAmount)} đ',
                          color: Colors.grey,
                        ),
                        AppText.bodySmall(
                          '/ ${formatter.format(status.limitAmount)} đ',
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
