import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/configs/app_colors.dart';
import '../../../dashboard/data/datasources/dashboard_local_data_source.dart';
import '../../../dashboard/domain/entities/category_entity.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/date_filter_chips.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/swipeable_chart_section.dart';

/// Dashboard Page - Trang chính hiển thị tổng quan thu chi
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<CategoryEntity> _categories = [];

  @override
  void initState() {
    super.initState();
    // Load dashboard khi mới vào
    context.read<DashboardBloc>().add(const LoadDashboard());
    // Load categories
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final dataSource = di.sl<DashboardLocalDataSource>();
      final categories = await dataSource.getAllCategories();
      if (mounted) {
        setState(() {
          _categories = categories.map((model) => model.toEntity()).toList();
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MONI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        elevation: 0,
        actions: [
          // Menu với các tùy chọn
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onSelected: (value) async {
              switch (value) {
                case 'add_transaction':
                  await context.push('/transactions/add');
                  if (mounted) {
                    context.read<DashboardBloc>().add(const RefreshDashboard());
                  }
                  break;
                case 'statistics':
                  await context.push('/statistics');
                  break;
                case 'categories':
                  await context.push('/categories');
                  if (mounted) {
                    context.read<DashboardBloc>().add(const RefreshDashboard());
                  }
                  break;
                case 'transactions':
                  await context.push('/transactions');
                  if (mounted) {
                    context.read<DashboardBloc>().add(const RefreshDashboard());
                  }
                  break;
                case 'settings':
                  await context.push('/settings');
                  if (mounted) {
                    context.read<DashboardBloc>().add(const RefreshDashboard());
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_transaction',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Thêm giao dịch'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'statistics',
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, size: 20),
                    SizedBox(width: 12),
                    Text('Thống kê'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Quản lý nhóm'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'transactions',
                child: Row(
                  children: [
                    Icon(Icons.list_alt, size: 20),
                    SizedBox(width: 12),
                    Text('Danh sách giao dịch'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Cài đặt'),
                  ],
                ),
              ),
            ],
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
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.red,
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
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Tổng chi',
                amount: summary.totalExpense,
                icon: Icons.arrow_upward,
                color: AppColors.red,
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

        // Swipeable Chart Section (Chi tiêu và Thu nhập theo nhóm)
        SwipeableChartSection(
          expenseByCategory: summary.expenseByCategory,
          incomeByCategory: summary.incomeByCategory,
          categories: _categories,
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
                    _buildChartLegendItem('Thu', AppColors.green),
                    const SizedBox(width: 16),
                    _buildChartLegendItem('Chi', AppColors.red),
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
