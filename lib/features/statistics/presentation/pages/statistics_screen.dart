import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/entities/statistics_summary.dart';
import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_event.dart';
import '../bloc/statistics_state.dart';
import '../widgets/advanced_filter_bottom_sheet.dart';

/// Màn hình Statistics với 3 tabs: Tất cả, Tổng thu, Tổng chi
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load statistics when screen opens
    context.read<StatisticsBloc>().add(const LoadStatistics());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thống kê',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: 'Bộ lọc',
            onPressed: _showFilterBottomSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tất cả', icon: Icon(Icons.dashboard)),
            Tab(text: 'Tổng thu', icon: Icon(Icons.arrow_downward)),
            Tab(text: 'Tổng chi', icon: Icon(Icons.arrow_upward)),
          ],
        ),
      ),
      body: BlocBuilder<StatisticsBloc, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StatisticsError) {
            return _buildError(state.message);
          }

          if (state is StatisticsLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildAllTab(state),
                _buildIncomeTab(state),
                _buildExpenseTab(state),
              ],
            );
          }

          return const Center(child: Text('Kéo xuống để tải dữ liệu'));
        },
      ),
    );
  }

  /// Tab 1: Tất cả - Hiển thị tổng thu và tổng chi
  Widget _buildAllTab(StatisticsLoaded state) {
    final summary = state.summary;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<StatisticsBloc>().add(const RefreshStatistics());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter info
            _buildFilterInfo(state.activeFilter),
            const SizedBox(height: 16),

            // Summary cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Tổng Thu',
                    summary.totalIncome,
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Tổng Chi',
                    summary.totalExpense,
                    Colors.red,
                    Icons.arrow_upward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Balance card
            _buildBalanceCard(summary.balance),
            const SizedBox(height: 20),

            // Combined chart (Thu vs Chi)
            if (summary.totalIncome > 0 || summary.totalExpense > 0) ...[
              const Text(
                'Biểu đồ tổng quan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildCombinedChart(summary),
            ] else
              _buildNoData(),
          ],
        ),
      ),
    );
  }

  /// Tab 2: Tổng thu - Chi tiết theo category
  Widget _buildIncomeTab(StatisticsLoaded state) {
    final summary = state.summary;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<StatisticsBloc>().add(const RefreshStatistics());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter info
            _buildFilterInfo(state.activeFilter),
            const SizedBox(height: 16),

            // Total income (big number in center)
            _buildTotalCard(
              'Tổng Thu Nhập',
              summary.totalIncome,
              Colors.green,
              Icons.trending_up,
            ),
            const SizedBox(height: 20),

            // Category breakdown
            if (summary.incomeByCategory.isNotEmpty) ...[
              // Pie chart
              _buildCategoryPieChart(summary.incomeByCategory, Colors.green),
              const SizedBox(height: 20),

              // Category list
              const Text(
                'Chi tiết theo nhóm',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...summary.incomeByCategory.map((cat) => _buildCategoryItem(cat)),
            ] else
              _buildNoData(),
          ],
        ),
      ),
    );
  }

  /// Tab 3: Tổng chi - Chi tiết theo category
  Widget _buildExpenseTab(StatisticsLoaded state) {
    final summary = state.summary;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<StatisticsBloc>().add(const RefreshStatistics());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter info
            _buildFilterInfo(state.activeFilter),
            const SizedBox(height: 16),

            // Total expense (big number in center)
            _buildTotalCard(
              'Tổng Chi Tiêu',
              summary.totalExpense,
              Colors.red,
              Icons.trending_down,
            ),
            const SizedBox(height: 20),

            // Category breakdown
            if (summary.expenseByCategory.isNotEmpty) ...[
              // Pie chart
              _buildCategoryPieChart(summary.expenseByCategory, Colors.red),
              const SizedBox(height: 20),

              // Category list
              const Text(
                'Chi tiết theo nhóm',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...summary.expenseByCategory
                  .map((cat) => _buildCategoryItem(cat)),
            ] else
              _buildNoData(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterInfo(FilterOptions filter) {
    String filterText = '';
    switch (filter.dateMode) {
      case DateMode.day:
        filterText = DateFormat('dd/MM/yyyy').format(filter.singleDate!);
        break;
      case DateMode.month:
        filterText = 'Tháng ${filter.month}/${filter.year}';
        break;
      case DateMode.year:
        filterText = 'Năm ${filter.year}';
        break;
      case DateMode.range:
        filterText =
            '${DateFormat('dd/MM').format(filter.startDate!)} - ${DateFormat('dd/MM/yyyy').format(filter.endDate!)}';
        break;
    }

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blue.shade700, size: 20),
            const SizedBox(width: 8),
            Text(
              filterText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
            const Spacer(),
            Icon(Icons.filter_alt, color: Colors.blue.shade700, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, double amount, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(
                locale: 'vi_VN',
                symbol: 'đ',
                decimalDigits: 0,
              ).format(amount),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    final isPositive = balance >= 0;
    return Card(
      elevation: 2,
      color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isPositive ? Icons.savings : Icons.warning,
              color: isPositive ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Số dư',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'vi_VN',
                      symbol: 'đ',
                      decimalDigits: 0,
                    ).format(balance.abs()),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(
      String title, double amount, Color color, IconData icon) {
    return Card(
      elevation: 3,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, color: color, size: 48),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(
                locale: 'vi_VN',
                symbol: 'đ',
                decimalDigits: 0,
              ).format(amount),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedChart(StatisticsSummary summary) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          maxY: (summary.totalIncome > summary.totalExpense
                  ? summary.totalIncome
                  : summary.totalExpense) *
              1.2,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: summary.totalIncome,
                  color: Colors.green,
                  width: 60,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: summary.totalExpense,
                  color: Colors.red,
                  width: 60,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text('Thu',
                          style: TextStyle(color: Colors.green));
                    case 1:
                      return const Text('Chi',
                          style: TextStyle(color: Colors.red));
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(
      List<CategoryStatistics> categories, Color baseColor) {
    // Giới hạn top 5 categories
    final topCategories = categories.take(5).toList();

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: topCategories.map((cat) {
            return PieChartSectionData(
              value: cat.amount,
              title: '${cat.percentage.toStringAsFixed(1)}%',
              color: Color(cat.categoryColorValue),
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 0,
        ),
      ),
    );
  }

  Widget _buildCategoryItem(CategoryStatistics cat) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(cat.categoryColorValue).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            IconData(
              cat.categoryIconCodePoint,
              fontFamily: cat.categoryIconFontFamily,
              fontPackage: cat.categoryIconFontPackage,
            ),
            color: Color(cat.categoryColorValue),
          ),
        ),
        title: Text(
          cat.categoryName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${cat.transactionCount} giao dịch'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              NumberFormat.currency(
                locale: 'vi_VN',
                symbol: 'đ',
                decimalDigits: 0,
              ).format(cat.amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(cat.categoryColorValue),
              ),
            ),
            Text(
              '${cat.percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Không có dữ liệu cho khoảng thời gian này',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<StatisticsBloc>().add(const LoadStatistics());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() async {
    final bloc = context.read<StatisticsBloc>();
    final state = bloc.state;

    if (state is! StatisticsLoaded) return;

    // Get categories from dashboard local data source
    // (In real app, inject via repository)
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: bloc,
        child: AdvancedFilterBottomSheet(
          currentFilter: state.activeFilter,
          categories: const [], // TODO: Get from repository
        ),
      ),
    );
  }
}
