import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/date_filter_chips.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/monthly_bar_chart.dart';

/// Dashboard Page - Trang chính hiển thị tổng quan thu chi
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load dashboard khi mới vào
    context.read<DashboardBloc>().add(const LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Thống kê',
            onPressed: () {
              context.push('/statistics');
            },
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Quản lý nhóm',
            onPressed: () async {
              // Navigate to categories
              await context.push('/categories');
              // Refresh dashboard khi quay lại
              if (mounted) {
                context.read<DashboardBloc>().add(const RefreshDashboard());
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Danh sách giao dịch',
            onPressed: () async {
              // Navigate to transactions
              await context.push('/transactions');
              // Refresh dashboard khi quay lại
              if (mounted) {
                context.read<DashboardBloc>().add(const RefreshDashboard());
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Thêm giao dịch',
            onPressed: () async {
              // Navigate to add transaction
              await context.push('/transactions/add');
              // Refresh dashboard khi quay lại
              if (mounted) {
                context.read<DashboardBloc>().add(const RefreshDashboard());
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cài đặt (Coming soon)')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<DashboardBloc>()
                          .add(const RefreshDashboard());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const RefreshDashboard());
                // Đợi cho đến khi state thay đổi
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: _buildDashboardContent(context, state),
            );
          }

          // Initial state
          return const Center(
            child: Text('Kéo xuống để tải dữ liệu'),
          );
        },
      ),
    );
  }

  /// Build nội dung Dashboard
  Widget _buildDashboardContent(BuildContext context, DashboardLoaded state) {
    final summary = state.summary;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Filter chips
        DateFilterChips(
          selectedFilter: state.currentFilter,
          onFilterChanged: (filter) {
            context.read<DashboardBloc>().add(ChangeDateFilter(filter: filter));
          },
        ),
        const SizedBox(height: 20),

        // Summary Cards
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Tổng thu',
                amount: summary.totalIncome,
                icon: Icons.arrow_downward,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Tổng chi',
                amount: summary.totalExpense,
                icon: Icons.arrow_upward,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Balance Card
        SummaryCard(
          title: 'Số dư',
          amount: summary.balance,
          icon: Icons.account_balance_wallet,
          color: summary.balance >= 0 ? Colors.blue : Colors.orange,
        ),
        const SizedBox(height: 24),

        // Pie Chart Section
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.pie_chart, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      'Chi tiêu theo nhóm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: ExpensePieChart(
                    expenseByCategory: summary.expenseByCategory,
                    categoryNames: const {
                      // TODO: Load from actual categories
                      'food': 'Ăn uống',
                      'transport': 'Di chuyển',
                      'shopping': 'Mua sắm',
                      'entertainment': 'Giải trí',
                      'other': 'Khác',
                    },
                    categoryColors: const {
                      'food': Colors.orange,
                      'transport': Colors.blue,
                      'shopping': Colors.purple,
                      'entertainment': Colors.pink,
                      'other': Colors.grey,
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildLegend(summary.expenseByCategory),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Bar Chart Section
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bar_chart, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      'Biểu đồ theo tháng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildChartLegendItem('Thu', Colors.green),
                    const SizedBox(width: 16),
                    _buildChartLegendItem('Chi', Colors.red),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: MonthlyBarChart(
                    monthlyData: summary.monthlyData,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Build legend cho Pie Chart
  Widget _buildLegend(Map<String, double> expenseByCategory) {
    if (expenseByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    final categoryInfo = {
      'food': {'name': 'Ăn uống', 'color': Colors.orange},
      'transport': {'name': 'Di chuyển', 'color': Colors.blue},
      'shopping': {'name': 'Mua sắm', 'color': Colors.purple},
      'entertainment': {'name': 'Giải trí', 'color': Colors.pink},
      'other': {'name': 'Khác', 'color': Colors.grey},
    };

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: expenseByCategory.entries.map((entry) {
        final categoryId = entry.key;
        final amount = entry.value;
        final info = categoryInfo[categoryId] ??
            {'name': categoryId, 'color': Colors.grey};

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
                color: info['color'] as Color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${info['name']}: $formattedAmount',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Build legend item cho Bar Chart
  Widget _buildChartLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
