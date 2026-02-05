import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/configs/app_colors.dart';
import '../../../../global/widgets/widgets.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/repositories/category_management_repository.dart';
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
      final categoryRepo = di.sl<CategoryManagementRepository>();
      final result = await categoryRepo.getAllCategories();
      result.fold(
        (failure) => print('Error loading categories: $failure'),
        (categories) {
          if (mounted) {
            setState(() {
              _categories = categories;
            });
          }
        },
      );
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.heading4('MONI'),
        elevation: 0,
        actions: [
          //Add transaction
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Thêm giao dịch',
            onPressed: () async {
              await context.push('/transactions/add');
              if (mounted) {
                context.read<DashboardBloc>().add(const RefreshDashboard());
              }
            },
          ),
          // Menu với các tùy chọn
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onSelected: (value) async {
              switch (value) {
                case 'statistics':
                  await context.push('/statistics');
                  break;
                case 'budget':
                  await context.push('/budget');
                  if (mounted) {
                    context.read<DashboardBloc>().add(const RefreshDashboard());
                  }
                  break;
                case 'recurring':
                  await context.push('/recurring-transactions');
                  if (mounted) {
                    context.read<DashboardBloc>().add(const RefreshDashboard());
                  }
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
              PopupMenuItem(
                value: 'statistics',
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, size: 20),
                    SizedBox(width: 12),
                    AppText.body('Thống kê'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'budget',
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 20),
                    SizedBox(width: 12),
                    AppText.body('Quản lý ngân sách'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'recurring',
                child: Row(
                  children: [
                    Icon(Icons.repeat, size: 20),
                    SizedBox(width: 12),
                    AppText.body('Giao dịch định kỳ'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category_outlined, size: 20),
                    SizedBox(width: 12),
                    AppText.body('Quản lý nhóm'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'transactions',
                child: Row(
                  children: [
                    Icon(Icons.list_alt, size: 20),
                    SizedBox(width: 12),
                    AppText.body('Danh sách giao dịch'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 12),
                    AppText.body('Cài đặt'),
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
                  AppText.body(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<DashboardBloc>()
                          .add(const RefreshDashboard());
                    },
                    icon: const Icon(Icons.refresh),
                    label: AppText.label('Thử lại'),
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
          return  Center(
            child: AppText.body('Kéo xuống để tải dữ liệu'),
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
        AppCard.padded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  AppText.heading4('Biểu đồ theo tháng'),
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
        AppText.caption(label),
      ],
    );
  }
}
