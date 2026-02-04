import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../dashboard/data/datasources/dashboard_local_data_source.dart';
import '../../../dashboard/domain/entities/category_entity.dart';
import '../../domain/entities/budget_entity.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';

/// Màn hình thêm/sửa ngân sách
class AddEditBudgetPage extends StatefulWidget {
  final BudgetEntity? budget;

  const AddEditBudgetPage({super.key, this.budget});

  @override
  State<AddEditBudgetPage> createState() => _AddEditBudgetPageState();
}

class _AddEditBudgetPageState extends State<AddEditBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  List<CategoryEntity> _categories = [];
  CategoryEntity? _selectedCategory;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    // Nếu edit mode, pre-fill data
    if (widget.budget != null) {
      _amountController.text = widget.budget!.amount.toStringAsFixed(0);
      _selectedPeriod = widget.budget!.period;
      _startDate = widget.budget!.startDate;
      _endDate = widget.budget!.endDate;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final dashboardDataSource = sl<DashboardLocalDataSource>();
      final categories = await dashboardDataSource.getAllCategories();
      setState(() {
        _categories = categories
            .map((m) => m.toEntity())
            .where((c) => c.type != TransactionCategoryType.income)
            .toList();
        _isLoading = false;

        // Nếu edit mode, tìm và set selected category
        if (widget.budget != null) {
          _selectedCategory = _categories.firstWhere(
            (c) => c.id == widget.budget!.categoryId,
            orElse: () => _categories.first,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải danh mục: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn danh mục'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final amount = CurrencyInputFormatter.getNumericValue(_amountController.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số tiền phải lớn hơn 0'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final budget = BudgetEntity(
      id: widget.budget?.id ?? const Uuid().v4(),
      categoryId: _selectedCategory!.id,
      amount: amount,
      period: _selectedPeriod,
      startDate: _startDate,
      endDate: _endDate,
    );

    context.read<BudgetBloc>().add(SetBudget(budget: budget));

    Navigator.of(context).pop(true);
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    setState(() {
      _endDate = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.budget != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Sửa Ngân Sách' : 'Thêm Ngân Sách'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Selector
                    const Text(
                      'Danh mục',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<CategoryEntity>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(category.icon, color: category.color, size: 20),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Vui lòng chọn danh mục';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Amount Input
                    const Text(
                      'Số tiền ngân sách',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: 'VND',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        CurrencyInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số tiền';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Số tiền phải lớn hơn 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Period Selector
                    const Text(
                      'Chu kỳ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<BudgetPeriod>(
                      segments: const [
                        ButtonSegment(
                          value: BudgetPeriod.monthly,
                          label: Text('Tháng'),
                          icon: Icon(Icons.calendar_month),
                        ),
                        ButtonSegment(
                          value: BudgetPeriod.quarterly,
                          label: Text('Quý'),
                          icon: Icon(Icons.calendar_view_month),
                        ),
                        ButtonSegment(
                          value: BudgetPeriod.yearly,
                          label: Text('Năm'),
                          icon: Icon(Icons.calendar_today),
                        ),
                      ],
                      selected: {_selectedPeriod},
                      onSelectionChanged: (Set<BudgetPeriod> newSelection) {
                        setState(() {
                          _selectedPeriod = newSelection.first;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Start Date
                    const Text(
                      'Ngày bắt đầu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      tileColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: _selectStartDate,
                    ),

                    const SizedBox(height: 24),

                    // End Date (Optional)
                    Row(
                      children: [
                        const Text(
                          'Ngày kết thúc (tùy chọn)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (_endDate != null)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _endDate = null;
                              });
                            },
                            child: const Text('Xóa'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      tileColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      leading: const Icon(Icons.event),
                      title: Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Không giới hạn',
                        style: TextStyle(
                          color: _endDate != null ? null : Colors.grey,
                        ),
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: _selectEndDate,
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveBudget,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          isEditMode ? 'Cập nhật' : 'Lưu',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
