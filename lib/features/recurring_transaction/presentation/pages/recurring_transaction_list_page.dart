import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../dashboard/data/datasources/dashboard_local_data_source.dart';
import '../../../dashboard/domain/entities/category_entity.dart';
import '../../domain/entities/recurring_transaction_entity.dart';
import '../bloc/recurring_transaction_bloc.dart';
import '../bloc/recurring_transaction_event.dart';
import '../bloc/recurring_transaction_state.dart';
import 'add_edit_recurring_page.dart';

/// Màn hình danh sách recurring transactions
class RecurringTransactionListPage extends StatelessWidget {
  const RecurringTransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RecurringTransactionBloc>()
        ..add(const ProcessPendingRecurring())
        ..add(const LoadRecurringTransactions()),
      child: const _RecurringTransactionListView(),
    );
  }
}

class _RecurringTransactionListView extends StatefulWidget {
  const _RecurringTransactionListView();

  @override
  State<_RecurringTransactionListView> createState() =>
      _RecurringTransactionListViewState();
}

class _RecurringTransactionListViewState
    extends State<_RecurringTransactionListView> {
  List<CategoryEntity> _categories = [];
  String _searchQuery = '';
  TransactionCategoryType? _selectedFilter;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final dashboardDataSource = sl<DashboardLocalDataSource>();
      final categories = await dashboardDataSource.getAllCategories();
      setState(() {
        _categories = categories.map((m) => m.toEntity()).toList();
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao Dịch Định Kỳ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<RecurringTransactionBloc>()
                  .add(const ProcessPendingRecurring());
              context
                  .read<RecurringTransactionBloc>()
                  .add(const RefreshRecurringTransactions());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar and filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm giao dịch định kỳ...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Tất cả'),
                        selected: _selectedFilter == null,
                        onSelected: (selected) {
                          setState(() => _selectedFilter = null);
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('🔽 Thu'),
                        selected: _selectedFilter == TransactionCategoryType.income,
                        onSelected: (selected) {
                          setState(() => _selectedFilter =
                              selected ? TransactionCategoryType.income : null);
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('🔼 Chi'),
                        selected: _selectedFilter == TransactionCategoryType.expense,
                        onSelected: (selected) {
                          setState(() => _selectedFilter =
                              selected ? TransactionCategoryType.expense : null);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<RecurringTransactionBloc, RecurringTransactionState>(
              listener: (context, state) {
                if (state is RecurringTransactionActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is RecurringTransactionError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is RecurringTransactionProcessed) {
                  if (state.generatedCount > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã tạo ${state.generatedCount} giao dịch từ lịch định kỳ',
                        ),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                }
              },
              builder: (context, state) {
                if (state is RecurringTransactionLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is RecurringTransactionError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<RecurringTransactionBloc>()
                                .add(const LoadRecurringTransactions());
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is RecurringTransactionLoaded) {
                  var recurrings = state.recurrings;

                  // Apply type filter
                  if (_selectedFilter != null) {
                    recurrings = recurrings
                        .where((r) => r.type == _selectedFilter)
                        .toList();
                  }

                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    recurrings = recurrings.where((r) {
                      final matchDescription = r.description
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                      final category = _categories.firstWhere(
                        (c) => c.id == r.categoryId,
                        orElse: () => const CategoryEntity(
                          id: '',
                          name: 'Unknown',
                          icon: Icons.help_outline,
                          color: Colors.grey,
                          type: TransactionCategoryType.expense,
                        ),
                      );
                      final matchCategory = category.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                      return matchDescription || matchCategory;
                    }).toList();
                  }

                  if (recurrings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.repeat, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có giao dịch định kỳ nào',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Nhấn nút + để thêm mới',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<RecurringTransactionBloc>()
                          .add(const RefreshRecurringTransactions());
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: recurrings.length,
                      itemBuilder: (context, index) {
                        final recurring = recurrings[index];
                        final category = _categories.firstWhere(
                          (c) => c.id == recurring.categoryId,
                          orElse: () => const CategoryEntity(
                            id: '',
                            name: 'Unknown',
                            icon: Icons.help_outline,
                            color: Colors.grey,
                            type: TransactionCategoryType.expense,
                          ),
                        );

                        return _buildRecurringCard(context, recurring, category);
                      },
                    ),
                  );
                }

                return const Center(child: Text('Không có dữ liệu'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditRecurringPage(),
            ),
          );

          if (result == true && context.mounted) {
            context
                .read<RecurringTransactionBloc>()
                .add(const LoadRecurringTransactions());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecurringCard(
    BuildContext context,
    RecurringTransactionEntity recurring,
    CategoryEntity category,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(category.icon, color: category.color),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recurring.description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recurring.type == TransactionCategoryType.income
                        ? '🔽 Thu'
                        : '🔼 Chi',
                    style: TextStyle(
                      fontSize: 12,
                      color: recurring.type == TransactionCategoryType.income
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.name),
            Text(
              '${recurring.frequency.displayName} • Kế tiếp: ${DateFormat('dd/MM/yyyy').format(recurring.nextDate)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(recurring.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: recurring.isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recurring.isActive ? 'Active' : 'Paused',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'toggle') {
                  if (recurring.isActive) {
                    context
                        .read<RecurringTransactionBloc>()
                        .add(DeactivateRecurring(id: recurring.id));
                  } else {
                    context
                        .read<RecurringTransactionBloc>()
                        .add(ActivateRecurring(id: recurring.id));
                  }
                } else if (value == 'delete') {
                  _confirmDelete(context, recurring);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(recurring.isActive ? 'Tạm dừng' : 'Kích hoạt'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Xóa', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditRecurringPage(recurring: recurring),
            ),
          );

          if (result == true && context.mounted) {
            context
                .read<RecurringTransactionBloc>()
                .add(const LoadRecurringTransactions());
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    RecurringTransactionEntity recurring,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${recurring.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context
          .read<RecurringTransactionBloc>()
          .add(DeleteRecurring(id: recurring.id));
    }
  }
}
